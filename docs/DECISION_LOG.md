# Karar Defteri — Agent Tasarımı

Kardeş modellerden gelen her öneri buraya girer, bir statü alır, ve statüsü değişirse
tarihiyle birlikte kaydedilir. Amaç: aynı tartışmayı iki kez yapmamak.

**Kaynak dosya:** [AGENT_DESIGN_FOR_REVIEW.md](AGENT_DESIGN_FOR_REVIEW.md)

## Statüler

| | Anlamı |
|---|---|
| ✅ **KABUL** | Uygulanacak. |
| ❌ **RED** | Uygulanmayacak, gerekçesiyle. |
| ⚔️ **ÇELİŞKİ** | Hakemler aynı fikirde değil. Üçüncü görüş bekliyor. |
| 🔬 **DOĞRULA** | Ampirik doğrulama olmadan karar verilemez. |
| ⏸️ **ERTELE** | Doğru fikir, v1 değil. |
| 👤 **SENİN** | Stratejik karar. Mustafa verecek. |

## Hakemler

| Kod | Tarih | Karakteri |
|---|---|---|
| **R1** | 2026-08-22 | Sert, kapsam kesmede acımasız. Bir gerçek kod hatası buldu. |
| **R2** | 2026-08-22 | Daha dengeli, çalışan kod verdi, R1'i dokuz noktada çürüttü. |

---

# ⚠️ ÖNCE BU: R2'nin kritik düzeltmesi

### P-00 · "Sandbox-only" muhtemelen bir kısıt değil, bir tavsiye

> **R2:** *"Official docs list Testing Center as **available in Developer Edition**, but repeatedly state 'use Testing Center only in your sandbox environment' **because** tests can modify data and consume credits."*

Bu, tüm planın dayandığı varsayımı değiştiriyor.

R1 ve ben o cümleyi **sert bir kapı** olarak okuduk ("DE'de çalışmaz"). R2 diyor ki bu bir **tavsiye** — sebebi de yazıyor: testler veri değiştirir ve kredi harcar, o yüzden production'da değil sandbox'ta koş.

Eğer R2 haklıysa:
- Faz 6–8 (asıl ayırt edici) **DE org'da çalışabilir**
- Gerçek kısıt sandbox değil, **kredi bütçesi** — ki bu yönetilebilir
- Scratch-org yedek planı (B-02) gereksiz karmaşıklık olur

Eğer R1 haklıysa plan değişir.

**🔬 DOĞRULA — bu, defterdeki tek en önemli maddedir.** Agentforce açılır açılmaz test edilecek. Sonuç `docs/PHASE0_VERIFICATION.md`'ye ham çıktıyla yazılacak.

---

# ⚔️ ÇELİŞKİLER — en değerli bölüm

İki bağımsız hakem dokuz noktada ayrıştı. Anlaştıkları yerler muhtemelen doğru;
**ayrıştıkları yerler benim en çok düşünmem gereken yerler.**

### X-01 · `Compliance_Frist__c` jenerik saati: öldür mü, tut mu?

| | Pozisyon |
|---|---|
| **R1** | **Öldür.** *"4 lookup = 4 validation rule, 4 rollup, ve `WHERE a = :id OR b = :id OR...` — selective değil, tablo taraması. `LIMIT 50000` hatayı gizliyor, çözmüyor."* İki somut nesne öner: `Eichfrist__c` + `Partner_Nachweis_Frist__c`. |
| **R2** | **Tut.** *"Dört lookup referential integrity verir ve agent'ın temiz traverse etmesini sağlar. Portfolyo için tut — bilinçli tasarım gösteriyor. Trade-off'u dokümante et, tam bir Bezug dolu olsun diye validation rule ekle."* Alternatif olarak 2 lookup + Type discriminator. |

**Benim değerlendirmem:** R1'in itirazı **mühendislik**, R2'nin savunması **sunum**. "Bilinçli tasarım gösteriyor" argümanı, selective olmayan sorgu problemini çözmüyor — ve tam da bir Salesforce mühendisinin ilk fark edeceği şey bu.

