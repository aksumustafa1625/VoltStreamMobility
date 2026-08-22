# Market reality — what the German Salesforce job market actually asks for

Researched 2026-08-22 across ~34 postings with real requirement detail, plus an unbiased scan of
**1,250 German job postings** from a public API. Weighted to senior roles, to energy and mobility
employers, and to Salesforce consulting partners.

This document exists because the project's central bet — *deep German regulatory domain knowledge
plus an Agentforce showcase* — needed testing against evidence rather than intuition. **Most of
the bet did not survive.** What follows is the honest version.

---

## 1. The binding constraint is not the portfolio

**It is German at negotiation level, plus a residency story.**

| Employer type | German required | English sufficient |
|---|---|---|
| **Consulting partners** — mindsquare, adesso, Salesfive, comselect, cbs, DIA, NFQ, entero, TechOhana | **13 of 13** | 0 |
| **In-house / product / scale-up** — auxmoney, Statista, Enpal, zolar | 0 | **4 of 4** |
| **Salesforce the vendor**, customer-facing | 3 of 3 *(one at native C2)* | 0 |
| **Utilities / Mittelstand** | German-only postings | 0 |

Of 25 postings where a stance is determinable, **18 require German (72 %)**. The hardest bars
found: *"Verhandlungssichere Deutsch- und Englischkenntnisse"* · *"Fließende Deutschkenntnisse"* ·
**native-level C2** (Salesforce Automotive) · **C1** (E.ON). One employer states residency
outright:

> **"Dein Wohnsitz liegt in Deutschland."** — mindsquare

The softest technical bar in the entire corpus is **JobRad (Freiburg): "Deutsch Grundkenntnisse
(B2)"** — and it is a mobility employer.

**No amount of portfolio depth moves that gate.** With 200 spare hours, C1 German beats every
option in §6 below.

### The visa position is better than most hiring managers believe

- **Blue Card 2026:** €50,700 general — but the **reduced threshold of €45,934.20 applies**,
  because § 18g AufenthG names *"den Gruppen … 25"* and **ISCO-08 group 25 is ICT Professionals**.
  Every credible senior Salesforce salary clears it by €25k+.
- **No degree is not a blocker.** § 18g Abs. 2 covers *"einer in den letzten sieben Jahren
  erworbenen, mindestens dreijährigen Berufserfahrung"* in ISCO 133 or 25, at academic level.
- **Chancenkarte:** 6 points, €1,091/month proof, up to 1 year, 20 h/week side work, German A1
  **or** English B2.
- No lottery, no cap, no petition, no employer fee — a usable talking point.

**But not one German Salesforce posting in the corpus mentioned sponsorship or relocation**, and
Mason Frank — the largest Salesforce-specialist recruiter — listed **zero** German vacancies on
22 August 2026. Practitioner phrasing advice: *"Able to relocate independently within X weeks"*
reads better than *"Open to relocation"*, which reads as a cost line.

---

## 2. The end-customer job in German energy and mobility is close to empty

Checked directly against each employer's own applicant tracking system:

| Employer | German Salesforce technical roles |
|---|---|
| RWE | **0** — 4 hits, all USA |
| Volkswagen Group | **0** — 4 hits, all Spain/Canada |
| Bosch | **0** — one internship |
| ZF · Continental · Deutsche Bahn · Elli · 1KOMMA5° · ubitricity · DHL | **0** |
| EnBW | *"Aktuell gibt es keine Jobangebote im technischen Bereich"* |
| Vattenfall · Techem | run **SAP** CRM |
| Octopus Energy Germany | 48 postings, **zero** Salesforce — runs its own **Kraken** platform |

**The work sits at consultancies.** And consultancies require negotiation-grade German 100 % of
the time.

---

## 3. Agentforce — ~4 % of postings, and the E.ON hypothesis was only half right

**Frequency, from the unbiased 1,250-posting scan:** 105 Salesforce mentions across ~48 distinct
postings, and **2 Agentforce mentions** — roughly **4 %**. In the end-customer energy/mobility
sweep: **0 of 17**. In the partner sweep: 4 of 21.

**But the split is not "build vs use AI tools" — it is "end customer vs large consultancy."**

adesso SE is running a dedicated **eight-posting "Salesforce Agentic" wave** (26 July – 20 August
2026), and it is unambiguously about *building*:

> *"Integrationsarchitekturen für **Agentic AI**"* · *"**Agentic Workflows**"* ·
> *"**Salesforce Agentic Enterprise**"* · *"**Agentforce360 und Data360**"* ·
> *"**MuleSoft AgentFabric**"*

Salesforce's own Munich FDE role is the purest build role found: *"Design and ship agentic systems
on the Agentforce platform: agent logic, tool calls, multi-agent orchestration"* — 6+ years.

Meanwhile the *use-AI-to-code* side is spreading faster and lower. Salesfive makes it a condition
of employment for ordinary developers: *"**Einsatz von KI-Tools als fester Bestandteil deiner
Arbeitsweise**"*. Statista demands both in different sections — LLM use as a **requirement**,
Agentforce itself only under **nice-to-have**.

### And "Agentforce" is now partly product-naming noise

Salesforce rebranded across Spring/Summer '26: Sales Cloud → **Agentforce Sales**, Service Cloud →
**Agentforce Service**, Data Cloud → **Data 360**, Energy & Utilities Cloud → **Agentforce Energy
& Utilities**. A 2026 posting saying "Agentforce" may mean nothing more than *"the Salesforce
platform."*

**The certification is the cheap capture.** *Agentforce Specialist* is named in exactly three
postings — but two of them list it inside a **required** cert list. It costs **$200, has no
prerequisites**, 60 questions, 73 % to pass.

*(The "20–40 % salary premium for Agentforce-trained developers" figure circulating online traces
to training-vendor marketing with no underlying data. Do not use it.)*

---

## 4. Energy & Utilities Cloud — scarce demand, not just scarce supply

**Across every dataset reachable, German postings naming E&U Cloud, OmniStudio, Vlocity or
Industries CPQ: effectively zero.**

