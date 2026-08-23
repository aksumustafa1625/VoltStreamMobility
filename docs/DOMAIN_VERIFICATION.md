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
| Public charge points in Germany, **1 July 2026** (BNetzA) | **209,605** — 155,264 AC, **54,341 DC**, 9.04 GW, **12,993 registered operators** |
| Eichungen per year the authorities' working group assumed | ~6,000 (from the 8-year period) |
| Eichungen per year **actually needed** | **more than 45,000** |
| Why the gap | cable replacement, maintenance **and** theft, together — see the correction below |
| Time for one AC Eichung, 2 points | **~90 minutes, ~€330** (Eichamt Sachsen, 01/2026) |
| Time for one DC Eichung | **at least two hours**, **regularly over €500** |
| Statutory hourly rate (MessEGebV, Schlüsselzahl H 7.2, billed purely by time) | **€279.40 / €219.90 / €174.30** per hour by qualification |
| DC test points required (AGME **GM-P 6.8, Stand 20.02.2026**) | **exactly eight** — a voltage × current matrix, not a minimum |
| Cost of DC test equipment operators are being told to buy themselves | **six figures** |
| German conformity-assessment procedures | *"teilweise bis zu **12 Monaten**"* |

### ⚠️ Correction — the "100 per day" figure does not mean cable theft

An earlier version of this file read that clause as *"cable theft — up to 100 cases per day."*
**That is a misreading**, found independently by two later research passes. The German is:

> *"Durch vorgeschriebene erneute Eichungen nach **Kabeltausch, Wartungen und Kabeldiebstahl**
> — teils bis zu **100 Fälle täglich** — sind **mehr als 45.000 Eichungen jährlich**
> notwendig."*

The parenthetical modifies **all three triggers together**, and the arithmetic proves it:
(45,000 − 6,000) ÷ 365 ≈ **107 per day** for the combined list. Theft alone at 100 per day
would be 36,500 a year and leave nothing for the other two.

There is also **no national cable-theft statistic in Germany at all** — only operator-level
reporting. What the evidence actually supports:

| Figure | Source |
|---|---|
| **~15 cases per day** reaching Alpitronic, Europe's largest HPC vendor | electrive, 18 Sep 2025 |
| EnBW: **>750 cables** stolen across ~120 sites since early 2025, damages in the single-digit millions | electrive, 18 Sep 2025 |
| **€5,000–8,000 repair cost per incident** — against ~€40–50 of copper to the thief | electrive, 18 Sep 2025 |
| Cologne: **4 cases in 2024 → 66 in 2025, +1,550 %**, hitting ~80 % of the city's fast chargers | electrive, 10 Feb 2026 |

The **conclusion survives the correction, and is better sourced for it.** The Eichfrist is
still an event stream rather than an eight-year timer — roughly 39,000 of the ~45,000 annual
re-calibrations are event-driven rather than schedule-driven. Only the attribution changes:
maintenance and cable replacement dominate, and theft is the fastest-growing contributor
rather than the largest one.

This correction is left in place rather than silently edited, because a project whose claim is
*"the numbers are checked"* has to show what happened when a number failed the check.

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
- The intervention is described as *Dimmen* — reduction **down to** at least 4.2 kW. But
  "never a shutdown" is only half true, and the missing half is the half that matters for
  charge points. See §17.3.

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

**Correction, 2026-08-23 — Absatz 1 has _four_ sentences, and this document had read two.**
The passage quoted above is Satz 2. Two more follow it, and both change the answer for a real
fleet. `[M]` — read from the statute while building `Eichfrist_Ende__c`, not before.

| Satz | Rule |
|---|---|
| 1 | The default Eichfrist is **two years**, *soweit nicht etwas anderes* is prescribed. Anlage 7 Nr. 6.7 is what makes charge points eight — the eight is a table entry, not a property of charge points. |
| 2 | Fristbeginn is the **Tag der Eichung**, *soweit nicht* § 37 Abs. 1 Satz 2 MessEG applies. |
| **3** | *"Wird ein Messgerät **nach Ablauf der Eichfrist** geeicht, beginnt die neue Eichfrist mit **Ablauf der vorausgegangenen Eichfrist**."* |
| **4** | *"Wenn ein Messgerät nach Ablauf der Eichfrist **nachweislich länger als ein Jahr nicht verwendet** wurde, ist für den erneuten Fristbeginn auf den **Tag der Eichung** abzustellen."* |

**Satz 4 is relief from Satz 3, not a fourth independent branch.** Calibrate late and the new
period is backdated to the end of the old one — the months you were late are deducted from the
next eight years. The only escape is proving the device sat unused for over a year, and
*nachweislich* puts that burden squarely on the operator.

So a system that quietly takes the favourable branch is wrong **in the dangerous direction**:
it grants protection the statute withholds. That is not a hypothetical here, it is measured.
`Eichfrist_Ende__c` — whose `BLANKVALUE(Letzte_Eichung__c, Inverkehrbringen__c)` cannot see
chronology — returns **2032-12-31** for a device placed on the market 2015-06-01 and calibrated
2024-03-10. The statute says **2031-12-31**.

Two consequences, both already built:

- **`Eingriff__c.Stilllegung_nachgewiesen__c`.** The Satz 4 claim is an explicit, evidenced
  entry on the record. Left false, `EichrechtService` applies the backdating. A checkbox is a
  poor substitute for proof, but a *defaulted* checkbox would be a lie, and this one defaults
  to the harsher answer.
- **The status matrix carries the case as `DEFERRED`, not `PASS`.** Case `E` prints the
  formula's answer and the statute's answer side by side and is counted separately. The run
  reads **15 PASS / 1 DEFERRED / 0 FAIL**, which is the honest number — a green 16 would have
  meant the test was asserting the formula against itself.

**One more thing Absatz 2 and 3 add.** Both close with a *Vermutung*: where the year of
Inverkehrbringen is not otherwise established, it is **presumed** from the § 14 marking. The
law supplies a fallback for the missing date. `Eichstatus__c` currently answers `UNBEKANNT`
there, which is safe but not complete — the presumption is a v1.1 item, and it is recorded
rather than assumed away.

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

