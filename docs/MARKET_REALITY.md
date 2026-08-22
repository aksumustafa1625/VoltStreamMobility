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