- 0 of 21 partner postings · 0 of 17 energy/automotive postings · 0 in the 1,250-posting scan
- OmniStudio on talent.com: **0 Germany, 0 Austria, 1 Switzerland** *(and that one lists it only
  as preferred, on a Data 360 role)*. Vlocity: **0 across all three.**
- Searching `"Energy & Utilities Cloud"` in Germany returns 20 results — **none of them
  Salesforce.** They are **SAP IS-U, S/4HANA Utilities, SAP Service Cloud for Utilities** roles,
  including at adesso.

**In German utility CRM and billing, SAP owns the field.**

But partners genuinely sell the Salesforce product. **Salesfive** brands its practice "Salesforce
Agentforce Energy & Utilities" and published a Stadtwerke template with **Energieversorgung
Oberhausen** on 30 March 2026. **Eigenherd GmbH** (Berlin, founded 2017, 600+ projects) is the
purest example — a Salesforce + MuleSoft boutique for *"energy suppliers, municipal utilities and
energy-related service providers"*, whose customer testimonial is from **Stadtwerke Solingen**, the
same utility that posted the one Salesforce-plus-energy job in the corpus.

**Access is no longer the bottleneck.** A free self-serve **30-day E&U Cloud trial** exists, a free
**180-day OmniStudio-enabled Developer Edition** exists, and since exams moved to Trailhead Academy
on 21 July 2025 the **OmniStudio Developer and Consultant certs have `prerequisites: []`** at the
standard $200.

---

## 5. Domain depth in the Salesforce job family — close to invisible

This is the crux question, and the evidence is unusually clean.

Across every posting examined, **exactly one** asks for energy-industry knowledge, and softly —
Stadtwerke Solingen: *"idealerweise in der Energiebranche"*. That is a **Produktmanager** role on a
public pay scale, not a developer role.

**Zero postings name EnWG, MsbG, Eichrecht, Ladesäulenverordnung, Messstellenbetrieb,
Marktkommunikation, MaKo, EDIFACT, GPKE or MaBiS alongside Salesforce skills.**

**And the inverse is equally clean: where German employers genuinely demand that regulatory depth,
the platform is never Salesforce.**

- Octopus Energy Germany hires *"(Senior) Specialist Energy Market Communication & Balancing"* — on
  **Kraken**
- Vattenfall hires **SAP CRM Developer** and **Application Manager SAP IS-U/CRM**
- Techem hires **SAP CX / CRM** Inhouse Consultant
- adesso staffs **SAP** Utilities consultants for that work

Two structural confirmations. Salesfive's own E&U pages never mention German regulatory processes,
and describe Salesforce as integrating with *"all common billing and customer information systems
(CIS)"* — complementing rather than replacing them. **Salesforce sits on the customer-facing layer;
Energiewirtschaft regulation lives in the CIS/billing layer, which is SAP IS-U, Schleupen and
Wilken territory.**

And **Eigenherd** — the most energy-specialised Salesforce partner in Germany, whose pitch is
literally *"fundiertes Branchenwissen mit digitaler Umsetzungskompetenz"* — **teaches domain
knowledge internally** through an in-house academy rather than screening for it.

**Can a Salesforce technical interviewer evaluate Eichrecht knowledge? Almost certainly not.** It
is not in their job description, their certification path, or their postings.

---

## 6. Where the effort should actually go — ranked

### 1st — Platform engineering rigour, redirected from *more* to *legible*

It is the only one of the four a Salesforce technical interviewer **can** evaluate, and it maps
onto what is actually screened: Platform Developer I/II, Apex, LWC, testing.

**The repository already exceeds market ask.** DevOps appears in ~24 % of postings, and
**Gearset, Flosum, PMD and Salesforce Code Analyzer are named zero times. No posting states a
coverage percentage.** So the 100 %-coverage rule, the Selector pattern and the trigger-framework
discipline sit *above* what anyone asks for.

**Therefore: do not add rigour. Make the existing rigour readable in the two to five minutes a
reviewer gives it** — an architecture diagram, a short demo video, and a README section on *why*
each decision was made. Design rationale is what separates a portfolio from a code dump.

### 2nd — Agentforce: buy the certification, do not build the showcase

4 % of postings, 0 % at end customers — an elaborate agentic showcase will not generate callbacks.
But the cert appears inside **required** lists, costs $200, and has no prerequisites. adesso is
hiring six-plus people *right now* to build agentic AI and screens on that vocabulary.

**Cert plus one credible agent feature in the existing project captures nearly all the value at a
fraction of the cost.**

### 3rd — E&U Cloud: a targeted bet on five named employers, not a market play

Zero demand across ~1,300 sampled postings. It will not generate callbacks and there is no point
pretending otherwise. But it is now **free to acquire**, and it is the precise differentiator for a
short list that actually exists: **E.ON · Eigenherd · Salesfive's Stadtwerke practice ·
comselect/Assist Digital · Telekom MMS**.

**Cap it at OmniStudio Developer plus one working E&U data-model artefact.** Do not build a second
large project around it.

### 4th — German regulatory depth: stop investing, start narrating

Last for *effort*, and the distinction matters. Zero Salesforce postings screen for it; where it is
demanded the platform is SAP or Kraken; and the most energy-specialised Salesforce partner in the
country trains it in-house rather than hiring for it. **Additional regulatory depth has close to
zero screening return.**

**But what already exists is not wasted.** It makes the premise credible rather than toy-shaped,
and it is a genuine advantage in a final-round conversation with a Stadtwerke stakeholder or with
Eigenherd, whose entire market position is *"Branchenwissen plus Salesforce."*

**Express it as one page of README framing and two sentences in a cover letter. Not as more
engineering.**

---

## 7. Two targets the data surfaced

**Eigenherd GmbH** (Berlin) — a Salesforce + MuleSoft boutique for utilities and grid operators,
**currently hiring a Salesforce Architect**, implemented Stadtwerke Solingen, and **trains domain
knowledge internally**. The single best structural fit found in the entire sweep: it is the one
employer whose market position rewards exactly the combination this project represents.

**JobRad** (Freiburg) — the only technical Salesforce posting in Germany accepting **B2 German**,
and mobility-sector. The softest language bar in the corpus.

---

## 8. Numbers worth keeping