Ama R2'nin "agent temiz traverse eder" noktası da gerçek: iki ayrı nesne, agent'ın "önümüzdeki 90 günde ne var?" sorusuna cevap vermesi için iki ayrı aksiyon gerektirir.

**Eğilimim R1** — ama R2'nin ara formülü (**2 lookup + Type discriminator**) ikisini de karşılıyor olabilir: `Bezug_Reseller__c` + `Bezug_Ladepunkt__c` yeter, çünkü v1'de sadece iki saat var.

**R3'e sorulacak.**

---

### X-02 · `AgentActionResult`: `rechtsgrundlage` / `konsequenz` ayrı alan mı?

| | Pozisyon |
|---|---|
| **R1** | **Çıkar.** *"Ayrı InvocableVariable olarak LLM bunları yeniden ifade eder ve JSONPath assert'lerini kırar. `ergebnis` içine göm."* |
| **R2** | **Tut.** *"Envelope iyi ve gerekli. Ayrı `rechtsgrundlage` / `konsequenz` / `leerHinweis` alanlarını koru."* |

**Benim değerlendirmem:** R1'in endişesi mekanizma hakkında (LLM paraphrase eder), R2'ninki değer hakkında (test edilebilirlik, zorunlu atıf).

Önerdiğim sentez ikisini de çözüyor: **alanları koru ama `filter_from_agent` ile modelden gizle.** Değer çıktıda durur → JSONPath assert çalışır. Model görmez → paraphrase edemez.

**Bu sentezin çalışıp çalışmadığı R3'e sorulacak** *(bkz. X-09)*.

---

### X-03 · Kaç subagent?

| | Pozisyon |
|---|---|
| **R1** | **2** — Partner-Compliance, Netzanschluss. Eichrecht'i Netzanschluss'a, THG'yi Compliance'a birleştir. |
| **R2** | **3** — Partner-Compliance, Netzanschluss+Eichrecht, THG/Förderung. |

**Benim değerlendirmem:** Fark küçük ve ikisi de 5'ten az diyor. R2'nin gruplaması daha mantıklı çünkü **THG ve Förderung aynı zihinsel modelde** (ikisi de "dışarıya beyan/başvuru"), oysa R1 THG'yi Compliance'a sıkıştırıyor ve o subagent aşırı yükleniyor.

**Eğilimim R2 (3 subagent)** — ama üçüncüsü ancak ilk ikisinin routing doğruluğu ölçüldükten sonra eklenecek. R1'in kuralı iyi: *"routing confusion %5'in altına inince subagent ekle."*

---

### X-04 · Groundedness scorer prompt'u

| | Pozisyon |
|---|---|
| **R1** | **Kötü kurulmuş.** *"'Emin değilsen 0 ver' doğru cevaplara da 0 verdirir, metrik gürültüye boğulur."* Yapılandırılmış auditor prompt'u öner. |
| **R2** | **İyi kurulmuş.** *"Default-to-zero'yu **güçlendir** ve hakemin eksik iddiayı **alıntılamasını** şart koş."* |

**Benim değerlendirmem:** İkisi aslında aynı şeyi farklı yerden söylüyor.

R1 haklı: körü körüne "şüphede 0" yanlış-negatif üretir.
R2 haklı: **hakemin eksik iddiayı alıntılamasını zorunlu kılmak** tam da bu sorunu çözer — çünkü hakem "hangi iddia eksik?" sorusuna somut cevap veremiyorsa 0 veremez.

**Sentez (ikisini birleştiriyorum):** R1'in yapılandırılmış çıkarım adımları + R2'nin zorunlu alıntı şartı.

```
1. RESPONSE içindeki §, tarih veya eşik içeren her iddiayı çıkar
2. Her iddia için ACTION_OUTPUT veya RETRIEVED_CHUNKS'ta entailment kontrol et
3. Skor 0 vermek için, karşılanmayan iddiayı BİREBİR ALINTILA
   → alıntılayamıyorsan 0 veremezsin
4. Hiç iddia yoksa 100
```