## 12. AFIR Art. 5 — three of my corrections were themselves wrong

The first round narrowed the retrofit duty and called that a correction. The narrowing was
right; almost everything around it was not. Article 5(1), verbatim:

> *"At publicly accessible recharging points **deployed from 13 April 2024**, recharging on an
> ad hoc basis shall be possible using a payment instrument that is widely used in the Union.
> … including **at least one of the following**: (a) payment card readers; (b) devices with a
> contactless functionality that is at least able to read payment cards; (c) **for publicly
> accessible recharging points with a power output below 50 kW**, devices using an internet
> connection and allowing for secure payment transactions such as those generating a
> **specific Quick Response code**."*

Three errors in what this file previously said:

| Claimed | Actually |
|---|---|
| The duty applies to points **≥ 50 kW** | It applies to **all** publicly accessible points deployed from 13 April 2024. The 50 kW line only decides **which** payment means qualify. |
| Trigger is *"newly deployed or renovated"* | Trigger is **"deployed from 13 April 2024"**. Renovation is not in the text. |
| A card reader **with PIN pad** is required | **AFIR nowhere requires a PIN pad.** That requirement was carried in from a secondary source. |

Also: *"specific"* Quick Response code, not *"dynamic"*. And an exemption this file missed
entirely — *"The requirements laid down in this paragraph **shall not apply to publicly
accessible recharging points that do not require payment**."*

### The corrected matrix

| Point | Deployed | Requirement | From |
|---|---|---|---|
| Public, **≥ 50 kW** | from 13.4.2024 | card reader **or** contactless — (a)/(b) only | 13.4.2024 |
| Public, **< 50 kW** | from 13.4.2024 | (a), (b) **or** a specific QR code (c) | 13.4.2024 |
| Public **≥ 50 kW** on **TEN-T** or a **safe and secure parking area** | **including before 13.4.2024** | must satisfy (a) **or** (b) | **1.1.2027** |
| Public ≥ 50 kW **elsewhere**, deployed before 13.4.2024 | before 13.4.2024 | **no AFIR retrofit duty** | — |
| Free-of-charge points | any | **exempt** | — |

The retrofit narrowing survives. The rest is replaced.

### Five further Article 5 duties that were never modelled

| | Duty | Deadline |
|---|---|---|
| **5(2)** | Where automatic authentication is offered, the user must always be able to **decline it** | in force |
| **5(4)** | At **≥ 50 kW** the ad-hoc price **must be per kWh** and **must be displayed at the station**; below 50 kW the components must appear in the order kWh → minute → session → other | in force |
| **5(7)** | All publicly accessible points must be **digitally connected** | **14.10.2024** |
| **5(8)** | Points built after 13.4.2024 or renovated after 14.10.2024 must be **smart-recharging capable** | in force |
| **5(10)** | **All DC** publicly accessible points must have a **fixed cable** | **14.4.2025** |

**5(11)** puts the duty on the *owner* where the owner is not the operator — a split this CRM
has to be able to represent, because in a channel business it is the normal case.

### TEN-T is a routing computation, not a radius

**Art. 2(3) AFIR:**

> *"'along the TEN-T road network' means … that they are located on the TEN-T road network or
> **within 3 km driving distance from the nearest exit of a TEN-T road**"*

**Driving distance from the nearest exit.** A 3 km buffer around a polyline answers a different
question and gets it wrong in both directions — 3 km straight-line can be 8 km by road, and a
site 4 km away as the crow flies can be 2 km from the exit. Since the 1 January 2027 duty turns
on this, `TEN_T_Netz__c` cannot be a checkbox someone ticks by looking at a map.

Model it as a **stored, dated, re-validated attribute** — `core` / `comprehensive` /
`within_3km` / `off_network` / **`unknown`** — with `unknown` as a first-class state that
demands human resolution rather than defaulting to "no duty."

### AFIR has **no penalties article** — and what Germany does instead is worse

Searched the full text: zero occurrences of *penalt*, *sanction*, *infringe*, *enforc*.
Article 24 is *Reporting and review*. There is no fine anywhere in the Regulation.

German enforcement is **§ 5 der neuen LSV**, and it is not a Bußgeld:

> *"(2) Die Regulierungsbehörde kann verlangen, dass ein Ladepunkt **nachgerüstet** wird …
> (3) Die Regulierungsbehörde kann den **Betrieb eines Ladepunkts untersagen**, wenn eine
> technische Anforderung nach § 3 oder eine Anforderung nach Artikel 5 Absatz 1, 2, 7, 8 oder 10
> … nicht eingehalten … oder der **Anzeigepflicht nach § 4 Absatz 1 nicht nachgekommen** worden
> ist."*

A fine is a number. **An operating ban is the end of the revenue** — and, because a banned point
falls out of the register, it takes the THG claim with it. See §13.

So the answer the agent gives to *"what happens if we miss AFIR"* is not *"a fine of X"*. It is
*"the Bundesnetzagentur can order the retrofit, and can stop you operating — and if it does, you
also lose the year's THG revenue for that point."*

---

## 13. THG — a law passed in June 2026 that rewrote the section this file cited

This is the largest gap the second research round found. The **Zweites Gesetz zur
Weiterentwicklung der Treibhausgasminderungs-Quote** — BGBl. **2026 I Nr. 163**, issued
1 June 2026, promulgated 5 June, **in force 7 June 2026** — rewrote **§§ 1, 3, 5, 6, 7 and 8**
of the 38. BImSchV. Everything this file said about THG was read against the pre-June text.

### My citation was wrong

| Claimed | Actually |
|---|---|
| *"**§ 8 Abs. 5**: report by 28 February of the following year"* | The deadline is **§ 8 Abs. 1 Satz 1 Nr. 1**. **§ 8 Abs. 5 is a brand-new provision** and says something else entirely: *"Mitteilungen nach Absatz 1, die unvollständig sind, werden von der zuständigen Stelle **abgelehnt**."* |
| § 6 requires the point to have been **published** by the BNetzA | § 6 Abs. 3 Nr. 1 is **disjunctive** — published **or** the Dritter has given the BNetzA **consent to publication**. Given that the publication lag is unbounded and unpublished, the consent route is the practical hedge. |