| Cut | Figure |
|---|---|
| Salesforce Consultant, median (gehalt.de) | **€71,315** — p25 €63,359 / p75 €80,272 |
| By experience | <3y €60,311 · 3–6y €63,226 · 7–9y €67,158 · **>9y €80,614** |
| By employer size | <100 €66,066 · 101–1,000 €71,299 · 1,001–20,000 €75,016 · **>20,000 €79,507** |
| Top Bundesländer | BW €74,675 · Hessen €74,167 · Hamburg €73,485 · Bayern €72,872 |
| Architect band, published | **€65,000–100,000** (mindsquare, all three architect postings) |
| Senior SWE Germany, total comp (levels.fyi) | **€93,406** median · p75 €114k · p90 €139k |
| Municipal utility | **TV-V EG11** + 13th month |

**Working target for a senior: €75,000–95,000 base**, +€10–15k for Munich/Frankfurt/Stuttgart or a
>20,000-employee employer, −€5–10k for Berlin — offset by far better language and visa odds.

**The real money break is at architect, not senior:** €67,158 at 7–9 years jumps to €80,614 at 9+,
a step larger than every earlier one combined.

**Seniority band:** 8+ years (auxmoney) · 6+ (Salesforce FDE senior) · 5+ (Statista, DIA,
mindsquare) · 3+ (scale-ups). So **5–8 years** is the German senior band.

**Certifications named, by frequency:** Platform Developer I (6) · Platform Developer II (4) ·
Application/System Architect (4) · Administrator (3) · **Agentforce Specialist (3)** · Integration
and IAM Architect (1 each). **Named zero times: JavaScript Developer I, Data Cloud Consultant,
Energy & Utilities Cloud Accredited Professional.**

*Timing caveat: the Hays IT Fachkräfte-Index fell 37 points to 59 % in Q2/2026 after peaking at
96 % in Q1. Salesforce is not named as a shortage specialism.*

---

## 9. The uncomfortable asymmetry, stated plainly

**Not one German Salesforce posting in this corpus asked for a portfolio, a GitHub link, or a code
sample. Certifications were asked for repeatedly.**

That asymmetry is informative about the **screening** stage — and it is the reason §6 ranks
legibility above depth. Portfolios help at the **interview** stage, not the screening stage.

The strongest evidence in the portfolio's favour is a hiring manager's own words, and read
carefully they are not a rejection:

> *"[My questions] involve the project that you are currently working on. This tells me more about
> your abilities and understanding than a portfolio ever could."*

He is not saying built work is worthless. He is saying that **narrating a real project fluently
under questioning** beats a static artifact. That is an argument for being able to defend every
architectural decision in this repository out loud, in one sentence, without notes.

And the one genuine convergence in the German-language evidence — **Capgemini** (employer,
31 Oct 2023) and **Jobriver** (14 Jan 2025), independently — points at exactly this project's
shape:

> *"Verlinke **maximal zwei bis drei repräsentative Repositories** … Es ist sinnvoller, **wenige,
> dafür aber sorgfältig gepflegte Repositories** einzubringen, statt eine Vielzahl halbfertiger
> Projekte."*

**Two to three curated, deeply documented repositories.** Which is what this is.

---

## 10. The channel — and a field already deployed that has to change

Twelve German charging manufacturers and CPOs were checked directly against their own partner
pages. The result contradicts a field that is **already in this org**.

### 10.1 🔴 `Partner_Tier__c` is invented, and a German reviewer will ask

`Reseller__c.Partner_Tier__c` currently carries **Bronze / Silber / Gold / Platin**.

**Not one of the twelve vendors publishes a ranked commercial tier ladder.** What they actually
publish:

| Vendor | Programme | Structure |
|---|---|---|
| **MENNEKES** | *MENNEKES Qualitätspartner für eMobility* | **No ladder.** Split by focus: *Fokus Privatkunden* / *Fokus Gewerbekunden* |
| **KEBA** | *eMobility Partnernetzwerk* | Six **types**, no ranks — Elektroinstallateure / Händler / System-Anbieter / EVU & Stadtwerke / Betreiber / Planer |
| **KOSTAL** | *zertifizierter Installateur* + *KOSTAL Fachpartner* | No levels. Explicitly **no minimum volumes, no entry fee** |
| **Compleo** (KOSTAL) | *Rahmenvertragspartner* / *Fachpartner* | Two contract types |
| **Elli** (VW Group) | Reseller channel | Categories **Reseller/Fachhandel** and **Installateur**; optional *zertifizierter Partner* |
| **go-e** | *Wiederverkäufer werden* | **None** — individual vetting: *"nur nach positiver individueller Prüfung"* |
| **ABB E-mobility** | Channel Partner Program | Foundation / Intermediate / Advanced — but these are **service certification levels, not partner tiers** |
| **ABL** | none | Installers order *"direkt im Onlineshop ihres Elektrogroßhandels"* |
| **Alfen · Vestel · Alpitronic** | **none at all** | Training only, or direct sales to CPOs |

Even **SMA**, a major German manufacturer in the adjacent PV trade, publishes no levels —
participation is tied to *"einem Qualifizierungsprozess und der Erfüllung von Partner-Kriterien."*

**If a German reviewer sees Bronze/Silber/Gold, they will ask which manufacturer does that.**
There is no answer.

**What is defensible instead, all evidenced:**

| Replace with | Evidence |
|---|---|
| **Certification status** — certified / not | Universal across all programmes |
| **Certification expiry** | **KEBA states it explicitly**: *"Teilnahmezertifikat (Gültigkeit **2 Jahre**)"*, with listing as a Partnerbetrieb *"für die Dauer der Zertifikatsgültigkeit"* |
| **Partner type** — Reseller · Installateur · Großhandel · Stadtwerk | Elli's two application paths; KEBA's six types |
| **A points balance** | **MENNEKES Prämienprogramm and E-Marken-Punkte are real** — seminars award 4 or 8 Punkte |

**And margins being absent from the model is realistic, not a gap.** Not one of the twelve
publishes a Rabattstaffel, Handelsspanne or volume threshold. The only directional statements are
Elli's *"lukrative Margen, keine Mindestbestellmengen"* and go-e's *"günstige
Einkaufskonditionen"* set by individual negotiation. **Any percentage seen elsewhere is
unsourced.**

