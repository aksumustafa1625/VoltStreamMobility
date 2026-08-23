/**
 * Deterministic transcript gate.
 *
 * Every paragraph the agent utters must have been handed to it by an action that ran for that
 * question. No model, no embedding, no threshold to defend: a citation was either returned by the
 * engine or it was invented, and that is a binary.
 *
 * The gate exists because of a measurement, not a principle. Cosine similarity scored a correct
 * German legal sentence 0.919, a wrong one 0.888 and a lie about a repealed ordinance 0.855 - six
 * points between true and false, because German legal prose is lexically alike either way and only
 * the numbers and the paragraph references move. Those are exactly what a similarity discounts and
 * exactly what this gate reads.
 *
 * The eval transcript carries what the agent said but not what the action returned, so ground
 * truth is produced separately: the same action is called with the same inputs through anonymous
 * Apex, and its citation list is the allowed set.
 *
 * Granularity, stated rather than implied: the gate matches at paragraph and statute level, so
 * "§ 34 MessEV" is checked but "Abs. 2" against "Abs. 1" is not. That catches the failure that
 * actually happens - a paragraph or an ordinance the engine never returned, such as the repealed
 * Ladesaeulenverordnung - and it does not catch a wrong Absatz within a correct paragraph. Tighten
 * it when a case needs it; do not pretend it is tighter than it is.
 *
 * Usage: node scripts/transkriptGate.mjs specs/eichrecht-gate.json [target-org]
 */