**Bu maddeyi çelişki olmaktan çıkarıp KABUL'e alıyorum.**

---

### X-05 · Citation stratejisi

| | Pozisyon |
|---|---|
| **R1** | **Tier 3 (zorunlu) kırılgan.** Trusted URL redaction `URL_Redacted` üretir. Tier 2 + kayıt Id'leri kullan. |
| **R2** | **Tier 3 hukuki iddialar için doğru.** Trusted URL'leri erkenden kaydet. |

**Benim değerlendirmem:** R2'nin çözümü (URL'leri erken kaydet) R1'in itirazını ortadan kaldırıyor. Ama R1'in **kayıt Id'siyle atıf** fikri ikisinden de iyi ve farklı bir problemi çözüyor.

**Sentez — iki kaynak, iki mekanizma:**
- **Hesaplanan gerçekler** (tarih, eşik, engel) → kaynak **kayıttır**, retrieval değil → `datensaetze` → *"Quelle: Ladepunkt LP-00042"*
- **Getirilen metin** (TAB gereksinimleri) → tier 2 citation + Trusted URL kaydı

**Çelişki değil, iş bölümü. KABUL.**

---

### X-06 · Data Library / RAG v1'de olsun mu?

| | Pozisyon |
|---|---|
| **R1** | Kalsın ama **PDF indexleme, kanun maddelerini markdown'a elle çevir**, sadece onları indexle. |
| **R2** | **v1'de tamamen öldür.** *"Her şeyi Apex'te hesapla, kanun atfını action result'tan statik string olarak ver. RAG'ı ancak deterministik çekirdek yeşil olduktan ve kalan bütçeyi ölçtükten sonra ekle."* |

**Benim değerlendirmem:** R2 daha radikal ve muhtemelen daha doğru — çünkü kendi mimari sınırım (§8.1) zaten şunu söylüyor: **tek generative aksiyon `HoleTABAnforderungen`.** Onu keserseniz RAG'a hiç ihtiyaç kalmıyor.

R2'nin ikinci argümanı daha da güçlü: *"Senin tek generative aksiyonun kullanıcı değerinin %90'ının ve halüsinasyon riskinin %100'ünün olduğu yer."* Yani RAG hem en riskli hem de kesilebilir parça.

**Ama** RAG'ı tamamen kesmek, groundedness scorer'ı da anlamsızlaştırır — yargılayacak retrieved content kalmaz.

**⚔️ AÇIK.** Karar şuna bağlı: groundedness kanıtı **wow'un merkezi mi**, yoksa hijyen mi? R1 "hijyen" dedi, R2 "gerçek ve nadir" dedi *(X-08)*.

---

### X-07 · `available_when` mi `ruleExpressions` mı otoriter?

| | Pozisyon |
|---|---|
| **R1** | *"Emin değilim, doğrula. Tahminim: `available_when` publish'te `ruleExpressions`'a derleniyor, yani Agent Script otoriter."* |
| **R2** | *"`ruleExpressions`'ı otoriter çalışma zamanı kapısı olarak kabul et; `available_when`'i sadece dokümantasyon için kullan. Ampirik doğrula."* |

**Benim değerlendirmem:** Tam ters tahminler, ikisi de emin değil, ikisi de doğrulama istiyor. İkisinin de dürüst davranması iyi.

**🔬 DOĞRULA.** Test yöntemi R1'den: ikisiyle birlikte publish et, üretilen `GenAiPlannerBundle`'ı diff'le.

---

### X-08 · Custom groundedness scorer "wow" mu, hijyen mi?

| | Pozisyon |
|---|---|
| **R1** | **Hijyen.** *"Herkes LLM-as-judge kurar. Table stakes, wow değil."* |
| **R2** | **Wow sıralamasında #3.** *"G1 metriklerinin geçireceği akıcı halüsinasyonları düşüren custom scorer — gerçek ve nadir."* |