### 10.2 🔴 Selling and installing are different legal roles — and the model must express both

**§ 13 NAV** means only a company entered in a Netzbetreiber's Installateurverzeichnis may do the
work. **Every serious programme in this market models that split:**

- **Elli** has literally separate *"Reseller/Fachhandel"* and *"Installateur"* application paths
- **Mercedes-Benz**: the **dealer sells** (22 kW wallbox, UVP €990), a **national Installationspartner installs**
- **BMW/MINI**: the **dealer refers**, and **E.ON does** *"alle Installationsarbeiten und die Inbetriebnahme"* — from €1,769
- **MENNEKES** runs a consumer webshop whose installations are fulfilled by the partner network

**A partner record that cannot express "sells but does not install" mis-models most of the
market.** `Reseller__c` needs two independent capability flags, not one type.

### 10.3 🔴 The Elektrogroßhandel is missing from the model entirely

`Reseller_Type__c` has eight values and **none of them is the wholesaler** — yet the wholesaler is
where installers actually buy. This is the German electrical trade's own named institution, the
**dreistufiger Vertriebsweg**: Hersteller → Elektrogroßhandel → Elektrohandwerk → Endkunde.

- **ABL** routes installers to *"direkte Bestellung im **Onlineshop ihres Elektrogroßhandels**"*
- **Hensel** does the same
- **GC-Gruppe**: *"Konsequent dem dreistufigen Vertriebsweg verpflichtet steht der professionelle
  Fachhandwerker als **ausschließlicher Kunde** im Zentrum"* — ~300 Vertriebspunkte, 850+ Abhol-Express
- **Compleo tried direct and retreated** — it *"mit dem Direktvertrieb schlechte Erfahrungen
  gemacht hatte"*, and the correction included *"die Stärkung des dreistufigen Vertriebs"*
- Demand-side proof: in a survey of **126 German Elektroinstallationsbetriebe**, the stationary
  Elektrogroßhandel is *"der wichtigste Einkaufskanal"* — and on a stockout **three quarters go to
  another wholesaler**, not online

**And the layer above the wholesalers is who a supplier actually negotiates with:**

| Cooperative | Scale |
|---|---|
| **VEG** (the sector body) | 58 members · 826 Standorte · 24,100 staff · ~€13 bn |
| **MITEGRO** | 8 wholesalers · ~250 Standorte · **€1.4 bn Einkaufsvolumen** · a dedicated **E-Mobilität** department |
| **FEGIME Deutschland** | 45 family-owned members · ~160 Verkaufspunkte · **€1.5 bn** |

**reev models this correctly and publicly** — its partner categories are Hardwarehersteller /
Lösungsanbieter / **Großhandel**, with *Elektrofachkräfte* as a separate audience rather than a
partner category.

### 10.4 Two corrections to the demo's premise

**Charging is ~1 % of the Elektrogroßhandel assortment** — growing +43.8 % year on year, but on a
tiny base. Kabel & Leitungen is 22 %. A story implying wholesalers are getting rich on wallboxes
overstates it; the credible version is the one they tell about themselves — *"vom
Logistikdienstleister zum Systempartner."*

**And the trade is contracting, not booming.** E-Handwerk revenue fell ~4 % in 2024, and ZVEH
reported skilled-worker demand falling **again in January 2026**. A narrative of installers
desperate for wallbox work is about two years out of date.

### 10.5 Stadtwerke are customer and competitor in the same record — and they are AC, not DC

The **Bundeskartellamt Sektoruntersuchung Ladeinfrastruktur (B8-28/20, October 2024)** is the
sharpest data available:

| | Municipally-controlled share of public charge points |
|---|---|
| Normalladepunkte (≤ 22 kW) | **~42 %** |
| Schnellladepunkte (> 22 kW) | ~19 % |
| **> 150 kW** | **~0.6 %** |

**A supplier pitching HPC to Stadtwerke as its core motion is fighting the data.** And 40 % of
surveyed CPOs reported problems entering a market dominated by the local Stadtwerk, because
*"viele Gebietskörperschaften geeignete öffentliche Flächen **exklusiv oder bevorzugt an das eigene
kommunale Stadtwerk** vergeben."*

Addressable count: **~760 electricity-active VKU members** *(the widely quoted "~900 Stadtwerke"
could not be verified from any primary source)*. And they buy backend software **collectively** —
smartlab/ladenetz.de serves *"über 270 Energieversorger"* with 21,700 charge points, and Thüga's
Regioladen+ exists explicitly to reduce the number of backends.

### 10.6 The regulator-granted qualification the model does not have

Manufacturer certification is not the binding one. **§ 54 MessEV** creates an
**Instandsetzerberechtigung** — the authority grants a business the right to mark repaired
measuring instruments, and **re-checks it *"spätestens alle fünf Jahre."***

MENNEKES states the consequence plainly: *"**Nur nach erfolgreicher Befugniserteilung durch die
zuständige Behörde dürfen Reparaturen an eichpflichtigen Geräten vorgenommen werden.**"*

So a partner may hold every manufacturer certificate and still be **legally unable to repair a
billing-relevant charge point.** That is a separate field with its own five-year clock, and it
belongs next to the Installateurverzeichnis entry.

### 10.7 🟢 And the gap the whole project rests on is real

**No commercial product manages compliance obligations for German charging operators.** The
closest counter-candidate is **AMPECO CoOperator** — *"Your embedded AI expert that understands
your network, acts on your behalf"*, doing platform Q&A, root-cause analysis on failed sessions,
and operational actions like changing tariffs and creating charge points.

**Its documentation mentions no Eichrecht, no AFIR, no regulatory deadlines.** It is an
**operations** agent, not a **compliance** agent.

Every vendor checked treats compliance as a **product attribute** — *"our charger is
eichrechtskonform"*, *"we support AFIR"* — rather than as **an obligation portfolio tracked over
time**. The only tool that even attempts the span disclaims itself: emobicon's free
Ladeinfrastruktur-Assistent names AFIR, LSV, Eichrecht, GEIG, WEG and EPBD, then states it gives
*"initial guidance — no legally binding planning"* and assumes no liability.