### Two deadlines, not one — and both are preclusive

| Route | Deadline |
|---|---|
| **§ 6** — public charge points, metered MWh | **28 February of the following year** |
| **§ 7** — non-public, flat per-vehicle Schätzwert, pure BEV only | **15 November of the obligation year itself** |

The UBA is explicit that there is no late filing: *"Hierbei handelt es sich um **gesetzliche
Fristen, die nicht zur Disposition stehen**."* No Wiedereinsetzung route is offered and no case
law exists. Miss it and the year is gone.

### Three new traps, all introduced in June 2026

1. **One filing per point per year.** *"Mitteilungen nach Satz 1 Nummer 1 können für den
   jeweiligen Ladepunkt für das jeweilige Verpflichtungsjahr **nur einmal** erfolgen."* Filing
   in September forfeits the rest of the year.
2. **The 500 MWh lock-out.** Where a *designated person* rather than the operator files, a
   second filing in the same year is allowed only if the previous one covered **at least
   500 MWh**. An aggregator that files 300 MWh in March is locked out until January — across
   its whole client book.
3. **Incomplete means rejected**, not queried (§ 8 Abs. 5). And **since 17 April 2026 the UBA
   charges €94.60–€6,500 per Bescheid** — so an incomplete filing now costs money to be refused.

### The EVSE-ID, and the trap inside it

The Bekanntmachung § 6 Abs. 4 called for was found: **BAnz AT 30.06.2026 B9**, UBA, 10 June 2026.
The IDRO is **Energie Codes und Services GmbH**, a BDEW subsidiary. And:

> *"**Über die … vergebene Operator ID hinaus ist für die Mitteilung … für jeden Ladepunkt
> zwingend die gesamte Electric Vehicle Supply Equipment ID (EVSEID) anzugeben**"*

Format is DIN SPEC 91286: `DE * <3-char Operator ID> * E <Power Outlet ID>` — e.g.
`DE*8AA*E456*78*321`. The operator prefix is issued by ECS; **the point-level part is
self-assigned**, so no registry call per charge point. Since 15 January 2026 an operator may
hold **several** Operator IDs, so the prefix is a multi-valued attribute, not a constant.

**And here is the trap, which is the best single demo beat in the whole domain:**

| | **BNetzA (LSV § 4)** | **UBA (38. BImSchV § 6)** |
|---|---|---|
| EVSE-ID | **optional** — *"falls vorhanden"* | **mandatory, full ID, per point** |
| Format in the official example | `DE*ABC*123456789` — **no `E`** | `DE*ABC*E12345678` — **with `E`** |

An operator who follows the BNetzA's own template is **fully LSV-compliant and silently
disqualified from THG revenue.** Two federal authorities, one identifier, incompatible
instructions — and the failure is invisible until the money does not arrive, by which time
28 February has passed.

### What the money actually is

Every input is statutory, so this is computable rather than quoted:

```
Anrechnungsfaktor 3 · 3.6 GJ/MWh · (Basiswert 94 − Netzmix 119 × 0.4)  =  501 kg CO₂e per MWh
```

| Electricity source | t CO₂e per MWh | vs grid |
|---|---|---|
| Grid mix | **0.501** | — |
| Photovoltaik | **0.947** | **+89 %** |
| Wind an Land | 0.994 | +98 % |
| Wind auf See | 1.004 | +100 % |

**Qualifying under § 5 Abs. 5 — renewables taken directly from a plant behind the same grid
connection point, now including electricity buffered in a battery — roughly doubles the revenue
per MWh.** That is the largest single lever a charge point operator has, and it is a *site
design* decision, which is exactly the kind of thing a channel partner should be advised on
before the concrete is poured.

There is **no official price index** — every €/MWh figure in circulation comes from a trader.
Two competing traders quoted within six days of each other agree within ~3 %: **~150–175 €/MWh**
for grid electricity in August 2026, implying **~310–345 €/t CO₂e**. A statutory ceiling exists:
§ 37c Abs. 2 Nr. 1 BImSchG prices non-compliance at **€600/t**, so nobody rationally pays more.

For scale: a 2,000 MWh operator missing 28 February loses on the order of **€330,000**, and it
cannot be recovered late.

### Two structural facts worth keeping

**The quota path steepens hard.** 12 % in 2026 → **17,5 % in 2027** — the largest single step in
the schedule, and the reason prices recovered in 2026. It runs to **65 % by 2040**.

**The Anrechnungsfaktor of 3 was kept to 2034**, not tapered from 2030 as the draft proposed.
This is a win for operators — and the **UBA's own FAQ still says the opposite.**

### The stale-guidance problem is the agent's reason to exist

The UBA FAQ that German practitioners actually read is dated 17 July 2025 and is **wrong on at
least six points** after June 2026: it cites the repealed LSV's paragraph numbers for both the
operator definition and the Anzeige, describes public accessibility under the old and narrower
test, says intra-year partial filing is possible when it is now once per point per year, says
*"Der Bescheid ergeht kostenfrei"* when it has cost money since April, and says the factor
tapers from 2030 when it holds to 2034.

That is the case for the whole project stated in one paragraph: **the authoritative summary is
stale, the statute is not, and the gap between them is where the money is lost.**

### And the 2027 collision

The **AFIR retrofit deadline of 1 January 2027** sits **four weeks** before the **THG deadline of
28 February 2027**. A point that fails AFIR can be ordered off by the BNetzA, which removes it
from the register, which fails § 6 Abs. 3 Nr. 1, which kills the THG claim for the whole year.

**These two tracks are coupled, and no tool models them together.** That is the demo.

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

## 16. The two flags from §7, now closed

### AGME GM-P 6.8 — in force, and the date circulating in the press is wrong

The document is *"Prüfanweisung … im Anwendungsbereich Elektromobilität (GM-P 6.8
Elektromobilität) **vom 20.02.2026**"*, 36 pages. The AGME approved the Neufassung on
**25 November 2025** and editorial corrections to section 3.7 were added with **Stand
20 February 2026**. **No document bearing the date 12.11.2025 exists** — that date appears
only in the industry paper and in press copied from it, and this file repeated it.