**Benim değerlendirmem:** Ölçülebilir bir soru ve cevabı elimde: GitHub sayımımız `AiAgentScorerDefinition` için sayı vermiyor, ama `AiEvaluationDefinition` için **15 repo** dedi. Scorer daha yeni ve daha az bilinen bir tip — muhtemelen daha da az.

R1 "herkes LLM-as-judge kurar" derken **genel LLM uygulamalarını** kastediyor. Doğru. Ama **Salesforce metadata'sı olarak commit edilmiş, CI'da koşan** bir scorer başka bir şey.

**Eğilimim R2** — ama X-06'ya bağlı: RAG yoksa scorer'ın yargılayacağı şey de azalır.

---

### X-09 · Merkez problem: onboarding mu, regülasyon saatleri mi?

| | Pozisyon |
|---|---|
| **R1** | **Onboarding.** *"E.ON'un sertifikalı EV partner programı yok, bunu sen kanıtladın. Compliance aritmetiği alt-kontrol olsun."* |
| **R2** | **Saatler.** *"Daha keskin, daha düşük yüzeyli bir problem yok; **regülasyon saatleri hendektir** (the moat)."* |

**Benim değerlendirmem:** Bu, ilk defterde 🟡 açık bıraktığım A-04 maddesi ve R2 net karşı çıkıyor.

R2'nin argümanı benim içgüdümle aynı: onboarding **jenerik**, her CRM portfolyosunda var. Saatler kopyalanamaz çünkü alan bilgisi gerektiriyor.

R1'in argümanı ise **anlaşılırlık** hakkındaydı, ayırt edicilik hakkında değil.

**KARAR: R2. Saatler merkez kalır.** R1'in haklı olduğu tek nokta demo *açılışı* — ilk 30 saniye anlaşılır bir soruyla başlamalı *(A-03, zaten kabul)*. Bu, merkezi değiştirmeden R1'in endişesini karşılıyor.

**Çelişki kapandı.**

---

# BÖLÜM A — Kapsam

### A-01 · Kapsamı sert kes ✅ KABUL
**R1 + R2 hemfikir.** R1: "3 nesne, 2 subagent, 25 vaka". R2: "dikey dilim: 1 saha + 1 partner + 2 saat + 3 aksiyon + küçük eval suite".