> **Nobody sells the calendar.**

### 10.8 One more dated obligation, and it lands on the dealer's own forecourt

**GEIG § 10:** an existing Nichtwohngebäude *"das über mehr als **20 Stellplätze** verfügt"* must
have had a charge point since **1 January 2025**. The **GEIG-Novelle passed both chambers and is in
force 1 July 2026** — and from **1 January 2027**, existing non-residential buildings above 20
spaces need **one charge point per ten spaces**, or 50 % Leitungsinfrastruktur. Enforcement:
Bauaufsichtsbehörden may fine **up to €10,000**.

A typical Autohaus with more than twenty customer, demo and stock spaces is squarely inside it.
**That is a more concrete procurement driver than any OEM dealer standard** — and no OEM standard
mandating charging-hardware sales could be verified at all.

### 10.9 A trap that would date the project instantly

*"Eichrecht becomes mandatory in 2026"* circulates in German-language press. **It is Austrian.**
In Germany, kWh-based eichrechtskonforme billing has been the rule since **2017/2019**. Repeating
the 2026 framing would be caught by any German reviewer in one search.

---

## 11. The decisive test case — and it settles §5

§5 argued that domain depth is close to invisible in the Salesforce job family. A follow-up pass
found the test that settles it, and the answer is cleaner than expected.

### 11.1 An energy-only Salesforce partner does not ask for energy knowledge

**Eigenherd GmbH** describes itself as *"Ihr spezialisierter Technologieexperte für die
**Digitalisierung der Energiewirtschaft**"* and does nothing but Salesforce for utilities. If deep
German energy-domain knowledge were a hiring signal anywhere, it would be here.

All four of its open roles were read. **Salesforce Architect (m/w/d)** — the complete requirement
list:

> *"mind. 5 Jahre Erfahrung in der Salesforce-Konfiguration und Implementierung von CRM-Systemen"*
> *"umfassende Kenntnisse in den Salesforce Core Clouds, **idealerweise** auch in einer der
> folgenden Cloud: **Energy & Utilities Cloud**, Media & Communications, Financial Services oder
> Healthcare & Life Sciences"*
> *"technische Salesforce Zertifizierungen"* · *"ausgezeichnete Kommunikationsfähigkeiten in
> **Deutsch und Englisch**"*

**Read the second line carefully.** The single energy item is a **Salesforce SKU**, listed as
*idealerweise*, and **ranked interchangeably with Financial Services Cloud.** Not EnWG. Not MsbG.
Not MaKo.

Its Junior Developer posting mentions energy only as *context* in the Aufgaben — never as a
requirement. Its Junior Consultant posting has **zero** energy content.

**And E.ON says the same thing.** Its *Salesforce System Engineer – AI based* posting mentions
energy exactly once, as the object rather than the requirement: *"Die End-to-End Weiterentwicklung
unserer **Salesforce Energy & Utilities Cloud**."* A German utility, building on the E&U Cloud,
asks for **no energy domain knowledge whatsoever.**

### 11.2 The split is by job family, not by employer industry

| Job family | Energy domain required? |
|---|---|
| **Salesforce-titled roles** (Eigenherd ×3, E.ON, entero ×2, adesso) | **~7 of 8: no** |
| **SAP / EDM-titled roles** (arvato, EWE, Hays) | **3 of 3: yes** — GPKE, MaBiS, WiM, SAP IS-U, intelligente Messsysteme |

The one posting pairing Salesforce *with* deep energy knowledge is titled **"EDM Experte
Energiewirtschaft"** — a domain-analyst role, freelance, that happens to touch Salesforce. The job
title is the tell.

**And the searches returned literal zeroes:**

> `"Salesforce" Stellenangebot "MsbG" OR "EnWG" OR "Ladesäulenverordnung"` → **No results found**
> `"Marktkommunikation" "Salesforce" Stellenanzeige Entwickler CRM` → **No results found**
> `"Salesforce" Consultant "Erfahrung in der Energiewirtschaft"` → **No results found**

**Not one German posting pairs Salesforce with any of the statutes this project models.**

### 11.3 Eichrecht as a hiring keyword: zero

**kimeta.de**, a major German aggregator, verbatim: *"Ihre Suche nach Stellenanzeigen zu
**Eichrecht** ergab **keine passenden Ergebnisse**."*

Where it does appear in postings, it is not software:

- **Eichdirektion Nord — Prüfer/in (m/w/d)**: *"Kenntnisse im Eichrecht. Marktüberwachung."* — a
  state calibration inspector.
- **KPS-Gruppe — Servicetechniker (M/W/D) – Quereinsteiger**: *"Sicherstellung der
  **Eichrechtskonformität**"* — a field technician role **explicitly open to career changers**.

Eichrecht is a genuine, complex, high-volume regulatory topic with BDEW position papers, PTB
documents, a Nationale Leitstelle Orientierungshilfe and a paid *Eichrecht Academy*. **It is simply
not a recruitment keyword.**

### 11.4 But the scarcity utilities complain about is real — it is just in the other stack

**ZfK, 7 November 2025**, quoting Stadtwerke München:

> *"Der Fachkräftemangel ist deutlich spürbar, vor allem bei spezialisierten IT-Fachkräften, **die
> technisches Know-how und Branchenwissen verbinden**."*

And Marena-Nathalie Ostermann of Factur, in the same piece:

> *"**SAP** können viele, aber die **Prozesse der Energiebranche versteht kaum jemand auf
> Anhieb**."*

**Read the second quote: it says SAP.** Every practitioner statement found about scarce
energy-domain IT skill points at the SAP IS-U / EDM / Marktkommunikation stack. The scarcity is
real and it is priced — into a different job family.

### 11.5 What a Salesforce-in-energy practitioner actually talks about

Telekom MMS, on LinkedIn, marketing exactly this work:

> *"Ob PV-Anlage auf dem Hallendach, **Ladeinfrastruktur auf dem Werksgelände** oder
> Mieterstrommodell im Neubauquartier … Angebote dauern zu lang ❌ Daten sind verteilt ❌ Abrechnung
> ist manuell"*

