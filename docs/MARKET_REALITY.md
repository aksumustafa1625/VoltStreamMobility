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
