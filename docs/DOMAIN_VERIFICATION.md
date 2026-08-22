# Domain verification — Eichrecht

Primary sources read 2026-08-22. Every claim below is quoted from the statute or from a
dated industry document, because the whole thesis rests on the domain being right rather
than plausible.

The open question that motivated this was the highest-consequence one in the review: if
German metrology law lets a fleet extend its calibration period by testing a sample, then
modelling the Eichfrist as a per-device clock is wrong, and the first thing a metrology
person would say to the demo is *"that is not how we do it."*

---

## 1. Stichprobenverfahren does **not** apply to charge points — and the industry is asking for it

**§ 35 MessEV** ([gesetze-im-internet.de](https://www.gesetze-im-internet.de/messev/__35.html))
allows a calibration period to be extended for a *Los* of devices on the strength of a
sample. Its scope line is the answer:

> *"Messgeräte für **Elektrizität, Gas, Wasser oder Wärme**, die in einem **Los**
> zusammengefasst sind"*

Conditions, all of which must hold together:

- ≥ **95 %** of the lot must meet the essential requirements under § 6 Abs. 2 MessEG
- *"Nachgewiesen ist, dass alle im Los erfassten Messgeräte **baugleich** sind"*
- the procedure must be **notified to the authority before testing begins** (§ 40 Abs. 1 MessEG)
- testing by bodies with the required competence and equipment
- application **at earliest two years** before the Eichfrist expires
- it must start early enough that **the entire lot could be replaced** before expiry if the
  proof fails

Charging stations are not in that scope list, and the decisive evidence is that the industry
is currently **petitioning to have the mechanism created for them**. From the joint position
paper *"Mess- und Eichrecht für Ladeinfrastruktur praxistauglich ausgestalten"*, **24 April
2026**, signed by ZVEI, ADAC, BDEW, BVES, CharIN, INSPIRE, S.A.F.E. and emob, addressed to
the BMWE ([PDF](https://www.zvei.org/presse-medien/publikationen/verbaendeschreiben-zu-huerden-im-mess-und-eichrecht-fuer-ladeinfrastruktur)):

> *"**Einführung eines gesetzlich verankerten Stichprobenverfahrens** für die 'Nacheichung'
> von Ladesäulen: Nach Ablauf der regulären achtjährigen Eichfrist **sollte** eine
> stichprobenartige anstelle der routinemäßigen 'Nacheichung' von Ladesäulen **ermöglicht
> werden**, um den Prüfaufwand zu reduzieren."*

You do not ask for something you already have.

**Conclusion: the per-device clock is correct.** And the finding is worth more than a
correct model — it is a dated, cited answer to a question a metrology reviewer would use to
test whether the domain work was real. Knowing precisely why a plausible mechanism does
*not* apply, and being able to name the four-month-old paper petitioning for it, is a
stronger signal than never having heard of it.

---

## 2. § 37 MessEG has **three** paths, not one — and they have different consequences

This is where both the original design and its correction were too simple. The design said
a firmware push leaves the Eichfrist unaffected. A reviewer corrected that to *"§ 37 Abs. 2
Nr. 2 ends it early."* The statute distinguishes three cases
([§ 37 MessEG](https://www.gesetze-im-internet.de/messeg/__37.html)):

| Event | Provision | Eichfrist | May the device be used? |
|---|---|---|---|
| An **Eingriff** that can affect metrological properties, or that extends/restricts the field of use | **Abs. 2 Nr. 2** | **ends early** | no — non-conformant |
| **Repair by an authorised repairer**, meeting four conditions | **Abs. 5** | **exempt** from early termination | yes |
| **Software update** | **Abs. 6** | *"Eichfristen bleiben **unberührt**"* | **no, until the authority approves** |

**Abs. 2 Nr. 2**, verbatim:

> *"ein **Eingriff** vorgenommen wird, der Einfluss auf die messtechnischen Eigenschaften des
> Messgeräts haben kann oder dessen Verwendungsbereich erweitert oder beschränkt"*

**Abs. 5** is the escape hatch, and it is conditional on four things together: the device
meets the essential requirements after repair; **Nr. 2 — *"die erneute Eichung unverzüglich
beantragt wird"***; the repair is marked per § 41; and the authority is notified immediately.

**Abs. 6** is the software path. A device may resume operation only after approval by the
authority under § 40 Abs. 1, which requires confirmation that the software and device are
suitable, conformity-assessment documentation, permanent recording of the update in the
device, and a spot-check. **The calibration period itself is not touched.**

### Why this makes the model better rather than merely more accurate

The interesting operational state is the third one, and neither the original design nor its
correction had it:

> A charge point whose calibration is **valid**, whose Eichfrist has **not** expired, and
> which nonetheless **may not legally operate** — because a software update is waiting on
> an Eichbehörde approval.

The industry confirms this is a real bottleneck rather than a theoretical one:

> *"Derzeit muss gemäß **§ 37 Abs. 6 Nr. 1 MessEG i.V.m. § 40 MessEV** die Eignung von
> Software und Messgeräten für das Software-Update durch die zuständige Eichbehörde geprüft
> werden. Dies führt zu **erheblichen Verzögerungen** bei der Nacheichung von Ladesäulen
> nach Software-Updates."*

And the same paper asks for **§ 37 Abs. 5 Nr. 2 to be deleted** so that repairs by
authorised repairers stop triggering a re-Eichung application at all — which tells you
exactly how much friction that one Nummer generates in practice.

---

## 3. § 38 MessEG is a **grace period**, not a deadline

The ten-week figure has been carried through the design as *"you must apply ten weeks
before expiry."* The statute says something more useful
([§ 38 MessEG](https://www.gesetze-im-internet.de/messeg/__38.html)), quoted in full:

> **§ 38 Verspätete Eichungen**
> *"Hat der Verwender die Eichung **mindestens zehn Wochen vor Ablauf der Eichfrist**
> beantragt und das zur Eichung seinerseits Erforderliche getan oder angeboten, steht das
> Messgerät **trotz des Ablaufs der Eichfrist** bis zum Zeitpunkt der behördlichen
> Überprüfung **einem geeichten Messgerät gleich**. Hat der Verwender die Eichung zu einem
> späteren Zeitpunkt beantragt und ist der Behörde eine Eichung vor Ablauf der Eichfrist
> nicht möglich, so **kann** sie das weitere Verwenden des Messgeräts bis zum Zeitpunkt der
> behördlichen Überprüfung **gestatten**. Die Behörde soll die Eichung nach Ablauf der
> Eichfrist unverzüglich vornehmen."*

Crossing the ten-week line does not put you in breach. It **loses you the automatic
protection** and puts continued operation at the authority's discretion — *kann*, not *muss*.

That yields three deterministic states from two dates, which is precisely the shape this
agent should be computing:

| State | Condition | Meaning |
|---|---|---|
| **GESCHÜTZT** | applied ≥ 10 weeks before expiry | legally equivalent to calibrated past expiry, until the authority checks |
| **ERMESSEN** | applied later | the authority *may* permit continued use — no entitlement |
| **ABGELAUFEN** | not applied | expired, no protection |

A binary "expired / not expired" field would have thrown away the middle state, which is the
one an operator actually lives in.

---

## 4. AC and DC are both eight years

Answers an open flag that suspected DC might carry a different period. The Saxon Eichamt
([eichamt.sachsen.de](https://www.eichamt.sachsen.de/elektromobilitaet.html)) states both
plainly:

```
AC-Ladesäulen: 8 Jahre
DC-Ladesäulen: 8 Jahre
```

The same page independently confirms the early-termination rule in operator-facing language:

> *"Nach einem **Eingriff oder Umbau** an der E-Ladesäule **endet möglicherweise die
> Eichfrist vorzeitig**."*

Note *möglicherweise* — consistent with Abs. 2 Nr. 2's *"haben **kann**"*. The test is
whether the intervention **can** affect metrological properties, not whether it did.

And the calendar-year-end rule holds: a device may remain in use through 31 December of the
year in which the period technically ends.

---

## 5. The operational numbers, from the April 2026 paper

These are the figures that make the problem real rather than theoretical, and they are
recent enough to be quotable:

| | |
|---|---|
| Public charge points in Germany, **1 Feb 2026** | **~200,000**, of which **~50,000** fast-charging |
| Eichungen per year the authorities' working group assumed | ~6,000 (from the 8-year period) |
| Eichungen per year **actually needed** | **more than 45,000** |
| Why the gap | cable replacement, maintenance, and **cable theft — up to 100 cases per day** |
| Time for one DC Eichung, at today's 2–3 test points | **at least two hours** |
| Cost of one DC Eichung | **regularly over €500** |
| Proposed increase in DC test points (AGME decision GM-P 6.8, 12.11.2025) | to **at least eight** |
| Cost of DC test equipment operators are being told to buy themselves | **six figures** |
| German conformity-assessment procedures | *"teilweise bis zu **12 Monaten**"* |

> *"Durch vorgeschriebene erneute Eichungen nach **Kabeltausch, Wartungen und Kabeldiebstahl**
> — teils bis zu **100 Fälle täglich** — sind **mehr als 45.000 Eichungen jährlich**
> notwendig."*

Cable theft is the detail worth keeping. It is the kind of fact that cannot be inferred from
reading the law, only from reading what operators say about living under it — and it turns
the Eichfrist from an eight-year timer into a continuously firing event stream. A CRM that
models only the eight-year clock would miss the ninety percent of re-calibrations that come
from theft and maintenance.

Also worth noting: operators are being told to provide DC test equipment themselves *"teilweise
unter Androhung erheblicher Sanktionen bis hin zur **Stilllegung** der Ladeinfrastruktur und
Verhängung von empfindlichen Bußgeldern."*

---

## 6. What this changes in the data model

| Was | Now |
|---|---|
| `Eichfrist_Ende__c` from Inverkehrbringen + 8 years, calendar-year end | **Unchanged and confirmed**, for both AC and DC |
| A `Stichprobe` regime alternative | **Not needed.** Cite § 35 MessEV's scope and the April 2026 petition instead. |
| Firmware push ends the Eichfrist | **Wrong.** Three separate paths — Abs. 2 Nr. 2 (Eingriff, ends), Abs. 5 (repair, exempt on four conditions), Abs. 6 (software, Eichfrist untouched but operation blocked pending approval). |
| A single `Letzter_Firmware_Eingriff__c` date | Needs an **`Eingriff__c`** child with a *type* — `Eingriff` / `Instandsetzung` / `Software-Update` — because the consequence differs per type. § 37 Abs. 6 approval is per event, so history is required rather than a last-value field. |
| Nacheichung: "must apply ≥10 weeks before" | **Three states**, not a deadline: GESCHÜTZT / ERMESSEN / ABGELAUFEN. |
| Eichfrist as an eight-year timer | Also an **event-driven stream** — cable replacement, maintenance and theft drive ~45,000 of the ~45,000+ annual re-calibrations against an assumed 6,000. |

The last row is the one that changes the demo. The interesting question is not *"when does
this charger's eight years run out"* but *"a cable was stolen last night — which of these
three regimes did that just put the device into, and may it operate this morning?"*

---

## 7. Still open

- Whether a **cable replacement** is an Abs. 2 Nr. 2 Eingriff, an Abs. 5 Instandsetzung, or
  neither. The position paper argues the MID does not require re-calibration for it and asks
  Germany to align — which implies German practice currently treats it as triggering one.
- The **MID Annex Va "Ladeinfrastruktur"** amendment: adopted, not yet transposed into German
  law. Worth tracking, because it would change several of the rules above.
- Whether **AGME decision GM-P 6.8** (12.11.2025, eight DC test points) has taken effect.

Sources: [§ 35 MessEV](https://www.gesetze-im-internet.de/messev/__35.html) ·
[§ 37 MessEG](https://www.gesetze-im-internet.de/messeg/__37.html) ·
[§ 38 MessEG](https://www.gesetze-im-internet.de/messeg/__38.html) ·
[Eichamt Sachsen — Elektromobilität](https://www.eichamt.sachsen.de/elektromobilitaet.html) ·
[ZVEI et al., position paper 24 April 2026](https://www.zvei.org/presse-medien/publikationen/verbaendeschreiben-zu-huerden-im-mess-und-eichrecht-fuer-ladeinfrastruktur)