**Process vocabulary — not one regulatory citation.** Salesfive's own Energiewirtschaft page says
only *"regulatorische Anforderungen"* generically; its Stadtwerke template, built with
Energieversorgung Oberhausen, scopes to *"typische Serviceprozesse und Kundenanliegen."*

**This is the crux, stated plainly: the Salesforce layer in German utilities sits on the
customer-experience side. The regulated metering and market-communication layer lives in SAP IS-U,
Robotron and Schleupen.** The regulatory work maps to the stack this project is not applying to.

### 11.6 So the conclusion of §6 stands, and gets one concrete substitute

The domain investment is **narrative, not screening**. The ZfK quote proves utilities feel the
scarcity of people who *"technisches Know-how und Branchenwissen verbinden"* — so a portfolio that
speaks fluently about Ladeinfrastruktur, tariff and billing processes will differentiate **in
conversation**. No keyword filter, and on this evidence no interviewer, is looking for Eichrecht.

**And there is now a named, actionable substitute for further statute reading:**
**Salesforce Energy & Utilities Cloud as a credential.** It is the one energy-flavoured thing the
energy-only Salesforce partner actually asks for — and it is free to acquire.

*(Correction to an earlier note in this file: **entero AG is not an energy consultancy.** Its own
industries page lists Manufacturing, Professional Services, Personaldienstleister and Analytics —
energy appears nowhere. Its German-language requirement is still evidence for §1; it is not
evidence about energy hiring.)*

---

## 12. The partner model, from twelve vendors' own pages

A dedicated pass read the partner programmes directly. It confirms §10.1 and gives the replacement
its exact shape.

### 12.1 Only two vendors publish a named partner status at all

| Vendor | Named status | Levels? |
|---|---|---|
| **MENNEKES** | *MENNEKES Qualitätspartner für eMobility* (**MQPeM**) | **No.** Two *specialisations*: private-installation focus vs commercial focus |
| **Zaptec** | *Certified Zaptec Partner*, plus a loyalty layer *Club Zaptec* | **No.** A single partnership level |
| go-e | *"Wiederverkäufer\*in"* / *"Fachhändler\*in"* | none |
| Wallbox Chargers | segmented **by type**: Betreiber · Vertriebspartner · Installateure · Autohändler · Wiederverkäufer | none |
| Elli | *Elli Vertriebspartner* — Reseller/Fachhandel vs Installateur | none |
| ABL | *"Zusammenschluss aus zertifizierten eMobility Fachbetrieben"* | none |
| Easee | *Easee Champions* — **points**, not tiers | none |
| Amperfied · EnBW · Juice | no published programme | — |

**The real German pattern is one partner status gated by mandatory product training, plus
individually negotiated purchase conditions.** A Bronze/Silber/Gold ladder is not a simplification
of that — it is a different thing that does not exist here.

### 12.2 What vendors publish instead of a discount ladder — adjectives

**No vendor in the sample publishes a Rabattstaffel, a Fachpartner-Preisliste, or any percentage.**

> Elli: *"attraktive Einkaufskonditionen und steigern Sie Ihren Umsatz durch **lukrative Margen**"* · *"**Keine Mindestbestellmengen**"*
> go-e: *"**günstige Einkaufskonditionen**"*
> Zaptec: *"Get a **quantity discount** on all orders"*
> MENNEKES: a points-based rewards programme, plus a calibration discount on measuring devices

**The one real trade pricing document found proves the structure.** ABL's *"LISTENPREISE EMOBILITY
… STAND MAI 2026"* has a column headed **"LISTENPREIS NETTO"** and states *"Sämtliche genannten
Preise … verstehen sich ohne Mehrwertsteuer."* **Netto here means ex-VAT list, not a dealer buy
price** — and a full-text search of the document finds **no occurrence of "Rabatt", "UVP" or
"empfohlen"** anywhere.

**So: list prices are published, discounts are not.** Model a **per-account negotiated discount**,
never a tier-derived one.

### 12.3 Certification is the real axis — and it has cost, points, and a refresh cycle

This is what should replace the tier field, and every element is evidenced:

| Element | Evidence |
|---|---|
| **Gated entry** | MENNEKES: *"Die Aufnahme … ist **ausschließlich Fachbetrieben des Elektrohandwerks** vorbehalten"*, subject to *"Schulungs- und Zertifizierungsanforderungen"* |
| **Approval as a workflow, not a flag** | go-e: individual review, **1–2 working days**, activation e-mail, **no ordering before approval** |
| **A refresh obligation** | ABL: partners must *"**regelmäßig** ABL Produktschulungen absolvieren"* · SENEC: *"**verpflichtende** Zertifizierungsschulung"* before a partner may sell or install |
| **An expiry date** | KEBA: *"Teilnahmezertifikat (**Gültigkeit 2 Jahre**)"*, with partner listing *"für die Dauer der Zertifikatsgültigkeit"* |
| **Priced training** | **ABL: €249 netto** webinar, **€479 netto** in person (~7 h), *"zertifiziert durch den **ZVEH**"*, worth **7 E-Akademie-Punkte** |
| **Points with an awarding body** | MENNEKES courses carry **4 and 8 E-Marken-Partner-Punkte**; Easee Champions awards **1 point per installed and commissioned unit** |
| **A public listing as the benefit** | MENNEKES, go-e, ABL (*Elektrikerfinder*), Zaptec (*"Secure a spot on our dealer map"*) all publish a partner locator |

**A training-record object with cost, points and awarding body is defensible German-market
modelling.** A tier picklist is not.

### 12.4 Two-step distribution, named

- **go-e**: direct webshop **or** *"Großhandelspartner"*
- **ABL**: installers order *"direkt im Onlineshop ihres **Elektrogroßhandels**"*
- **Elli**: stationary distribution runs through **Volkswagen Original Teile Logistik (OTLG)** into
  VW, Seat, Cupra, Škoda and Audi dealers. *Connect* and *Pro* go through the dealer channel;
  *Standard* stays online-only.

**Partner records need a supplying-distributor relationship**, not only a direct link to the
manufacturer.