It is a *Verwaltungsvorschrift* binding the Eichbehörden. It contains no *Inkrafttreten*, no
*Übergangsfrist* and no *gilt ab* — **effective on adoption, with no grandfathering.**

And the substance is sharper than "at least eight." Tabelle 6 is a voltage × current matrix
with **exactly eight** marked cells, and Tabelle 7 enumerates them as *"1. Prüfpunkt"* through
*"8. Prüfpunkt"*. It prescribes eight, not a minimum of eight.

**The exception nobody in the press mentions is the operationally useful half:**

> *"**AUSNAHME:** Wird ein in der Baumusterprüfbescheinigung … aufgeführter Elektrizitätszähler
> / Messwertaufnehmer verwendet, dessen Eichung oder Konformitätsbewertung / Vorprüfung nicht
> länger als ein Jahr zurückliegt, und wird … eine messtechnische Leitungsverlustkompensation
> … durchgeführt, kann davon ausgegangen werden, dass **die Prüfung an einem Lastpunkt
> (Betriebspunktprüfung) ausreichend ist**."*

Eight collapses to **one** where a recently-verified certified meter is used together with
line-loss compensation. For an agent advising an operator, that is the answer worth giving —
the cost of a DC Eichung is a function of the hardware chosen, not a fixed fate.

### MID Annex Va — now a directive with dates, and a category error to avoid

**Richtlinie (EU) 2026/706 of 11 March 2026** (OJ L, 2026/706, 20.3.2026; CELEX 32026L0706),
amending Directive 2014/32/EU for *Messanlagen für Ladeeinrichtungen für Elektrofahrzeuge*.
Ordinary legislative procedure under Art. 114 TFEU — not a delegated act. It creates a new
instrument category, **MI-011**.

| Milestone | Date |
|---|---|
| Entry into force | **9 April 2026** |
| Transposition deadline | **10 April 2028** |
| Application | **10 October 2028** |
| Nationally-compliant instruments may still be placed on the market until | 10 April 2030 |
| Existing certificates valid to expiry, capped at | 10 April 2038 |

Annex Va covers conductive transfer *"in beide Richtungen"* — **V2G is in scope** — across road,
rail, boats, ships and aircraft, measured *am Übergabepunkt*, and expressly **not** as utility
metering. Three accuracy classes A/B/C (2 % / 1 % / 0.5 %). Conformity assessment: *"B + F oder
B + D oder G oder H1."*

The cable provision the industry wanted is in **Annex Va § 4**: a connector cable may be
exchanged under seal only if it is declared exchangeable in the conformity assessment,
uniquely marked, and *"getrennt so gesiegelt …, dass für den Austausch weder ein Zugang zu den
messtechnisch gesiegelten Bauteilen … noch ein **Bruch des metrologischen Siegels** erforderlich
ist."*

**Germany has not transposed it and is not late** — the deadline is 2028.

🔑 **The category error worth stating, because it is easy to make and would be visible:**
Annex Va governs **placing on the market**. It does **not** govern **Eichung and Nacheichung in
service**, which remain national. **Transposing the MID will not reduce GM-P 6.8's eight DC test
points, on any timeline.** The two industry demands — sampling for Nacheichung, and MID
transposition — are legally distinct and solve different problems.

### Still open

- **§ 3 LSV's reach**: the single sentence points at § 49 Abs. 1 EnWG, which points at the
  allgemein anerkannte Regeln der Technik. That chain was not followed to the end; it lands in
  VDE territory and is out of scope for a CRM.


---

## 17. Netzanschluss — a broken cross-reference, and two fields that were one

### 17.1 🔴 BK6-22-300 points at a paragraph that no longer exists

This is the most interesting thing in the entire domain, and it is four months old and unaddressed.

**BK6-22-300 Ziffer 2.4.1** defines a controllable charge point as:

> *"ein Ladepunkt für Elektromobile, der **kein öffentlich zugänglicher Ladepunkt im Sinne des
> § 2 Nr. 5 der Ladesäulenverordnung (LSV)** ist"*

**§ 2 Nr. 5 LSV no longer exists.** The Ladesäulenverordnung was repealed on 1 January 2026 and
the new one has four numbers in § 2. The definition now sits at **§ 2 Nr. 2** — and its substance
changed.

**Old § 2 Nr. 5** turned on the car park and gave the operator an opt-out:

> *"…wenn der zum Ladepunkt gehörende **Parkplatz** … tatsächlich befahren werden kann, **es sei
> denn, der Betreiber hat … durch eine deutlich sichtbare Kennzeichnung oder Beschilderung die
> Nutzung auf einen individuell bestimmten Personenkreis beschränkt**"*

**New § 2 Nr. 2** adopts the AFIR wording and **deletes the signage opt-out**:

> *"…unabhängig davon, ob sich der Ladepunkt auf öffentlichem oder privatem Grund befindet,
> **ob der Zugang zu dem Standort oder den Räumlichkeiten Beschränkungen oder Bedingungen
> unterliegt** und ungeachtet der für die Nutzung des Ladepunkts geltenden Bedingungen"*

**Restrictions on access no longer stop a point being public.** And because § 14a applies only to
**non-public** points, a broader reading of "public" **narrows § 14a's scope** — potentially
pulling depot and workplace charging out of the controllable-load regime and, separately, into
the THG § 6 route (§13 above). Two regimes move in opposite directions off one changed definition.

**No BNetzA correction, Mitteilung or guidance addressing this could be found.** It is a live,
unresolved contradiction between a 2023 Festlegung and a 2026 ordinance.

For a project whose thesis is *"the summary is stale and the statute is not,"* this is the
strongest possible exhibit: **the regulator's own binding decision now cites a repealed
provision, and the substitute is not equivalent.** The honest agent answer is not a
classification — it is *"this turns on a definition that changed on 1 January 2026 and the
decision has not been updated; here are both readings and what each costs."*

### 17.2 We modelled one field where the law has two

The design carried a single `Paragraph_14a_Modul__c`. R8 said it was on the wrong object and
came from the wrong Festlegung. Both true — and there are actually **two independent elections**.

