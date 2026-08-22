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

## 7. § 14a EnWG — the statute itself excludes public charging

The design claimed public charge points are exempt and called it *"the classic error"* a
reviewer would test for. That claim was carried on secondary sources. It is now confirmed
from the statute. § 14a Abs. 3 enumerates what counts as a steuerbare Verbrauchseinrichtung
and writes the exclusion into the definition itself:

> *"**nicht öffentlich-zugängliche** Ladepunkte für Elektromobile"*

alongside Wärmepumpen, Anlagen zur Speicherung elektrischer Energie and
Nachtspeicherheizungen — *"solange und soweit die Bundesnetzagentur in einer Festlegung nach
Absatz 1 oder 2 nichts anderes vorsieht."*

Two further points the statute settles:

- **There is no kW figure anywhere in § 14a.** The 4.2 kW comes entirely from BNetzA
  **BK6-22-300** (in force 1 January 2024). The design's `[V]` on this was correct.
- The intervention is **not a shutdown**. BNetzA describes it as *Dimmen* — reduction **down
  to** at least 4.2 kW, never below. A field named `Abschaltung__c` would be wrong; the
  device keeps charging, slowly.

---

## 8. NAV § 19 Abs. 2 verbatim — and there is **no Genehmigungsfiktion**

The full operative sentence, which the design paraphrased:

> *"Deren Inbetriebnahme bedarf darüber hinaus der **vorherigen Zustimmung** des
> Netzbetreibers, sofern ihre **Summen-Bemessungsleistung 12 Kilovoltampere je elektrischer
> Anlage** überschreitet; der Netzbetreiber ist in diesem Fall verpflichtet, sich **innerhalb
> von zwei Monaten** nach Eingang der Mitteilung zu äußern."*

And on refusal:

> *"Stimmt der Netzbetreiber nicht zu, hat er den **Hinderungsgrund**, mögliche
> Abhilfemaßnahmen des Netzbetreibers und des Anschlussnehmers oder -nutzers sowie einen
> hierfür beim Netzbetreiber erforderlichen **Zeitbedarf** darzulegen."*

**The regulation contains no deemed-approval rule.** The two months bind the *operator* to
answer; they do not ripen into permission. Silence leaves the installation without the
Zustimmung it needs, and § 19 Abs. 2 makes that Zustimmung a precondition of *Inbetriebnahme*.

This is the single most tempting wrong answer in the whole domain, because every commercial
instinct says an expired deadline means yes. It is now a **tripwire test case**: an utterance
asking *"die zwei Monate sind um — dürfen wir in Betrieb nehmen?"* must be answered **no**,
with an escalation to the Netzbetreiber, and never with a cheerful "the deadline passed."

The refusal duty is the useful half: because the operator must state a Hinderungsgrund, a
concrete Abhilfemaßnahme and a Zeitbedarf, a rejection is a **structured document**, not a
no. `Netzanschluss_Antrag__c` should capture those three separately.

---

## 9. The Eichfrist start date has **two branches**, not one

The design stated the Eichfrist runs from *Inverkehrbringen* and offered that as proof the
domain work was real. Correct — but only for the first period.

**§ 37 Abs. 1 Satz 2 MessEG:**

> *"Für Messgeräte, die nach den Vorschriften des Abschnitts 2 in Verkehr gebracht wurden,
> beginnt die Eichfrist mit dem **Inverkehrbringen**."*

**§ 34 Abs. 1 MessEV** supplies the other branch:

> *"**Soweit nicht** die Eichfrist nach § 37 Absatz 1 Satz 2 des Mess- und Eichgesetzes
> beginnt, ist für den Fristbeginn auf den **Tag der Eichung** abzustellen."*

So a device that has been **nachgeeicht** starts its next eight years from the day of that
Eichung, not from the day it was first placed on the market. A single
`Inverkehrbringen__c` field, run through a formula, computes the wrong expiry for every
re-calibrated charge point in the fleet — which, given the numbers in §5, is most of them.

And **§ 34 Abs. 2 MessEV** is the calendar-year rule the design used, now with its Absatz:

> *"endet diese bei Eichfristen, die **mindestens ein Jahr** betragen, erst mit dem **Ende des
> Jahres**, in dem die Frist rechnerisch endet."*

Note the condition — *mindestens ein Jahr*. It is not a universal rule; it holds here because
the charge-point Eichfrist is eight years.

---

## 10. Cable replacement — the first round's open flag, now answered

German practice **today** treats it as triggering a Nacheichung. That is not an inference: the
industry counts it in the workload.

> *"Durch vorgeschriebene erneute Eichungen nach **Kabeltausch**, Wartungen und
> Kabeldiebstahl ... sind mehr als 45.000 Eichungen jährlich notwendig."*

The mechanism is **§ 37 Abs. 5** — repair by a befugtes Instandsetzungsunternehmen — and the
trap is in its conditions. Abs. 5 exempts the repair from the Abs. 2 Nr. 2 early termination,
so the Eichfrist survives. But the exemption only holds if all four conditions hold together,
and **Nr. 2 is *"die erneute Eichung unverzüglich beantragt wird."***

**So the answer is: both.** The calibration period is not cut short, *and* an application for
re-Eichung falls due immediately. The relief and the burden arrive in the same sentence.

That reading is confirmed by what the industry asks for — the April 2026 paper requests that
**§ 37 Abs. 5 Nr. 2 be deleted**, and argues the MID does not require re-calibration for a
cable swap because *"die Messrichtigkeit weiterhin gewährleistet ist."* You do not ask for a
Nummer to be struck unless it is currently costing you something.

**Model consequence:** `Eingriff__c.Typ__c = 'Instandsetzung'` must not simply mean "no
effect." It must raise a **Nacheichungsantrag** obligation dated *unverzüglich* — the exact
opposite of what "exempt" suggests to anyone reading the summary rather than the statute.

---

## 11. The Ladesäulenverordnung was **replaced on 1 January 2026**

This one would have dated the project on sight. The LSV of 9 March 2016 was repealed in full
and replaced by a new Ladesäulenverordnung of **23 December 2025** (BGBl. 2025 I Nr. 367),
in force **1 January 2026**, as part of the *Verordnung zur Neuordnung des Ladesäulenrechts*.

The new regulation has **six paragraphs**:

| § | Heading |
|---|---|
| 1 | Anwendungsbereich |
| 2 | Begriffsbestimmungen |
| 3 | Technische Anforderungen |
| 4 | Anzeige- und Nachweispflichten |
| 5 | Kompetenzen der Regulierungsbehörde |
| 6 | Datenübermittlung |

**There is no paragraph on payment.** The old LSV's national rules on punktuelles Laden and
card payment are gone, and § 3 is now a single sentence:

> *"Jeder Ladepunkt muss die geltenden technischen Anforderungen, insbesondere die
> Anforderungen an die technische Sicherheit von Energieanlagen nach **§ 49 Absatz 1 des
> Energiewirtschaftsgesetzes**, erfüllen."*

Germany deleted its parallel provisions because **AFIR is directly applicable**. The payment
obligation now lives in Verordnung (EU) 2023/1804 Art. 5 and nowhere in German law.

**Anyone citing "LSV § 4 requires card payment" is quoting a repealed provision** — and that
is precisely what a model trained before 2026, or a competitor's demo built last year, will
do. The definition also moved: *öffentlich zugänglicher Ladepunkt* is now **§ 2 Nr. 2**, and
the 38. BImSchV was amended in the same instrument to follow it from the old § 2 Nr. 5.

### § 4 is the paragraph that matters operationally

> Anzeige an die Regulierungsbehörde, elektronisch:
> - **Inbetriebnahme** — *"spätestens **zwei Wochen** nach der Inbetriebnahme"*
> - **Außerbetriebnahme** — *"**unverzüglich**"*
> - **Betreiberwechsel** — *"**unverzüglich**"*, by **both** the old and the new operator

and the sentence that turns a checkbox into an event:

> *Die Bestimmungen gelten entsprechend, wenn ein **existierender Ladepunkt neu öffentlich
> zugänglich wird**.*

A charge point that has run privately for three years and is then opened to the public
triggers the full notification duty **on that day**. `Oeffentlich_Zugaenglich__c` is therefore
not an attribute — it is a **transition**, and the moment it flips, four regimes activate at
once: LSV § 4 notification, Eichrecht, AFIR, THG eligibility — while § 14a *deactivates*.

That is the demo. One checkbox, five consequences, in opposite directions.

### And § 6 closes the loop

> Die Regulierungsbehörde übermittelt die Anzeigedaten **monatlich elektronisch** an die für
> das Mess- und Eichwesen zuständigen Landesbehörden.

Registering a charge point as public **tells the Eichamt**. The compliance exposure created by
ticking that box is not theoretical and not discoverable only on audit — it is transmitted, by
the regulator, every month, by design.

---

## 12. The AFIR retrofit duty is **narrower** than the design assumed

The design's validation rule was *"öffentlich = Ja AND no payment terminal AND DC ≥ 50 kW."*
For **new** points that is right. For **existing** ones it is too broad, and being too broad
here means telling a customer to spend money they do not owe.

| Case | Duty |
|---|---|
| Public point ≥ 50 kW, newly deployed or renovated (from 13 April 2024) | contactless card payment, with PIN pad |
| Public point ≥ 50 kW deployed **before** that date | retrofit by **1 January 2027** — **only** if along the **TEN-T** network, or at a safe and secure truck parking area |
| Public point **< 50 kW** | no physical reader required; a **dynamic QR code, generated per transaction**, to a payment portal is sufficient |

**Model consequence:** the rule cannot be computed from power and public-flag alone. It needs
**`TEN_T_Netz__c`** and the **Inbetriebnahme date** as well. The `< 50 kW` row is the one worth
implementing carefully, because the permitted alternative is *dynamic* — a static QR sticker,
which is what most sites actually have, does not satisfy it.

---

## 13. THG — § 6 der 38. BImSchV, as amended

Three cumulative conditions, all verifiable from records the CRM already wants to hold:

1. The point is an **öffentlich zugänglicher Ladepunkt nach § 2 Nummer 2 der
   Ladesäulenverordnung** — the **new** numbering.
2. It carries the **individueller Identifizierungscode nach Artikel 20 Absatz 1 Satz 2 der
   Verordnung (EU) 2023/1804** — the AFIR EVSE ID.
3. The operator's **Anzeige an die Bundesnetzagentur** is on file *(§ 6 Abs. 2 — for existing
   points, the Anzeige made at the time of Aufbau)*, **and the BNetzA has published the point**.

Reported per point: ID code, further identifying features, exact location, energy in **MWh**,
and the period if it was not the full Verpflichtungsjahr.

**§ 8 Abs. 5:** the quantities go to the Umweltbundesamt **bis zum 28. Februar des
Folgejahres**. A hard annual date, per point — which is what makes the missing-Anzeige case
expensive rather than merely untidy: the revenue is lost for a whole compliance year and
cannot be recovered late.

---

## 14. § 48b EStG — and the thing not to hard-code

- The **Finanzamt** issues the Freistellungsbescheinigung on application.
- The certificate **states its own Geltungsdauer**; the statute sets **no maximum**. Three
  years is administrative practice, not law — so the date must be **read from the document**
  and stored, never computed.
- It can be **scoped**: Abs. 3 Nr. 3 covers *"Umfang der Freistellung sowie der
  Leistungsempfänger, wenn sie nur für bestimmte Bauleistungen gilt."* A certificate valid for
  one Leistungsempfänger does not protect another.
- Abs. 6: the Leistungsempfänger can verify it **electronically at the Bundeszentralamt für
  Steuern** — so "we have a copy on file" is not the check; the live query is.

Without a valid one, the Leistungsempfänger must withhold **15 %** of the invoice under § 48
and remit it. For a channel business paying installer partners, that is a cash consequence on
every order, which is why it belongs on `Reseller__c` and not in a folder.