### 12.5 The money is in the installation, not the box

ADAC, **29 June 2026** — the cleanest published breakdown:

| | Range |
|---|---|
| Wallbox hardware | **€300 – 2,000** *(simple 300–600 · mid 600–1,000 · premium 1,000–2,000 · bidirectional 2,000–3,000)* |
| Installation, single-family home | **€500 – 3,000+** *(low 500–800 · medium 800–1,500 · high 1,500–3,000+)* |
| **All-in** | *"grob mit **1.200 bis 3.500 Euro** rechnen"* |

EnBW puts average installation at *"**1.500 €** (500 € bis 2.500 €)"*. And in multi-party
buildings, ADAC found costs varying *"um bis zu **82 Prozent** je vorbereitetem Stellplatz."*

**At the midpoints the hardware is roughly a third of the installed ticket.** A channel CRM for this
market should treat **the installation quote, not the box, as the revenue-bearing object** — which
also happens to be the half that requires the Installateurverzeichnis entry.

### 12.6 Real price anchors for demo data

From the **ABL Listenpreise, Stand Mai 2026** — net list, Germany. These are real numbers from a
real trade price list, which is worth more than plausible invention:

| Product | Net list |
|---|---|
| ABL Pulsar 11 kW · 22 kW | €707 · €770 |
| eMH1 mit Ladekabel 11 kW · 22 kW | €403 · €456 |
| eM4 Single Controller 22 kW | €1,418 – €1,663 |
| eM4 Twin Controller | €2,969 – €3,808 |
| Ladesäule eMC2 · eMC3 | €6,566 – €6,832 · €7,877 – €10,028 |
| ABL Payment Terminal | €3,236 |

*(Caveat from the source: extracted from a multi-column PDF where two extraction modes disagreed on
row alignment — treat individual name↔price pairings as indicative.)*

Cross-checks from other vendors' own pages: **Elli** Connect 11 from €759, Connect 22 from €839,
Pro 22 from €1,099, **Pro 22 eichrechtskonform from €1,499**. **MENNEKES** Amtron 4You 500 €1,096,
**+€219 for Dienstwagenabrechnung**, **+€73 for 22 kW**.

**That Eichrecht surcharge — €1,099 → €1,499, a 36 % premium — is the single most useful price fact
for this project**, because it puts a number on the compliance decision the agent exists to advise.

### 12.7 One structural correction

**ABL is now a Wallbox Chargers company.** ABL filed for insolvency 27 June 2023, proceedings opened
at Amtsgericht Nürnberg 29 August, and **Wallbox Chargers acquired it 18 October 2023**. The May
2026 price list is filenamed `ABLxWallbox_…` and signed by **Enric Asunción Escorsa**, Wallbox NV's
CEO. So "ABL" and "Wallbox Chargers" are not two independent German suppliers — treating them as
such in a catalogue would be a visible error.

### 12.8 The subsidy that sets the 2026 price ceiling

The **€500 m Mehrparteienhaus programme**, applications from **15 April 2026**:

> up to **€1,300 per Stellplatz** for preparation · max **€1,500** for installing a wallbox · up to
> **€2,000** where the point supports **bidirectional charging**

Eligible costs cover *"die Anschaffung von Wallboxen, … die technische Ausrüstung, den
**Netzanschluss** sowie notwendige Baumaßnahmen."* Applicants: WEGs, KMU and private landlords.

**Installers quote into that ceiling**, which is why the funding-window field is a sales artefact
and not merely compliance decoration.

---

## 13. Who actually sells Salesforce into German utilities — thirty companies checked

The §6 recommendation put Energy & Utilities Cloud third, as *"a targeted bet on five named
employers."* A sweep of thirty German consultancies, system integrators and energy-IT specialists
narrows that list and explains why.

### 13.1 Two companies. Out of thirty.

| | Claim |
|---|---|
| **Salesfive** | The only **productised** offer. A dedicated E&U cloud page, a German industry page, and a **Stadtwerke template co-developed with Energieversorgung Oberhausen** built *"auf Basis von **Salesforce Agentforce Energy & Utilities**"*, with a named practice lead and a live customer-portal reference. |
| **Telekom MMS** | Genuine, less productised. Names *"Salesforce Energy & Utilities Cloud"* with substantive product copy on **both** its Salesforce partner page and its energy industry page — *"zugeschnitten auf Energieversorger, Netzbetreiber und -händler."* |

**Three more name the technology without selling a practice:** comselect has excellent
Vlocity/OmniStudio/E&U explainers from 2022–23, but they are SEO knowledge content with no industry
page behind them. NTT Data and IBM claim *"Salesforce Industries"* and *"alle 19 Salesforce
Industry Clouds"* generically, and **neither connects it to energy on their German pages.**

### 13.2 🔴 The German energy-IT sector is a Salesforce-free zone

All ten energy-IT specialists were checked sitewide — URL paths, homepages, partner pages:

**Arvato Systems · Schleupen · SOPTIM · KISTERS · robotron · PSI · BTC AG · Wilken · SIV** —
**zero Salesforce mentions. Every one.**

The incumbent stack for a German Stadtwerk is **Schleupen CS, SAP IS-U / S/4HANA Utilities, CURSOR,
SIV, Wilken, powercloud.**

> **Any Energy & Utilities Cloud project in Germany is a *displacement* play against those systems,
> not a greenfield build.**

That single sentence reframes the product. It also explains §5: the regulatory logic lives in the
system being displaced *from*, not the one being displaced *to*.

### 13.3 And where the big integrators have German utilities practices, they are SAP-led

| | Evidence |
|---|---|
| **Accenture DE** | The German utilities page names SAP, Oracle, Microsoft/Avanade, AWS — **and no Salesforce** |
| **valantic** | Utilities page: **109 SAP mentions, 0 Salesforce.** Its Salesforce practice lists nine clouds — including Media Cloud, an Industries product — but **no E&U Cloud** |
| **Capgemini DE** | Salesforce partner page: 38 Salesforce mentions, **0 Vlocity / OmniStudio / Industry Cloud.** The energy-retail-CX page mentions no Salesforce at all |
| **cbs** | Deep SAP S/4HANA for Utilities practice; its Salesforce page has **zero** energy content. The two practices are unconnected |