| Election | Level | Made to | Source |
|---|---|---|---|
| **Modul 1 / 2 / 3** — the Netzentgelt reduction | **per Marktlokation** | **the electricity supplier**, not the DSO | BK8-22/010-A |
| **Direktansteuerung vs EMS** — how the device is controlled | **per device** | the DSO | BK6-22-300 Ziff. 4.4 |

BK8 Rn. 148 is explicit that the module has nothing to do with the grid operator:

> *"Der Betreiber trifft **gegenüber dem Lieferanten** die Wahl für Modul 2 als Alternative zu
> Modul 1 bzw. für Modul 3 als Ergänzung zu Modul 1. **Zwischen dem Netzbetreiber und dem
> Betreiber besteht insoweit kein vertragliches Verhältnis.**"*

And the module attaches to the metering point, not the connection or the device (Rn. 90):
*"je Marktlokation … unabhängig davon, ob eine oder mehrere steuerbare Verbrauchseinrichtungen
über eine Marktlokation abgerechnet werden."*

**Defaults and rules worth encoding:** Modul 1 applies automatically where no election is made or
the customer is in Grundversorgung. A module change is **never retroactive** — *"Ein rückwirkender
Modulwechsel ist ausgeschlossen."* Modul 2 requires a **separate Marktlokation** and cannot be
combined with Modul 1. Modul 3 is only ever **in addition to** Modul 1.

### 17.3 The 4,2 kW does two jobs, and does not aggregate for charge points

Confirmed from Anlage 1 and worth stating precisely, because it is easy to get backwards:

- **As a threshold** (Ziff. 2.4.1) — above 4,2 kW Netzanschlussleistung, in Niederspannung, a
  non-public charge point **is** a steuerbare Verbrauchseinrichtung.
- **As a floor** (Ziff. 4.5.1) — *"beträgt die Mindestleistung 4,2 kW"*.

**The 0,4 scaling factor is for heat pumps and cooling only.** A charge point's floor is a flat
4,2 kW however large it is.

#### ⚠️ But the floor binds the *instruction*, not the *response* — and a simple wallbox goes to zero

An earlier version of this file said the reduction is *"never a shutdown."* That is half true,
and the missing half is the half that matters. **Ziffer 4.6 Satz 2:**

> *"Sofern es einer steuerbaren Verbrauchseinrichtung aus technischen Gründen nicht möglich ist,
> den netzwirksamen Leistungsbezug auf den vom Netzbetreiber vorgegebenen Wert zu reduzieren,
> muss eine Reduzierung auf den **nächstgeringeren Wert, der technisch möglich ist**, erfolgen."*

And the Beschluss reasoning (p. 70) forecloses the obvious objection:

> *"Vorsorglich sei auch darauf hingewiesen, dass eine Unmöglichkeit insbesondere **nicht** aus
> der Tatsache herrühren kann, dass die betreffende teilnahmepflichtige Anlage **nur die
> Möglichkeit zur vollständigen Ausschaltung** besitzt, nicht aber die Möglichkeit zur
> stufenweisen … Ansteuerung."*

**So a relay-switched, non-modulating wallbox is lawfully taken to zero**, with no claim to the
4,2 kW — and it cannot use that inability to qualify for the Ziff. 10.6 hardship exemption
either. Only modulating hardware actually delivers the guarantee.

That turns the 4,2 kW from a reassurance into a **hardware purchasing decision**, which is
precisely the kind of thing a channel partner should be told before the order is placed. Any
sales copy promising *"you always keep 4.2 kW"* is wrong for on/off equipment.

#### And BK6-22-300 mandates no hardware at all

Term-counted against the binding Anlage 1: **`intelligente` 0 · `Smart-Meter` 0 · `Steuerbox` 0 ·
`CLS` 0 · `MsbG` 0 · `Rundsteuer` 0.** The Festlegung is technology-neutral; its only equipment
clause is Ziff. 4.6 Satz 1 (the device must be *"stets steuerbar"*). **The iMSys/Gateway mandate
comes from § 14a Abs. 4 EnWG and § 29 MsbG, not from the decision.** Anyone writing
*"BK6-22-300 requires a smart meter gateway"* is citing the wrong instrument.

Two consequences the design did not have:

- **The obligation attaches before any hardware exists** — *"Die technische Inbetriebnahme …
  setzt **nicht** bereits das Vorhandensein der … notwendigen Steuertechnik … voraus."*
- **Ordering the metering operator is full exculpation, and the discount still runs**:
  *"Unabhängig davon, wann der Einbau der Steuerungstechnik stattfindet, **erhält er die
  Netzentgeltreduzierung**."*

That — not a Rundsteuerempfänger — is the answer to *"what if there is no smart meter yet."*
Ripple control appears in BK6 exactly once, and it is used to **deny** hardship relief, not to
authorise an interim arrangement.

**And aggregation does not apply to charge points at all.** Ziff. 2.4.2 limits summing to
Fallgruppen b. and c. — heat pumps and cooling — because the rule exists to stop cascades being
split artificially. **Each charge point above 4,2 kW is its own steuVE with its own floor.** The
data model must treat charge points individually and heat pumps as summed groups; one rule for
both would be wrong in one direction or the other.

### 17.4 Curtailment is ultima ratio, and the trigger is 80 % — not overload

BK6 Ziff. 4.2 requires the occasion to be established *"auf Basis der Netzzustandsermittlung"*,
and the reasoning is unusually direct:

> *"…dass der Netzbetreiber im Sinne des hier tragenden **Ultima-ratio-Ansatzes ausschließlich bei
> Vorliegen einer akuten Handlungsnotwendigkeit aus aktuellem Anlass tätig wird und **nicht
> präventiv**."*

Two things follow that a model would otherwise miss:

- The **15 % / 7 %** measurement-coverage figures in Ziff. 2.6 are **superseded** — the
  *"anderweitige Empfehlung"* they were conditional on arrived as the VDE FNN Hinweis of
  10.04.2025, replacing them with a topology-differentiated table.
- Intervention may begin at **80 % of equipment loading** (or −8 % voltage), proven by direct
  measurement — not at actual overload.

**Preventive control does exist, but only transitionally**: until 31.12.2028, for at most 24
months per network area, and **capped at two hours per day** (Ziff. 10.5).

### 17.5 🔴 A deadline four months away