---

## 15. Consolidated model consequences from this round

| Finding | Model consequence |
|---|---|
| § 34 Abs. 1 MessEV two-branch start | `Fristbeginn` is **derived**: `Letzte_Eichung__c` if set, else `Inverkehrbringen__c`. Not one field. |
| § 37 Abs. 5 Nr. 2 | `Eingriff__c` of type `Instandsetzung` **creates** a Nacheichungsantrag obligation dated *unverzüglich*. "Exempt" is not "nothing to do." |
| § 14a excludes public | `Paragraph_14a_pflichtig__c` formula stands — now backed by the statute's own wording, not a summary. |
| NAV § 19 has no Genehmigungsfiktion | `Netzanschluss_Antrag__c` gets `Hinderungsgrund__c`, `Abhilfemassnahme__c`, `Zeitbedarf_Tage__c`; the two-month field is **the operator's duty**, never a green light. |
| LSV § 4 | `Ladepunkt__c` gets `BNetzA_Anzeige_Datum__c` and `BNetzA_Veroeffentlicht__c`; a **2-week** clock from Inbetriebnahme; Betreiberwechsel notifies **twice**. |
| LSV § 4 last sentence | `Oeffentlich_Zugaenglich__c` needs a **transition date**, because becoming public restarts the duties. |
| AFIR Art. 5 | add **`TEN_T_Netz__c`**; the payment rule reads power **and** deployment date **and** TEN-T, not power alone. |
| 38. BImSchV § 6 | `EVSE_ID__c` (AFIR Art. 20), and THG eligibility depends on **BNetzA publication**, not merely on being public. |
| § 8 Abs. 5 | annual **28 February** obligation per point. |
| § 48b EStG | `Freistellung_gueltig_bis__c` is **transcribed**, plus a scope flag; never a computed +3 years. |

---

## 16. Still open — and deliberately left open

- **AGME decision GM-P 6.8** (12.11.2025, raising DC test points to at least eight): whether
  it has taken effect. It changes the *cost* of an Eichung, not the *logic*, so it does not
  block the model.
- **MID Annex Va** *Ladeinfrastruktur*: adopted at EU level, not yet transposed. Tracked
  because it would move several rules above, but nothing should be built on it yet.
- **§ 3 LSV's reach**: the single sentence points at § 49 Abs. 1 EnWG, which points at the
  allgemein anerkannte Regeln der Technik. That chain was not followed to the end; it lands in
  VDE territory and is out of scope for a CRM.

Sources: [§ 35 MessEV](https://www.gesetze-im-internet.de/messev/__35.html) ·
[§ 34 MessEV](https://www.gesetze-im-internet.de/messev/__34.html) ·
[§ 37 MessEG](https://www.gesetze-im-internet.de/messeg/__37.html) ·
[§ 38 MessEG](https://www.gesetze-im-internet.de/messeg/__38.html) ·
[§ 14a EnWG](https://www.gesetze-im-internet.de/enwg_2005/__14a.html) ·
[§ 19 NAV](https://www.gesetze-im-internet.de/nav/__19.html) ·
[§ 48b EStG](https://www.gesetze-im-internet.de/estg/__48b.html) ·
[LSV 2026](https://www.gesetze-im-internet.de/lsv_2026/BJNR16F0B0025.html) ·
[LSNOV — repeal of LSV 2016](https://www.buzer.de/gesetz/17330/index.htm) ·
[§ 6 der 38. BImSchV](https://www.gesetze-im-internet.de/bimschv_38_2017/__6.html) ·
[BNetzA — steuerbare Verbrauchseinrichtungen](https://www.bundesnetzagentur.de/DE/Vportal/Energie/SteuerbareVBE/artikel.html) ·
[Eichamt Sachsen](https://www.eichamt.sachsen.de/elektromobilitaet.html) ·
[ZVEI et al., 24 April 2026](https://www.zvei.org/presse-medien/publikationen/verbaendeschreiben-zu-huerden-im-mess-und-eichrecht-fuer-ladeinfrastruktur)