import { execSync } from 'node:child_process';
import { readFileSync, writeFileSync, mkdtempSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

const GESETZE = 'MessEG|MessEV|EnWG|NAV|LSV|BImSchV|GEIG|AFIR|BK6';
const PARAGRAPH = new RegExp(`§\\s*(\\d+[a-z]?)((?:[^§]{0,80}?)(${GESETZE}))?`, 'gi');

/**
 * Reduce a stretch of German legal prose to the set of things it claims the law says.
 * Two keys per reference: the bare paragraph, and the paragraph bound to its statute. A sentence
 * naming a statute is held to the stricter of the two.
 */
function zitate(text) {
    const bloss = new Set();
    const mitGesetz = new Set();
    if (!text) return { bloss, mitGesetz };
    for (const treffer of text.matchAll(PARAGRAPH)) {
        const nummer = treffer[1].toLowerCase();
        const gesetz = treffer[3] ? treffer[3].toLowerCase() : null;
        bloss.add(nummer);
        if (gesetz) mitGesetz.add(`${nummer}|${gesetz}`);
    }
    return { bloss, mitGesetz };
}

/**
 * Both CLI commands the gate uses exit non-zero on a perfectly good run - the eval runner because
 * it is in beta and writes a warning to stderr, `apex run` because of how it reports. Their output
 * is what matters, so a non-zero exit with output on stdout is treated as output rather than as
 * failure. A run that produces nothing still throws.
 */
function lauf(befehl) {
    try {
        return execSync(befehl, { encoding: 'utf8', maxBuffer: 64 * 1024 * 1024, stdio: ['ignore', 'pipe', 'pipe'] });
    } catch (fehler) {
        if (fehler.stdout && fehler.stdout.length) return fehler.stdout;
        throw new Error(`Befehl lieferte keine Ausgabe: ${befehl}\n${fehler.stderr ?? fehler.message}`);
    }
}

/** Undo the HTML entities the CLI writes into its debug stream. */
function entschaerft(text) {
    return text
        .replace(/&#124;/g, '|')
        .replace(/&lt;/g, '<')
        .replace(/&gt;/g, '>')
        .replace(/&amp;/g, '&')
        .trim();
}

function jsonAusAusgabe(roh) {
    const start = roh.indexOf('{');
    if (start < 0) throw new Error('Keine JSON-Antwort erhalten:\n' + roh.slice(0, 400));
    return JSON.parse(roh.slice(start));
}

/** What the agent said, per test case id. */
function agentenAntworten(ergebnis) {
    const je = new Map();
    for (const fall of ergebnis.result?.results ?? ergebnis.results ?? []) {
        const bewertung = (fall.evaluation_results ?? []).find((b) => b.actual_value);
        if (bewertung) je.set(fall.id, bewertung.actual_value);
    }
    return je;
}

/**
 * What the engine actually returned, per test case id. Generated as anonymous Apex rather than
 * read from the transcript, because the transcript does not carry action outputs - and asking the
 * engine the same question is a better ground truth than trusting the runner to expose one.
 */
function engineGrundwahrheit(faelle, org) {
    const zeilen = [];
    for (const f of faelle) {
        if (!f.ladepunktNummer && !f.betreiber) continue;
        zeilen.push(`{
  PruefeEichfristen.Anfrage a = new PruefeEichfristen.Anfrage();
  a.ladepunktNummer = ${f.ladepunktNummer ? `'${f.ladepunktNummer}'` : 'null'};
  a.betreiber = ${f.betreiber ? `'${f.betreiber}'` : 'null'};
  PruefeEichfristen.Antwort r = PruefeEichfristen.pruefe(new List<PruefeEichfristen.Anfrage>{a})[0];
  System.debug(LoggingLevel.ERROR, 'GATE::${f.id}::' + r.rechtsgrundlagen);
}`);
    }
    const datei = join(mkdtempSync(join(tmpdir(), 'gate-')), 'grundwahrheit.apex');
    writeFileSync(datei, zeilen.join('\n'), 'utf8');

    const ausgabe = lauf(`sf apex run --file "${datei}" -o ${org}`);
    const je = new Map();
    for (const zeile of ausgabe.split(/\r?\n/)) {
        // The command echoes the source before the log, so the marker appears twice per case -
        // once in the statement that prints it and once in the line it printed. Only the log line
        // carries a value; matching the echo would compare the agent against a fragment of Apex.
        if (!zeile.includes('USER_DEBUG')) continue;
        // The separator is '::' rather than a pipe because the CLI HTML-escapes the debug stream:
        // a pipe comes back as &#124; and a marker built on it never matches. Same family of
        // defect as escaping the agent's German - it is invisible until something stops matching.
        const treffer = zeile.match(/GATE::([^:]*)::(.*)$/);
        if (treffer) je.set(treffer[1], entschaerft(treffer[2]));
    }
    return je;
}

/**
 * Paragraphs the agent uttered that the engine never handed over. The whole gate is this function;
 * everything else fetches its two arguments.
 */
function erfundeneZitate(gesagt, uebergeben) {
    const g = zitate(gesagt);
    const e = zitate(uebergeben);
    const schlecht = [];
    for (const schluessel of g.mitGesetz) {
        const [nummer, gesetz] = schluessel.split('|');
        if (!e.mitGesetz.has(schluessel)) schlecht.push(`§ ${nummer} ${gesetz} (nicht übergeben)`);
    }
    for (const nummer of g.bloss) {
        const hatGesetz = [...g.mitGesetz].some((k) => k.startsWith(`${nummer}|`));
        if (!hatGesetz && !e.bloss.has(nummer)) schlecht.push(`§ ${nummer} (nicht übergeben)`);
    }
    return schlecht;
}

/**
 * A gate that only ever passes proves nothing, so it proves on every run that it can fail. Fixed
 * strings, no org, four cases - and the one that matters is the second: the exact sentence the
 * similarity scorer waved through at 0.855, citing an ordinance repealed on 1 January 2026. This
 * gate rejects it not because it sounds wrong but because no action returned that paragraph.
 */
function selbsttest() {
    const faelle = [
        { name: 'zitiert genau das Übergebene',
          gesagt: 'Die Frist endet nach § 34 Abs. 2 MessEV zum Jahresende.',
          uebergeben: '§ 34 Abs. 2 MessEV; § 37 Abs. 1 Satz 2 MessEG', erwartet: 0 },
        { name: 'zitiert eine aufgehobene Verordnung',
          gesagt: 'LSV § 4 verlangt Kartenzahlung an allen öffentlichen Ladepunkten.',
          uebergeben: '§ 34 Abs. 2 MessEV', erwartet: 1 },
        { name: 'zitiert ohne dass etwas übergeben wurde',
          gesagt: 'Der Ladepunkt ist geschützt nach § 38 MessEG.',
          uebergeben: '', erwartet: 1 },
        { name: 'nennt gar keinen Paragraphen',
          gesagt: 'Zu dieser Nummer existiert kein Ladepunkt.',
          uebergeben: '', erwartet: 0 }
    ];
    for (const f of faelle) {
        const ist = erfundeneZitate(f.gesagt, f.uebergeben).length;
        if (ist !== f.erwartet) {
            console.error(`Selbsttest fehlgeschlagen — "${f.name}": erwartet ${f.erwartet} Verstoß/Verstöße, gefunden ${ist}.`);
            console.error('Das Gate misst nicht, was es zu messen behauptet. Abbruch vor der eigentlichen Prüfung.');
            process.exit(2);
        }
    }
    console.log(`Selbsttest: ${faelle.length} Fälle, das Gate erkennt Erfundenes und lässt Übergebenes durch.`);
}

// ── main ─────────────────────────────────────────────────────────────────────────────────────

const konfigPfad = process.argv[2];
const org = process.argv[3] ?? 'VoltStreamDev';
if (!konfigPfad) {
    console.error('Aufruf: node scripts/transkriptGate.mjs <gate-konfig.json> [org]');
    process.exit(2);
}
const konfig = JSON.parse(readFileSync(konfigPfad, 'utf8'));

// Before measuring the agent, prove the instrument still measures.
selbsttest();

console.log(`Transkript-Gate — Spezifikation ${konfig.spec}, Org ${org}\n`);

const gesagt = agentenAntworten(
    jsonAusAusgabe(lauf(`sf agent test run-eval -s ${konfig.spec} -o ${org} --result-format json`))
);
const erlaubt = engineGrundwahrheit(konfig.faelle, org);

let verstoesse = 0;
let geprueft = 0;

for (const fall of konfig.faelle) {
    const antwort = gesagt.get(fall.id);
    if (antwort === undefined) {
        console.log(`? ${fall.id}\n    Keine Agentenantwort im Transkript gefunden.`);
        verstoesse++;
        continue;
    }
    geprueft++;

    const schlecht = erfundeneZitate(antwort, erlaubt.get(fall.id) ?? '');

    if (schlecht.length) {
        verstoesse++;
        console.log(`FAIL ${fall.id}`);
        console.log(`    Erfunden: ${schlecht.join(', ')}`);
        console.log(`    Übergeben: ${erlaubt.get(fall.id) || '(nichts)'}`);
        console.log(`    Gesagt: ${antwort.replace(/\s+/g, ' ').slice(0, 220)}\n`);
    } else {
        const anzahl = zitate(antwort).bloss.size;
        console.log(`PASS ${fall.id} — ${anzahl} Paragraph${anzahl === 1 ? '' : 'en'} genannt, alle übergeben`);
    }
}

console.log(`\n=== ${geprueft - verstoesse} PASS / ${verstoesse} FAIL von ${konfig.faelle.length} ===`);
process.exit(verstoesse ? 1 : 0);