> **Ziff. 10.6** — charge points that *"nachweislich technisch nicht gesteuert werden können"*,
> whose controllability cannot be established *"mit vertretbarem technischem Aufwand"*, and which
> are commissioned **bis zum Ablauf des 31.12.2026**, are exempt from Ziffern 3–5 entirely.

The burden of proof is on the operator, and the absence of a digital interface does not by itself
make out impossibility if the device can be switched by other means. **This window closes in
roughly four months** and is exactly the kind of dated, consequential fact the agent exists to
surface.

The other date: **Bestandsanlagen convert on 01.01.2029** (Ziff. 10.2). Switching in early is
voluntary, the DSO **cannot refuse** it, and it is **one-way** — *"Ein erneuter Wechsel zurück …
ist nicht möglich."*

### 17.6 Three things that do **not** exempt you

Ziff. 3.2, verbatim, and all three are common assumptions:

> *"¹Die etwaige **Zahlung eines Baukostenzuschusses** … **entbindet den Betreiber nicht** von der
> Teilnahmeverpflichtung. ²Die Einbindung … in einen **Pool** … entbindet … nicht. ³Die
> **Abwesenheit von Netzengpässen** entbindet ebenso nicht."*

Paying the connection contribution, joining a pool, and there being no congestion — none of them
buys you out of controllability.

### 17.7 The notification duty has no lower bound

The first round framed this as *"below 12 kVA, notification only."* That is backwards.
**§ 19 Abs. 2 NAV requires notification of every charging device at any power.** The 12 kVA line
only *adds* the Zustimmung.

And there is a second, independent duty the design never had: **VDE-AR-N 4100 requires an
Anmeldung at ≥ 3,6 kVA** — and it catches ordinary sockets:

> *"Dazu zählen nicht nur Ladeeinrichtungen zum konduktiven Laden … sondern auch … **Stromkreise
> mit Haushalts- oder Industriesteckvorrichtungen (Schutzkontakt- oder CEE-Steckdosen)**, die für
> den Anschluss von ladeleitungsintegrierten Steuer- und Schutzeinrichtungen für die
> **Ladebetriebsart 2** … vorgesehen sind."*

Note also **VDE-AR-N 4100:2026-04**, released 5 March 2026, supersedes the 2019 edition. Most DSO
TABs still cite the old one.

### 17.8 Two process steps, not one — and both are installer-gated

**§ 14 Abs. 2 NAV** adds a second act the design collapsed into the first:

> *"Jede Inbetriebsetzung … ist bei ihm von **dem Unternehmen, das nach § 13 Abs. 2 die Arbeiten an
> der Anlage ausgeführt hat, in Auftrag zu geben**."*

The Inbetriebsetzungsauftrag can only be placed by **the same registered company that did the
work**. So a partner losing its registration mid-project does not merely delay the next job — it
strands the current one.

### 17.9 § 11 NAV — 30 kW is an allowance, not a trigger

> *"**(3)** Ein Baukostenzuschuss darf **nur für den Teil der Leistungsanforderung erhoben werden,
> der eine Leistungsanforderung von 30 Kilowatt übersteigt**."*

A 100 kW connection is charged on **70 kW**, not on 100. And § 11 NAV governs **Niederspannung
only** — above that there is no statutory basis, and the BNetzA's BKZ position paper of 20.11.2024
derives it from §§ 17, 21 EnWG using a Leistungspreismodell instead.

**The commercial lever nobody models: § 17 Abs. 2b EnWG flexible connection agreements**, worth
roughly **70 % off the BKZ** at one large DSO. The statute prescribes five mandatory contents —
the limitation level, the period(s), the term, the technical requirements, and **the customer's
liability on exceedance** — which is a five-field entity, not a checkbox. And § 14a stays
untouched alongside it.

### 17.10 The Installateurverzeichnis rule we had was wrong — and the real one is sharper

The design carried *"registration lasts five years, with a three-month notification window for
changes."* Read against the **BDEW/ZVEH Grundsätze, Ausgabe Januar 2024**, both halves are off.

**The five years** is a *"soll"*, a **maximum**, and applies to the **Installateurausweis** rather
than the registration — *"soll die Gültigkeitsdauer der Installateurausweise auf maximal fünf
Jahre begrenzt sein"*, with automatic renewal expressly **not** recommended and the first term
allowed to differ. Renewal now also requires **two documented Fortbildungsmaßnahmen** within the
validity period.

**The three months is not a notification window at all.** Changes are notifiable **unverzüglich**:
*"Das Installationsunternehmen hat den Netzbetreiber über das **Ausscheiden einer Verantwortlichen
Elektrofachkraft** … **unverzüglich** zu informieren."*

The real three-month rule is far more consequential:

> *"**Bei Ausscheiden der letzten Verantwortlichen Elektrofachkraft** … **ruht die Eintragung**.
> Ist **spätestens innerhalb von drei Monaten** keine Verantwortliche Elektrofachkraft wieder
> **fest** im Installationsunternehmen eingestellt, **kann die Löschung** aus dem
> Installateurverzeichnis erfolgen."*

**A vacant VEFK post suspends the registration immediately** — not after three months. The three
months is the window to fill it before deletion. And without registration the partner may not
lawfully work behind the Hausanschlusssicherung at all (§ 13 Abs. 2 NAV), nor place the
Inbetriebsetzungsauftrag (§ 17.8).

That makes `VEFK_Name__c` on `Reseller__c` not a contact field but a **status field with an
immediate legal effect and a three-month fuse** — the sharpest partner-compliance rule in the
domain, and the design had it as a nicety.

#### Two things about the VEFK that are widely repeated and wrong

**It is not a statutory office, and DGUV Vorschrift 3 does not know it.** A full-text search of
DGUV V3 for *"verantwortliche Elektrofachkraft"* returns **zero** hits — § 3 imposes duties on the
*Unternehmer* and requires a plain *Elektrofachkraft*. The VEFK is defined by **DIN VDE 1000-10**
and operates as a written delegation under **§ 13 Abs. 2 ArbSchG**, backed by **§ 130 OWiG**
(fines to €1 million for failures of appointment, selection and supervision).