**At nearly every large system integrator, the Salesforce practice and the energy practice sit in
different silos.**

**The most interesting near-miss is adesso** — a deep German energy practice *(Amprion, E.ON, EnBW,
BS Energy, enervie)*, a strong Salesforce practice, and a real energy-supplier reference in
**eprimo**. But eprimo is delivered on **Service Cloud**, not E&U Cloud, and adesso's energy stack
is Schleupen CS, CURSOR and SAP BTP.

### 13.4 The mid-market is being absorbed

**parsionate.com and cloudconsultinggroup.de now both 301-redirect to accenture.com.** Two of the
German Salesforce mid-market names on the original target list no longer exist independently.

### 13.5 What this does to the §6 ranking

**It does not change the order. It shortens the list and sharpens the reason.**

The E&U Cloud bet was *"a targeted bet on five named employers."* The evidence now says the list of
companies that actually sell this product in Germany is **Salesfive, Telekom MMS, and Eigenherd**
— the last of which asks for the cloud as *"idealerweise"* on its Architect role.

**Three employers is not a market. But it is a precise, verified, addressable list** — and the
credential to reach it costs $200 and a free trial org. That ratio is still worth taking.

**What it removes is any temptation to build a second large project around it.** In a market where
the incumbent is Schleupen and SAP, a portfolio E&U Cloud artefact demonstrates a credential, not a
practice. One working data-model artefact, and stop.

---

## 14. Two utilities. In all of DACH.

The final sweep looked for actual customers rather than vendor claims. It is the sharpest number in
this document.

### 14.1 The complete public list of DACH utilities on Energy & Utilities Cloud

| Utility | Product, precisely | Partner | Date |
|---|---|---|---|
| **SachsenEnergie AG** — 4th-largest municipal energy provider in Germany | **E&U Cloud** — *"mittels Salesforce Energy & Utilities Cloud Branchentemplates"*, multi-org for regulatory client separation, 17 system integrations | **Telekom MMS** | ongoing |
| **Energieversorgung Oberhausen (evo)** | **E&U Cloud + OmniStudio + Experience Cloud + Service Cloud**, MuleSoft → SAP IS-U real-time sync, built with scratch orgs. Portal live **Dec 2024**. Won Salesforce's 2025 *"most innovative energy project"* | **Salesfive** | Jan–Mar 2026 |

**That is the entire list.**

Everything else in DACH is generic Salesforce. **EKZ** (CH) — Sales + Service Cloud. **IWB** (CH) —
Service → Marketing → Sales + CPQ. **SOLARWATT** — Sales, Service, Commerce. **Enpal** — Sales +
Service. All four publish explicit product lists, and **none includes the industry cloud.**

**And E.ON's May 2026 announcement is not E&U Cloud either** — it is **Data 360 + Agentforce for
Sales, Service and Marketing**. Worth correcting wherever this repo implies otherwise.

### 14.2 The most quotable single fact in this whole research round

**ZfK — the Zeitung für kommunale Wirtschaft, the VKU's own outlet — has 35,557 indexed articles
from May 2014 to August 2026. Exactly one mentions Salesforce.** And it is a vendor partnership
announcement, not a utility implementation.

The German utility CRM conversation is **SAP, CURSOR, Schleupen, BSI, Lime and Microsoft Dynamics.**

### 14.3 Salesforce Germany cannot show a DACH utility reference

Every customer logo on **salesforce.com/de/energy-utilities/** is non-DACH — ENGIE (FR), Centrica
(UK), Sunnova (US), Veolia (FR), GE Renewable Energy, Reconomy (UK). Of 124 customer stories on the
German site, three are energy-adjacent: **two Swiss and one solar manufacturer, none on the industry
cloud.**

That is a statement about market penetration, not about marketing effort.

### 14.4 The incumbents evaluated Salesforce and chose otherwise

| Utility | Chose |
|---|---|
| **EnBW** — the obvious flagship prospect | **CURSOR Software** (general contractor, 2021) and later **BSI Software** for AI-driven service |
| **Wien Energie** | **Microsoft Dynamics 365** via Avanade |
| **Stadtwerke Düsseldorf** · **Stadtwerke Bielefeld** | SAP Service Cloud / SAP Sales & Service Cloud |
| **1KOMMA5°** | Zoho |

**And Stadtwerke Ingolstadt's own published report says it out loud:** Salesforce *"ist von Haus aus
**nicht auf die Prozesse der deutschen Energie- und Wasserwirtschaft zugeschnitten**"* — so they
built a custom bidirectional **Schleupen.CS** interface instead.

That sentence, from a utility that chose Salesforce anyway, is the clearest possible statement of
§13.2's displacement problem.

### 14.5 🟢 But one finding cuts the other way, and it is worth having

> **"OmniStudio" appears exactly once in all public DACH utility material** — the evo case study.
> **"Vlocity" appears zero times** across ZfK's entire twelve-year archive.

**OmniStudio is a differentiator in this market precisely because almost nobody publicly claims
it.** Two prerequisite-free $200 certifications and a free 180-day org stand between here and a
credential that ~everyone in German utility Salesforce lacks.

Combined with §13.1, the addressable list is small but exact: **Salesfive · Telekom MMS ·
Eigenherd.** Three employers, all verified, all currently selling or hiring for this.

### 14.6 And the timing is unusually good

Both signals are months old. **E.ON's Agentforce announcement is 20 May 2026.** **Salesfive's
Stadtwerke-Template launched January–March 2026**, pitched at E-world as *"vom Stadtwerk für
Stadtwerke"* with go-live *"within a few weeks"* — an explicit land-grab for the ~760
electricity-active municipal utilities that have so far bought SAP or CURSOR.

**If a German Salesforce-in-energy hiring wave happens, it starts here, and it started this year.**

Note also where Salesforce's DACH energy wins actually cluster: **new-energy companies rather than
incumbents** — Enpal, SOLARWATT, 1KOMMA5°. The buying pattern looks like B2C tech scale-ups, not
regulated utilities. Which is also where §1 found the English-sufficient jobs.