**Uzlaşılan v1:**
- **3–4 nesne:** `Ladestandort__c`, `Ladepunkt__c`, `Partner_Nachweis_Frist__c` *(+ `Netzbetreiber__c`, X-01'e bağlı)*
- **2 saat:** Eichfrist + Installateurverzeichnis
- **3 aksiyon**, **3 subagent** *(X-03)*
- **15–25 Almanca eval vakası**

### A-02 · §6 Abs. 4 köprüsü kahraman ✅ KABUL
**Her iki hakem de "en güçlü tek demo anı" dedi.** R2 sıralamasında #2, R1'de #1.

### A-03 · Demo sohbetle açılsın ✅ KABUL
R2 ekliyor: *"ilk utterance altı maddelik yapılandırılmış cevabı üretsin, ki small-talk eksikliğini hiç hissetmesinler."*

### A-05 · E.ON'u koddan çıkar ✅ KABUL
**Her ikisi de aynı fikirde.**

---

# BÖLÜM B — Faz 0

### B-01 · Önce doğrula, sonra tasarla ✅ KABUL
**Her iki hakem de.** R2 somut: *"bugün `sf agent test list` ve 5 vakalık smoke suite'i doğrula."*

### B-02 · Scratch org yedek planı ⏸️ ERTELE
**P-00 nedeniyle beklemede.** DE gerçekten çalışıyorsa gereksiz karmaşıklık.

### B-03 · Kredi bütçesi ölçülecek, tahmin edilmeyecek 🔬 DOĞRULA
**R2 daha da ileri gidiyor** *(bkz. H-07)*: kredi tüketimini sadece ölçme, **CI kapısı yap**.

### B-04 · "Referans sayfası yok ⇒ sandbox-only" ❌ RED
Muhakeme hatası. R2 de zaten aksini söylüyor *(P-00)*.

---

# BÖLÜM C — Veri modeli

| Kod | Madde | Statü |
|---|---|---|
| **C-01** | Jenerik saat nesnesi | ⚔️ **X-01** |
| **C-02** | `Ladepunkt__c` ↔ `THG_Meldung__c` junction eksik | ✅ **KABUL** — R1'in bulduğu gerçek kod hatası |
| **C-03** | `Netzbetreiber__c` custom object + nullable `Account__c` | ✅ **KABUL** — her iki hakem de custom object diyor |
| **C-04** | 860 DSO numarası yapma, 5 tane seed et | ✅ **KABUL** — R2 aynı listeyi verdi |
| **C-05** | 6 nesne fazla | ✅ **KABUL** |

### C-06 · Formül vs Apex ayrımı ✅ KABUL *(R2 — yeni)*
> **R2:** *"Değişmeyen yasal aritmetik için formül. İş günü takvimi veya karmaşık çapraz-nesne mantığı için Apex/DateUtils. Hesaplanan değeri **her zaman action result envelope'unda göster**, agent asla yeniden türetmesin."*

Son cümle önemli ve aklıma gelmemişti: agent bir tarihi yeniden hesaplamak zorunda kalırsa halüsinasyon kapısı açılır.

### C-07 · Hakemlerin soracağı sorular ✅ KABUL *(R2 — yeni)*
R2 bir Salesforce mühendisinin veri modeline soracağı beş soruyu listeledi. Üçü doğrudan test vakasına dönüşüyor:
- 8 yıllık Eichfrist **yıl sınırlarında ve artık yıllarda** nasıl test ediliyor?
- Formül alanı **null** olduğunda agent'ın son tarih uydurmasını ne engelliyor?
- `Netzbetreiber__c.Antwortfrist_Tage__c` değişirse **açık** `Netzanschluss_Antrag__c` kayıtlarına ne oluyor?

---

# BÖLÜM D — Apex

| Kod | Madde | Statü |
|---|---|---|
| **D-01** | Bulkification — `List<Id>` girer, `List<AgentActionResult>` çıkar | ✅ **KABUL** |
| **D-02** | `InvocableVariable` uzunluk sınırı, `ergebnis`'i kırp | 🔬 **DOĞRULA** |
| **D-03** | Envelope'tan alan çıkar | ⚔️ **X-02** |
| **D-04** | Idempotency key — çift Task üretme | ✅ **KABUL** |
| **D-05** | FLS'i kanıtlayan güvenlik testi | ✅ **KABUL** — **her iki hakem de vurguladı** |
| **D-06** | Köprüyü üreten tek komutluk seed | ✅ **KABUL** — her ikisi de |

### D-07 · `DateUtils` implementasyonu ✅ KABUL *(R2 — çalışan kod verdi)*

R2 tam bir `DateUtils.cls` + `DateUtilsTest.cls` yazdı. Doğruladım:

```apex
eichfristEnde(2019-03-14) → 2027-12-31          ✓ MessEV §34 Abs. 2 doğru
nacheichungAntragsfrist(2027-12-31) → 2027-10-22 ✓ 70 gün, elle saydım, doğru
navAntwortfrist(2026-01-15) → 2026-03-15         ✓ takvim ayı, gün değil
```

Tasarımı doğru: saf, statik, null-safe, DML'siz test edilebilir. `addYears(8)` yerine takvim-yılı-sonu mantığı doğru kurulmuş.

Bir not: `navTageUeberfaellig` `frist.daysBetween(reference)` kullanıyor — işaret yönü doğru (pozitif = gecikmiş), ama test edilmeli.

### D-08 · Her invocable için failure-mode sözleşmesi ✅ KABUL *(R2 — yeni, önemli)*
> **R2:** *"Selector sıfır satır döndürdüğünde, formül alanı null olduğunda, CPQ lock çakıştığında, Search Index `Ready` değilken agent ne diyor ve hangi status'ü döndürüyor? `leerHinweis` bir başlangıç, **sistematik değil.**"*

Haklı. `leerHinweis` tek bir başarısızlık modunu (boş sonuç) karşılıyor, diğerlerini karşılamıyor.

**Aksiyon:** her aksiyon için dört başarısızlık modu tanımlanacak ve **her biri bir eval vakası olacak**:

| Mod | Beklenen davranış |
|---|---|
| Sıfır satır | `leerHinweis`, uydurma yok |
| Null formül alanı | `WARNUNG` + eksik alanı isimlendir |
| Lock/DML hatası | `WARNUNG` + tekrar dene önerisi, sessiz yutma yok |
| Bağımlı servis hazır değil | `WARNUNG`, sessiz boş cevap **asla** |

---

# BÖLÜM E — Eval ve CI

### E-01 · Doğrudan G2 ✅ KABUL — her ikisi de

### E-02 · CI kapısını böl ✅ KABUL — **R2 daha iyi eşik verdi**
> **R2:** *"%90 genel zayıf. **Deterministik sette %100 + yargılananda ≥%85** daha güçlü."*

R2 haklı ve bu benim planımdan da R1'inkinden de iyi. %90 genel oran, bir routing regresyonunun yargılanan metriklerin arkasına saklanmasına izin verir. Ayırınca:
- **Deterministik** (routing, action sequence, JSONPath) → **%100, istisnasız**
- **LLM-yargılı** (factuality, groundedness) → **≥%85**

### E-03 · Boş `expectedActions` pre-commit koruması ✅ KABUL
### E-04 · Groundedness prompt'u ✅ KABUL — **sentez, bkz. X-04**
### E-05 · Scorer action output'a erişebiliyor mu? 🔬 DOĞRULA — ikisi de emin değil
### E-06 · Eksik test kategorileri ✅ KABUL — birleştirilmiş liste:

multi-turn state · running-user permission degradation · bayat TAB (>1 yıl) ·
Chatter üzerinden injection · de-minimis rolling window · hukuki-danışmanlık reddi ·
Search-Index-not-Ready sessiz hatası · yıl sınırı / artık yıl · null formül alanı

### E-07 · Retrieval'ın gerçekleştiğini assert et ✅ KABUL
### E-08 · Adversarial refutation ✅ KES — **her iki hakem de "tiyatro" dedi**
### E-09 · Almanca bileşik isim routing vakaları ✅ KABUL

### E-10 · "Düşman hakem senaryosu" — ilk üç dakika ✅ KABUL *(R2 — yeni, çok iyi)*
> **R2:** *"Bir Alman enerji şirketi mühendisinin ilk üç dakikada yazacağı **tam beş utterance**. Bunlar yeşil olmadan başka hiçbir test önemli değil."*

R2'nin listesi:
1. **Kamuya açık vs özel §14a** — public charging muaf, klasik hata
2. **Eichfrist takvim-yılı sonu** — `addYears(8)` değil
3. **Installateurverzeichnis şirket düzeyinde**, kişi düzeyinde değil
4. **Vorzeitiger Maßnahmenbeginn**
5. **Eksik EVSE-ID**

Bu beş vaka, eval suite'inin **çekirdeği** olacak. Diğer 20 vaka bunların etrafında.

---

# BÖLÜM F — Grounding

| Kod | Madde | Statü |
|---|---|---|
| **F-01** | PDF yerine markdown | ⚔️ **X-06** — R2 tamamen kesmeyi öneriyor |
| **F-02/03** | Citation stratejisi | ✅ **KABUL** — sentez, bkz. X-05 |
| **F-04** | Data Cloud'suz observability yedeği | ✅ **KABUL** |
| **F-05** | ADL sürümleme + `Ready` kapısı | ✅ **KABUL** *(X-06'ya bağlı)* |
| **F-06** | Data Cloud'a gitmeyecek alan denylist'i | ✅ **KABUL** |

### F-07 · Telemetri DMO haritası ✅ KABUL *(R2 — yeni bilgi)*
R2, benim listemde olmayan DMO'ları ve **join anahtarını** verdi:

```
Session Tracing (planner katmanı)
  ssot__AiAgentSession__dlm
  ssot__AiAgentSessionParticipant__dlm      ← yeni
  ssot__AiAgentInteraction__dlm
  ssot__AiAgentInteractionMessage__dlm      ← yeni
  ssot__AiAgentInteractionStep__dlm

Platform Tracing (yürütme katmanı)
  ssot__TelemetryTraceSpan__dlm

Join: ssot__TelemetryTrace__c ↔ ssot__TelemetryTraceId__c   ← yeni, kritik

Metering
  AiAgentGenerativeAiUsage_std__dlm         ← yeni, H-07 için gerekli
```

Ayrıca uyarı: *"bir parent span, çocukları OK raporlasa bile fail edebilir"* — hata sorgusunun sadece `StatusCode = 'ERROR'`'a bakmaması gerektiği anlamına geliyor.

---

# BÖLÜM G — Kesilecekler

| Kod | Ne | R1 | R2 | Karar |
|---|---|---|---|---|
| **G-01** | Bundesland tatil tablosu | kes | kes | ✅ **KES** |
| **G-02** | CPQ | kes | kes | 👤 **SENİN** — aşağıda |
| **G-03** | MCP server + client | ertele | *"solution looking for a problem"* | ⏸️ **ERTELE** |
| **G-04** | 10 PDF'lik Data Library | markdown'a çevir | v1'de tamamen kes | ⚔️ **X-06** |
| **G-05** | 5 subagent | 2'ye in | 3'e in | ⚔️ **X-03** |
| **G-06** | 70 eval vakası | 25 | 15–25 | ✅ **KES** → 20 |
| **G-07** | Agent-to-agent | kes | *"Salesforce kendi `future_` klasöründe tutuyor, yoksay"* | ✅ **KES** |
| **G-08** | `available_when` + `ruleExpressions` + permission set'leri mükemmel uyumlu hale getirmeye çalışmak | — | *"tek çalışan subagent'ın olmadan bunu yapma"* | ✅ **KES** — sıralama meselesi |

### G-02 · CPQ 👤
**Her iki hakem de kes diyor.** R2: *"transferable skill, Apex-only API'yi invocable ile sarmak — bunu çok daha ince bir mock'la gösterebilirsin."*

Üç seçenek duruyor: (1) tamamen kes · (2) **ayrı projeye taşı** · (3) ince tut.
Eğilimim hâlâ **(2)** — CPQ ölü değil, ayrı bir hikâye.

---

# BÖLÜM H — Yeni iş

| Kod | Madde | Kaynak | Statü |
|---|---|---|---|
| **H-01** | GDPR silme/saklama | R1 | ✅ KABUL |
| **H-02** | Teardown scripti | R1 | ✅ KABUL |
| **H-03** | `Betriebsvereinbarung_AI_Entwurf.md` | R1 | ✅ KABUL |
| **H-04** | Hukuki-danışmanlık reddi eval suite'i | R1 | ✅ KABUL |
| **H-05** | Windows/CI ayrışması | R1 | ✅ KABUL — R2 de `subjectVersion` patch'inin Windows'ta çalışması gerektiğini vurguladı |
| **H-06** | "Neden Salesforce, Power Platform varken?" cevabı | R1 | ✅ KABUL |

### H-07 · Kredi/gecikme gözlemlenebilirliği **birinci sınıf artefakt** ✅ KABUL *(R2 — yeni)*
> **R2:** *"Telemetri DMO'ları üzerinde commit'li SOQL paketi iyi; **başarılı etkileşim başına ortalama Einstein request'i bir eşiği aştığında build'i düşüren** bir dashboard daha iyi."*

Bu, kredi kaygısını pasif bir endişeden **ölçülen ve kapıya bağlanan bir metriğe** çeviriyor. `AiAgentGenerativeAiUsage_std__dlm` üzerinden yapılabilir *(F-07)*.

Ve savunması güçlü: *"maliyeti CI'da ölçüyorum"* demek, *"kredi yetmedi"* demekten çok farklı.

### H-08 · "Sayılar Apex'ten geldi, LLM'den değil" kanıtı ✅ KABUL *(R2 — yeni)*
> **R2:** *"Anlatı bunu söylüyor; **repo bunu kanıtlamayı önemsiz hale getirmeli.** Action result envelope görünür, tam tarih string'ini assert eden bir eval vakası, ve blast-radius raporu alanın modele hiç yazılabilir olmadığını gösteriyor."*

Tüm tezin ispat yükü bu tek maddede toplanıyor.

### H-09 · Klonlama sonrası **tek komut** ✅ KABUL *(her ikisi de)*
> **R2:** *"Eğer o komut yoksa ve temiz bir DE org'da başarılı olmuyorsa, 'git'ten yeniden üretilebilir' iddiası **yanlıştır** ve portfolyo değerinin yarısını kaybeder."*

Sert ama doğru. Hedef:
```bash
sf project deploy start && \
sf apex run -f scripts/apex/seed.apex && \
sf agent test run --api-name VS_Smoke --result-format human
```

---

# BÖLÜM I — Kanıt kalitesi

### I-01 · `[V]` etiketleri fazla iddialı ✅ KABUL *(R1)*
R2 bu konuda sessiz kaldı — yani R1'in spesifik itirazlarını (Agent Script tarihi, subagent adlandırması) ne doğruladı ne çürüttü. **Her `[V]` için URL + erişim tarihi eklenecek.**

---

# Özet

| Statü | Adet |
|---|---|
| ✅ KABUL | 41 |
| ⚔️ ÇELİŞKİ (açık) | 4 |
| 🔬 DOĞRULA | 5 |
| ⏸️ ERTELE | 2 |
| ❌ RED | 1 |
| 👤 SENİN | 1 |

**İki hakem, dokuz noktada çelişti. Beşini kendim çözdüm, dördü açık.**

## R3'e sorulacak dört şey

1. **X-01** — `Compliance_Frist__c`: R1 öldür diyor (selective olmayan sorgu), R2 tut diyor (referential integrity). 2 lookup + Type discriminator ara formülü ikisini de çözer mi?
2. **X-02 / X-09** — `rechtsgrundlage`'ı ayrı alan olarak tutup `filter_from_agent` ile modelden gizlemek: test edilebilirliği korur mu, yoksa çıktı yapısı yine de reasoning'e sızar mı?
3. **X-03** — 2 mi 3 mü subagent?
4. **X-06** — Data Library v1'de tamamen kesilsin mi? Kesilirse groundedness scorer'ın yargılayacağı ne kalır — yani X-08'deki "wow mu hijyen mi" sorusu da buna bağlı.

Ve genel soru: **iki hakem de kaçırdı mı?** Bu defteri de ver, sor.

## Öncelik sırası (iki hakemin uzlaştığı)

1. **Faz 0 doğrulaması** — her şey buna bağlı *(P-00, B-01)*
2. **3–4 nesne + `DateUtils` + selector'lar** — R2 kodu verdi *(D-07)*
3. **1 subagent + 3 bulk aksiyon** *(D-01)*
4. **FLS güvenlik testi** — tek dosya, yüksek sinyal *(D-05)*
5. **R2'nin beş düşman utterance'ı** yeşil *(E-10)*
6. **Blast-radius CI'da** *(wow #1, her iki hakem de)*
7. **Tek komutluk yeniden üretim** *(H-09)*