**And it is not universally mandatory.** The DKE committee that publishes the standard says so:
*"In Unternehmen oder Unternehmensbereichen **mit nur einer EFK ist keine zusätzliche VEFK
erforderlich**"* and *"Das bloße **Benennen als 'VEFK' ist nicht ausreichend**."*

**But for the Installateurverzeichnis it is a hard prerequisite, and a stricter one.** The
Grundsätze require the Sachkundenachweis (or Meister plus Sicherheitsschein) **and permanent
employment** — *"fest, d. h. nicht nur vorübergehend, angestellt."* **An external contractor
cannot satisfy it**, even where they would be acceptable as a generic VEFK. So the partner-facing
rule is narrower than the safety-law one, and that is the one this CRM models.

*(Also: the "three-year VEFK refresher" that circulates has no primary source. What is verified is
the five-year Ausweis cycle with at least two Fortbildungen. The three-year figure is a false
friend — the FNN § 14a **documents** are reviewed at least every three years.)*

### 17.10b The process is not the same at two grid operators

The most consequential process finding, because it defeats a single hard-coded workflow:

| DSO | Sequence for a wallbox |
|---|---|
| **Netze BW** | *"Eine vorherige Genehmigung durch uns als Netzbetreiber entfällt **unabhängig von der Leistung der Wallbox**"* — registration **after** installation |
| **Netze Duisburg** | *"Bei Ladeeinrichtungen mit einer Leistung **über 12 kVA** ist **vor der Installation die Genehmigung … abzuwarten**"* |

**Same statute, opposite order.** A CRM that hard-codes one sequence is wrong for half its
partners. `Netzbetreiber__c` has to carry the *process*, not just the name — which is exactly the
blast-radius argument for making it an object rather than a text field.

And **no DSO publishes a processing time.** Across seven examined, not one states a
`Bearbeitungszeit`; one actively disclaims control over it. Any SLA field must be **derived from
our own observed history**, never quoted as the operator's promise.

### 17.10c Four parties sign, not one

The BDEW explanatory note gives the reason in the statute's own terms:

> *"Die nach NAV vorzunehmende **Unterscheidung von Anschlussnehmer und Anschlussnutzer** macht es
> erforderlich, **zwei 'Einblatt-Formulare'** zu verwenden."*

So the party model needs **Anschlussnehmer · Anschlussnutzer · Grundstückseigentümer · Betreiber
der Ladeeinrichtung** as distinct roles, plus the submitting **Elektrofachbetrieb** and an optional
**Bevollmächtigter** carrying a Vollmacht document. In a channel business these are routinely four
different companies, and the design collapsed them into an Account lookup.

**Attachments are first-class, including photographs.** One DSO mandates a *"Foto des
Hausanschlusskastens"* **and** a *"Foto vom **geöffneten** Hausanschlusskasten zum Abgleich der
installierten Sicherungsgröße."* A document-management story is not decoration here.

### 17.10d Three more thresholds, from real DSO documents

| Threshold | Consequence | Source |
|---|---|---|
| **475 kW** | *"Ab 475 kW muss die Wirkleistung durch Westnetz begrenzt werden können (**Fernwirk-Gateway**)"* | Westnetz MS/HS |
| **> 1.000 kW** consumption (or > 300 kW storage) | Removed from the ordinary portal into a **criteria-based allocation queue** — *"ist eine Antragstellung über das bisherige Netzanschlussportal **ab sofort nicht mehr möglich**"* | Bayernwerk |
| **≥ 3,6 kVA** | VDE-AR-N 4100 Anmeldung, Formblatt **B.3** | FNN Hinweis |

**The 1.000 kW line is the binding one for DC hubs** — a twenty-stall 300 kW site clears it
several times over, and clearing it means the normal application route is closed. Escape is only
via a documented *privilegierte Kundengruppe*.

*(Form correction: the canonical EV datasheet at low voltage is **Anhang B.3** of VDE-AR-N 4100,
not an E-number. VDE-AR-N 4110's **E.8** is a medium-voltage generation/storage datasheet. And
**VDE-AR-N 4105:2026-03** was reissued alongside 4100:2026-04 — both core low-voltage rules
changed in 2026.)*

*(Control path: EEBUS via VDE-AR-E 2829-6-1 is the FNN **Mindeststandard**, but BK6 itself says
*"Dies schließt die Verwendung alternativer Schnittstellen nicht aus."* "EEBUS is legally
mandatory" is **not** established; "EEBUS is the safe default" is. The FNN Steuerbox controls at
most **four** devices — a fifth needs a second box.)*

### 17.11 Model consequences

| Finding | Consequence |
|---|---|
| BK6 cites a repealed § | `Oeffentlich_zugaenglich__c` needs a **legal-basis date**, and the agent must be able to say *"this definition changed on 1.1.2026 and the decision was not updated."* |
| Two separate elections | `Paragraph_14a_Modul__c` moves to a **Marktlokation** entity, elected via the supplier; a **new** per-device field carries Direktansteuerung vs EMS. |
| No aggregation for charge points | Each `Ladepunkt__c > 4,2 kW` is its own steuVE. Do not sum. |
| Notification has no lower bound | The § 19 duty is unconditional; 12 kVA only adds Zustimmung; a **second** duty starts at 3,6 kVA. |
| § 14 NAV | A distinct `Inbetriebsetzung` step, bound to the **same** registered installer. |
| § 11 Abs. 3 NAV | BKZ is charged on `max(0, kW − 30)`, and **only in Niederspannung**. |
| § 17 Abs. 2b EnWG | A five-field `Flexible_Netzanschlussvereinbarung` entity, worth ~70 % of BKZ. |
| Grundsätze § 2.2.5 | VEFK vacancy → registration **ruht** immediately; deletion possible after 3 months. Partner status must be **derived**, not typed. |
| Ziff. 10.6 | A live **31.12.2026** hardship window; Ziff. 10.2 a **01.01.2029** conversion, one-way. |

---


---

## 18. The forward calendar — what is already law but not yet in force

A compliance CRM that only knows today's rules is a filing cabinet. The dates below are
**already enacted or already consulted**, and every one of them changes what a partner should
be selling *now*.

### 18.1 🔴 1 January 2027 — the GEIG amendment changes the product

Adopted **23 July 2026** (BGBl. 2026 I Nr. 226), Artikel 7, in force **1 January 2027**. It is
published but not yet in force, so the consolidated text still shows the old version — exactly
the gap where a stale summary does damage.

**New § 5 GEIG:**

> *"Ein Ladepunkt, der **ab dem 1. Januar 2027** errichtet oder ersetzt wird, hat **intelligentes
> Laden** auf der Grundlage nichtproprietärer und diskriminierungsfreier Kommunikationsprotokolle
> und Standards, auf interoperable Weise … zu ermöglichen."*

Note **"errichtet oder ersetzt"** — a *replacement* triggers it too. Every unit in the catalogue
that cannot do smart charging becomes unsellable for new and replacement installations on that
date, and a quote written in December 2026 for a February 2027 installation is already wrong.

**New § 2 Nr. 14a redefines Vorverkabelung, and kills the cheap answer:**

> *"…eine reine Grund- oder Sammelinstallation, wie beispielsweise eine Hauptzuleitung,
> Stromschiene oder ein zentraler Verteiler ohne individuelle Abzweigung **oder das Verlegen von
> Leerrohren oder Kabelkanälen, nicht ausreichend ist**."*

**Empty conduit no longer counts.** There must be a connectable endpoint at the parking space so
a charger can be attached *"ohne weitere Elektroarbeiten."*

**New § 4 Sätze 5–7 adds a sizing duty:**

> *"Die Leitungsinfrastruktur sowie die Vorverkabelung müssen so dimensioniert werden, dass die
> nach diesem Gesetz vorgeschriebene Anzahl von Ladepunkten **gleichzeitig und effizient** genutzt
> werden kann. Bei der Vorverkabelung nicht öffentlich zugänglicher Stellplätze ist die
> Installation eines **Lademanagementsystems** zu berücksichtigen."*

So load management moves from an upsell to a statutory design consideration, subject only to a
technical-impossibility or economic-unreasonableness escape.

### 18.2 The dated calendar

| Date | What | Status |
|---|---|---|
| **30.09.2026** | Deadline in the BNetzA's **Zwangsgeldandrohung** against two grid operators for not implementing the § 14a Modul 3 tariff | **Enforcement live** |
| **01.10.2026** | **MiSpeL** Festlegung targeted effective — first time charge points become (partly) eligible for EEG support, treated like storage | Arbeitsstand published 05.08.2026, not yet adopted |
| **18.09.2026** | **AgNes** consultation closes — the complete rewrite of German network tariffs, ~€37 bn/year, decision targeted for 2026 | Draft published 06.08.2026 |
| **31.12.2026** | **§ 14a hardship exemption closes** (BK6 Ziff. 10.6) | In force |
| **01.01.2027** | **GEIG**: intelligent charging mandatory for every point erected *or replaced*; Vorverkabelung redefined | Enacted 23.07.2026 |
| **01.01.2027** | **AFIR retrofit** for ≥ 50 kW points on TEN-T / secure truck parking | In force |
| **28.02.2027** | THG filing deadline for 2026 — **four weeks after** the AFIR date, and coupled to it | In force |
| **31.12.2027** | AFIR TEN-T core raised to ≥ 600 kW pools with 2 × 150 kW | In force |
| **10.04.2028** | **MID Annex Va** transposition deadline (Richtlinie (EU) 2026/706) | In force since 09.04.2026 |
| **31.12.2028** | **StromNEV expires**; preventive § 14a control ends | — |
| **01.01.2029** | **Bestandsanlagen convert** to the § 14a regime (one-way); **AgNes tariffs apply** | In force |
| **31.12.2032** | 90 % of Pflichteinbaufälle metered (§ 29 MsbG) | Unchanged — the 2025 amendment only made the date precise |

### 18.3 Two negatives worth as much as the positives

**The NAV has not been substantively amended since 19 July 2022.** The December 2025 act touched
only § 18 Abs. 3, and only to repoint a renumbered cross-reference. So §§ 11, 13 and 19 NAV — the
three this project models — stand exactly as read. That is a clean, citable stability finding.

**BNetzA has not exercised its § 17 Abs. 4 competence on flexible connection agreements, and
formally abandoned its attempt to standardise capacity allocation.** BK6-24-245, closed
05.02.2025:

> *"Nach Sichtung der eingegangenen Stellungnahmen verfolgt die Beschlusskammer das Ziel der
> Erarbeitung eines Positionspapiers **nicht weiter**. … Es bleibt **jedem Netzbetreiber
> überlassen**, ein den Anforderungen des § 17 EnWG genügendes Verfahren zu entwickeln und
> anzuwenden … [muss aber] **auf seiner Internetseite veröffentlicht**"*

**That is the regulator saying, in terms, that the process differs per grid operator.** It is the
authority for §17.10b's finding that two DSOs read the same statute in opposite orders — and the
reason `Netzbetreiber__c` has to carry a *process*, not just a name.

### 18.4 Enforcement stopped being theoretical in 2026

Two BNetzA actions this year change the risk picture from "rules exist" to "rules are being
enforced against grid operators":

- **28.05.2026** — penalty payments threatened against two DSOs over the § 14a tariff reductions,
  with a **30 September 2026** cure deadline and more operators to follow.
- **27.03.2026** — **77 proceedings** opened against metering operators that missed the 20 %
  smart-meter quota.

For a channel business this cuts both ways and both are modellable: a customer's Modul 3 discount
may be unavailable because *their* DSO is non-compliant, and a § 14a installation may stall
because the metering operator has not delivered — neither of which is the partner's fault, and
both of which are documented, citable and therefore escalatable.

### 18.5 One gap that matters for the DC business

**VDE-AR-N 4110 is still the September 2023 edition.** Low voltage got two brand-new editions in
2026 — **4100:2026-04** (published 06.03.2026) and **4105:2026-03** (27.02.2026, adding
requirements for *rückspeisefähige Ladeeinrichtungen*) — but medium voltage, which is where HPC
hubs and truck charging parks actually connect, has had a draft pending since December 2024 with
no publication.

So the fastest-moving segment of the market is governed by the oldest rule in the family. Worth
knowing, and worth watching.

---

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
