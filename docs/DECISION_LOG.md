# Karar Defteri — Agent Tasarımı

Kardeş modellerden gelen her öneri buraya girer, bir statü alır, ve statüsü değişirse
tarihiyle birlikte kaydedilir. Amaç: aynı tartışmayı iki kez yapmamak.

**Kaynak dosya:** [AGENT_DESIGN_FOR_REVIEW.md](AGENT_DESIGN_FOR_REVIEW.md)

## Statüler

| | Anlamı |
|---|---|
| ✅ **KABUL** | Uygulanacak. Gerekçe ikna edici. |
| ❌ **RED** | Uygulanmayacak. Gerekçesiyle birlikte. |
| 🟡 **AÇIK** | Karar verilmedi. Başka bir hakemin görüşü bekleniyor. |
| 🔬 **DOĞRULA** | Ampirik doğrulama olmadan karar verilemez. Org'da test edilecek. |
| ⏸️ **ERTELE** | Doğru fikir, v1 değil. v2 listesinde. |
| 👤 **SENİN** | Teknik değil, stratejik/kişisel karar. Mustafa verecek. |

## Hakemler

| Kod | Model | Tarih | Not |
|---|---|---|---|
| **R1** | (birinci kardeş) | 2026-08-22 | Sert, büyük ölçüde isabetli. Kapsam kesme konusunda haklı. |

---

# BÖLÜM A — Kapsam ve tez

### A-01 · Tasarımı yazıldığı gibi inşa etme, kapsamı sert kes
> **R1:** *"6 nesne, 5 subagent, CPQ bağlı, çift nesil eval — tek geliştirici bunu Developer Edition'da 2. haftada öldürür."*

**✅ KABUL.**

Bu defterdeki en önemli madde. R1 haklı ve gerekçesi şu: ben tasarımı *kanıtın genişliğine* göre kurdum (6 araştırma geçişi Alman hukukunu kanıtladı, o yüzden 4 rejimi de modelleyeyim), oysa **platformun nerede sessizce çökeceğine** göre kurmalıydım.

Yeni v1 kapsamı:
- **3 nesne:** `Netzbetreiber__c`, `Ladestandort__c` + `Ladepunkt__c`, `Partner_Nachweis_Frist__c`
- **2 subagent:** `Partner_Compliance`, `Netzanschluss`
- **1 kahraman aksiyon:** §6 Abs. 4 köprüsü
- **25 Almanca eval vakası** (60–80 değil)

Kesilen her şey `docs/V2_BACKLOG.md`'ye gider — silinmez, ertelenir.

---

### A-02 · §6 Abs. 4 köprüsü kahraman olsun
> **R1:** *"Public korpusta iki Alman hukuk rejimini tek bir tarih alanıyla birleştiren tek örnek. README'nin başına koy."*

**✅ KABUL.** Zaten öyle tasarlamıştım, R1 onayladı ve önceliğini yükseltti. README'nin ilk ekran görüntüsü bu olacak.

---

### A-03 · Demo sohbetle açılsın, aritmetikle değil
> **R1:** *"Hakemler önce routing görmek ister. 'Darf Partner X noch installieren?' — basit evet/hayır — sonra THG köprüsü."*

**✅ KABUL.** Ucuz ve doğru. Demo sırası: basit routing → partner engeli → çapraz rejim köprüsü.

---

### A-04 · Asıl problem partner onboarding + lead dağıtımı olsun
> **R1:** *"Daha keskin demo, daha az regülasyon yüzeyi. E.ON'un sertifikalı EV partner programı yok — bunu sen kanıtladın. Compliance aritmetiği alt-kontrol olsun, ürünün tamamı değil."*

**🟡 AÇIK** — ve bu defterdeki en tartışmalı madde.

R1'in argümanı güçlü: işe alan yönetici onboarding'i anlar, MessEV §34 Abs. 2 takvim aritmetiğini anlamaz.

**Ama karşı argüman:** onboarding **jenerik**. Her CRM portfolyosunda var. Bizi ayıran şey tam olarak "kimsenin modellemediği çapraz rejim bağlantısı". Onboarding'i merkeze alırsak, ayırt edici özelliği yan ürüne çeviririz.

**Önerdiğim sentez:** onboarding **anlatı çerçevesi** olsun, köprü **teknik kahraman** kalsın. Demo bir partner başvurusuyla başlar (yönetici anlar), yetki belgesi kontrolüyle devam eder (somut), ve çapraz rejim yakalamasıyla biter (şaşırtıcı).

Diğer hakemlere soracağım: *"Ayırt edici teknik derinliği merkezde tutup, anlaşılır bir iş sürecine sarmak mümkün mü — yoksa bu iki arada kalmak mı?"*

---

### A-05 · E.ON'u koddan çıkar, anlatıda tut
> **R1:** *"Genel Alman enerji/otomotiv işvereni için okunabilir olsun. Kodda E.ON adı geçmesin."*

**✅ KABUL.** Zaten marka kullanmama kararı almıştık (§ önceki oturum), R1 bunu koda kadar genişletiyor. Doğru. `Netzbetreiber__c` kayıtları gerçek DSO adları taşıyacak (Netze BW, Stromnetz Berlin — bunlar kamuya açık kayıt bilgisi), ama E.ON'a özel hiçbir yapı olmayacak.

---

# BÖLÜM B — Faz 0: kritik doğrulama

### B-01 · Tasarımı bırak, önce DE org'un test koşup koşmadığını doğrula
> **R1:** *"6 araştırma geçişini Alman hukukunu kanıtlamaya harcadın, DE org'unun `sf agent test run` koşup koşmadığını kanıtlamaya sıfır geçiş. Bu tersine çevirme yüzünden bu plan aylar kaybettirir."*

**✅ KABUL — ve bu, defterdeki en haklı cümle.**

Riski işaretledim, sonra planı başarılı olacağı varsayımıyla kurdum. Klasik hata.

**Aksiyon:** Agentforce açılır açılmaz `docs/PHASE0_VERIFICATION.md` oluşturulacak, komut çıktıları **ham haliyle** yapıştırılacak. Sonuç ne olursa olsun. Başarısızsa README'de yazacak.

---

### B-02 · Başarısız olursa: scratch org + `--features Agentforce,DataCloud`
> **R1:** *"Eval metadata'sını commit'li tut, evalleri 30 günlük trial/scratch org'da koş, README'de dürüstçe yaz: 'DE org NGT runner'ı çalıştıramıyor.' Bu dürüstlük daha kıdemli. DE'nin çalıştığını numara yapmak junior."*

**✅ KABUL.** Yedek planlarımın (d) şıkkının daha iyi hali. Not: scratch org **Dev Hub** gerektiriyor — kullanıcıda `aksultd2` Dev Hub olarak kayıtlı, yani mümkün.

---

### B-03 · Einstein Request kredi bütçesi hesabı
> **R1:** *"70 vaka × ~800 token Almanca × 2 nesil ≈ 112k token. Main'de tek CI koşusu = tükendi."*

**🔬 DOĞRULA.** R1'in rakamları `[S]` seviyesinde — DE tier limitini kendi kaynağından doğrulamadı. Ama büyüklük mertebesi mantıklı ve karar bunun üzerine kurulmamalı: **kredi tüketimini ölçeceğim**, tahmin etmeyeceğim. İlk eval koşusundan sonra gerçek tüketim `PHASE0_VERIFICATION.md`'ye yazılacak.

---

### B-04 · "AiTestingDefinition'ın public referans sayfası yok, demek ki sandbox-only"
> **R1:** *"You found no public reference page for AiTestingDefinition. That means it IS sandbox-only."*

**❌ RED — muhakeme hatası.**

Dokümantasyon eksikliği, çalışma zamanı kısıtı anlamına gelmez. G2 tipinin referans sayfası yok çünkü **yeni**, Salesforce'un kendi CLI kaynağından çıkarıldı. Sandbox kısıtı ayrı bir iddia ve ayrı kanıt ister.

Sonuç doğru çıkabilir — ama bu gerekçeyle değil. B-01'de ampirik olarak test edilecek.

---

# BÖLÜM C — Veri modeli

### C-01 · Jenerik `Compliance_Frist__c` saatini öldür
> **R1:** *"4 lookup + Type picklist = 4 validation rule, 4 rollup, ve her selector'da `WHERE a = :id OR b = :id OR...` — bu selective değil, tablo taraması. `LIMIT 50000` hatayı gizliyor, çözmüyor."*

**✅ KABUL.** Teknik olarak tartışmasız haklı. Salesforce'ta gerçek polimorfik lookup yok ve raporlama tarafı da çöküyor — "önümüzdeki 30 günde hangi son tarihler doluyor, Bundesland kırılımında" sorusu 4 ayrı rapor gerektirirdi.

**Yeni şekil:**
```
Netzbetreiber__c
    └── Ladestandort__c
            ├── Ladepunkt__c            (Eichfrist_Ende__c formülü kendi üzerinde)
            └── Netzanschluss_Antrag__c (Frist_Ablauf__c formülü kendi üzerinde)
Reseller__c
    └── Partner_Nachweis_Frist__c       (Master-Detail, Typ__c picklist)
```

Somut ilişkiler, gerçek rollup'lar, selective sorgular.

---

### C-02 · `Ladepunkt__c` ↔ `THG_Meldung__c` bağlantısı modellenmemiş
> **R1:** *"§7.4'teki `LadepunktSelector.getMitAbgelaufenerEichfrist(meldungId, ...)` çalışamaz çünkü `Ladepunkt__c`'nin `THG_Meldung__c`'ye lookup'ı yok. Junction gerekli, sen modellemedin."*

**✅ KABUL — gerçek bir kod hatası yakaladı.**

Kahraman aksiyonun imzası, var olmayan bir ilişkiye dayanıyordu. Düzeltme: `THG_Meldung_Ladepunkt__c` junction nesnesi (bir bildirim çok ladepunkt içerir; bir ladepunkt yıllara göre birden çok bildirimde olabilir).

Bu maddeyi bulmak, tasarımı hakeme vermenin tek başına bedelini çıkardı.

---

### C-03 · `Netzbetreiber__c` custom object doğru + nullable `Account__c` lookup ekle
> **R1:** *"DSO müşteri değil, kayıt. BDEW kodu external ID olarak Account Site'tan temiz. Ama DSO aynı zamanda müşteriyse diye nullable Account lookup ekle, trade-off'u dokümante et."*

**✅ KABUL.** Sorumu net cevapladı ve pratik bir orta yol verdi.

---

### C-04 · 860 DSO'yu modelliyormuş gibi yapma
> **R1:** *"Almanya'da ücretsiz resmî posta kodu→DSO API'si yok. 5 DSO'yu elle seed ettiğini ve en yakın geolocation ile çözdüğünü kabul et. 860 numarası yapma."*

**✅ KABUL.** Dürüstlük meselesi. `NetzbetreiberSelector.byPostcode` gerçekçi olmayan bir vaat olurdu. Seed'de 5 gerçek DSO olacak, çözüm geolocation yakınlığıyla, ve README'de sınır açıkça yazacak.

---

### C-05 · 6 nesne v1 için fazla, 3'e in
**✅ KABUL.** A-01'in parçası.

---

# BÖLÜM D — Apex ve aksiyonlar

### D-01 · Her aksiyon bulk olmalı: `List<Id>` girer, `List<AgentActionResult>` çıkar
> **R1:** *"Planner 200 Ladepunkt için `PruefeEichfristen` çağırırsa SOQL 100 ve DML limitine çarparsın. Governor limit'lerden hiç bahsetmiyorsun."*

**✅ KABUL.** Tasarımın en bariz boşluğu ve ben görmedim. `@InvocableMethod` zaten liste alır/döndürür — tekil imza yazmak Salesforce'un bulk sözleşmesini bilerek kırmak olurdu.

Bu, mevcut repo standardımla da çelişiyordu: trigger'larım bulkified, aksiyonlarım değildi.

---

### D-02 · `InvocableVariable` string uzunluk sınırı
> **R1:** *"`ergebnis`'i 4000 karaktere kırp, InvocableVariable'ın limiti var, hesaba katmamışsın."*

**🔬 DOĞRULA.** Kesin limiti doğrulamadım. Ama savunmacı kırpma zaten doğru pratik — limit ne olursa olsun uygulanacak. Ayrıca uzun çıktı LLM bağlamını da şişirir.

---

### D-03 · `AgentActionResult`'tan `rechtsgrundlage` ve `konsequenz` alanlarını çıkar
> **R1:** *"Ayrı InvocableVariable olarak LLM bunları başka kelimelerle yazar ve JSONPath assert'lerini kırar. Tek `ergebnis` string'inin içine göm."*

**🟡 AÇIK — kısmen katılmıyorum.**

R1'in mekanizma endişesi geçerli: LLM `rechtsgrundlage` alanını okuyup cevabında yeniden ifade edebilir ve JSONPath assert'i kırılabilir.

**Ama** ayrı alanların iki değeri var:
1. **Test edilebilirlik** — `$.rechtsgrundlage` üzerinde assert yapmak, prose içinde regex aramaktan çok daha sağlam
2. **Zorunlu atıf** — ayrı alan, aksiyonun her cevaba kaynak iliştirmesini *yapısal olarak* zorlar

**Sentez önerim:** alanları koru ama LLM'e gösterme. Agent Script'in `filter_from_agent` özelliği tam bunun için var: değer çıktıda durur, teste açıktır, ama modelin bağlamına girmez. Model sadece `ergebnis`'i görür — içine zaten gömülmüş halde.

Diğer hakemlere soracağım: *"`filter_from_agent` ile alanı testte tutup modelden gizlemek çalışır mı, yoksa çıktı yapısı yine de reasoning'e sızar mı?"*

---

### D-04 · Idempotency — yazma aksiyonları çift kayıt üretmemeli
> **R1:** *"Onaydan sonra ne oluyor? Kullanıcı iki kez sorarsa `ErstelleComplianceAufgabe` iki Task mı yaratıyor? `Idempotency_Key__c = resellerId + type + today` ekle."*

**✅ KABUL.** `isConfirmationRequired` insan onayını çözüyor, tekrarı çözmüyor. Bunu kaçırmışım.

---

### D-05 · FLS'i kanıtlayan güvenlik testi yaz
> **R1:** *"`WITH USER_MODE`'un uygulama noktası olduğunu söylüyorsun. Kanıtla: alan görünürlüğü kapalı bir kullanıcı yarat, aksiyonu o kullanıcı olarak koş, `System.SecurityException` fırlattığını assert et. **O tek test dosyası, 70 eval vakasından daha kıdemli.**"*

**✅ KABUL — ve bunu "wow" listesine terfi ettiriyorum.**

Mevcut mimari kuralımı (`WITH USER_MODE`) bir stil tercihinden **kanıtlanmış güvenlik özelliğine** çeviriyor. Tek dosya, düşük maliyet, yüksek sinyal. `ResellerSelectorSecurityTest.cls`.

---

### D-06 · Kaçırma dışı seed: `§6 Abs. 4` köprüsünü üreten tek komut
> **R1:** *"Bir yabancı `sf apex run scripts/apex/seed.apex` çalıştırıp hemen `BLOCKIERT` göremiyorsa demon ölü."*

**✅ KABUL.** Seed script zaten yazma alışkanlığımız var (3 tane var), ama köprüyü üreten spesifik veriyi henüz kurmadım.

---

# BÖLÜM E — Eval ve CI

### E-01 · G1+G2 paralel koşma, doğrudan G2'ye git
**✅ KABUL.** G1'in gerçek metriği yok (form ölçüyor). İki nesli birden koşmak krediyi ikiye katlayıp bilgi eklemiyor. G1 metadata'sı yine de commit'li kalacak — dokümante edilmiş tip o, ve karşılaştırma yazısı için lazım.

---

### E-02 · CI kapısını böl: deterministik all-green + LLM-yargılı oran kapısı
> **R1:** *"Maliyeti ikiye katlasa bile böl. Kredi maliyeti, gizlenen regresyonun maliyetinden ucuz."*

**✅ KABUL.** Kendi hipotezimdi, R1 onayladı ve gerekçesini netleştirdi.

- **Her PR'da:** 8 vakalık smoke, `topic_sequence_match` + `action_sequence_match` + JSONPath assert'leri → **hepsi yeşil olmalı**
- **Main + nightly:** 25 vakalık tam suite, `factuality` + groundedness scorer → **%90 oran kapısı**

%90'lık kapının deterministik assert'leri kapsamaması kritik: routing regresyonu artık gizlenemiyor.

---

### E-03 · Boş `expectedActions` için pre-commit koruması (bug #3314)
> **R1:** *"`yq` ile boş `expectedActions` varsa build'i düşür. Sen bug'ı not etmişsin ama kapın yakalamıyor."*

**✅ KABUL.** Sessiz doğruluk hatası — testler boş beklentiyle geçer ve yeşil görünür. Bunu not edip önlem almamak tuhaftı.

---

### E-04 · Groundedness scorer prompt'u yanlış kurulmuş
> **R1:** *"'Emin değilsen 0 ver' talimatı, bağlam ifadesi farklı olduğunda doğru cevaplara da 0 verdirir. Yeniden yaz: iddiaları çıkar, her birinin entailment'ını kontrol et, hepsi karşılanıyorsa 100."*

**✅ KABUL.** R1 haklı — benim prompt'um yanlış-negatif üreten bir tasarım. "Şüphede reddet" ilkesi güvenlik için doğru, **ölçüm** için yanlış: metrik gürültüye boğulur.

R1'in önerdiği yapılandırılmış versiyon (iddia çıkar → entailment kontrol et → JSON dön) doğru şekil.

---

### E-05 · `AiAgentScorerDefinition` action output'a erişebiliyor mu?
> **R1:** *"Emin değilim, doğrula."*

**🔬 DOĞRULA.** Ben de emin değilim. Scorer sadece interaction'ı mı görüyor, yoksa action çıktısını da mı — bu, E-04'teki prompt'un çalışıp çalışmayacağını belirliyor. Faz 0'da test edilecek.

R1'in kendi belirsizliğini işaretlemesi iyi — prompt'ta istediğim davranış tam buydu.

---

### E-06 · Eksik test kategorileri
> **R1:** *"multi-turn, permission (yetkisiz kullanıcı subagent'ı görmemeli), bayat TAB (>1 yıl), Chatter üzerinden injection, de-minimis rolling window."*

**✅ KABUL.** Beşi de gerçek boşluk. Özellikle **permission** kategorisi D-05'teki güvenlik testiyle birleşiyor.

---

### E-07 · Retrieval'ın gerçekleştiğini assert et, sadece sonucu yargılama
> **R1:** *"Custom scorer halüsinasyonu *olduktan sonra* yargılıyor. Önce retrieval'ın olduğunu assert etmelisin."*

**✅ KABUL.** İnce ve doğru nokta. JSONPath ile `invokedActions[...].function.output` üzerinde "retriever chunk döndürdü mü" assert'i, cevabı yargılamadan önce gelmeli.

---

### E-08 · Adversarial refutation ikinci geçişi tiyatro
**✅ KABUL (kes).** Kredi pahalı, kazanç belirsiz. E-02'deki bölünmüş kapı zaten regresyonu yakalıyor.

---

### E-09 · Almanca bileşik isimler için özel routing vakaları
> **R1:** *"İtalyanca 'modifica' örneğinin Almanca karşılığı: 'Freischaltung' → unlock mu activation mı?"*

**✅ KABUL.** Somut ve alan-spesifik. Almanca bileşik isimler (`Netzanschlussbegehren`, `Inbetriebsetzung`, `Freischaltung`) routing için özel risk.

---

# BÖLÜM F — Grounding

### F-01 · PDF indexleme, kanun maddelerini markdown'a elle çevir
> **R1:** *"10+ PDF, chunking savaşı, index sonsuza kadar 'Indexing'de takılı. Bunun yerine ihtiyacın olan 5 paragrafı `data/recht/` altına markdown olarak commit et. Mükemmel chunk'lanır."*

**✅ KABUL.** Kendi araştırmam zaten PDF risklerini işaretlemişti (gömülü içerik desteklenmiyor, görseller hiç chunk'lanmıyor) — ama yine de PDF planı yazmıştım. Tutarsızlık.

`data/recht/` altında: NAV §19, MessEG §38, 38. BImSchV §6 Abs. 4, BDEW/ZVEH §5.1–5.2, §14a EnWG. Kaynak URL'si her dosyanın başında.

---

### F-02 · Zorunlu citation (tier 3) kırılgan yapar
> **R1:** *"Trusted URL redaction `URL_Redacted` üretir. Tier 2 (model isterse alıntılar) + kayıt Id'leri kullan."*

**✅ KABUL.** F-03 ile birlikte.

---

### F-03 · Retrieval yerine kayıt Id'siyle atıf ⭐
> **R1:** *"Her Apex aksiyonu kayıt Id'si döndürsün, prompt template 'Quelle: Ladepunkt LP-00042' olarak render etsin. Retrieval olmadan atıf. Bunu public repolarda görmedim."*

**✅ KABUL — ve "wow" listesine ekliyorum.**

R1'in en yaratıcı önerisi. Kırılgan Data Cloud citation altyapısına bağımlı olmadan "kanıtla" şartını karşılıyor. Ve mimari sınırımla kusursuz uyumlu: **hesaplanan şeyin kaynağı kayıttır, retrieval değil.**

---

### F-04 · Data Cloud'suz observability yedeği
> **R1:** *"`ssot__` DMO sorguların Data Cloud gerektiriyor. DE'de muhtemelen yok. `Agent_Log__c` custom nesnesine yazan bir fallback logger ekle."*

**✅ KABUL.** Aynı Faz 0 riski gözlemlenebilirlik katmanını da vuruyor.

---

### F-05 · ADL sürümleme ve `Ready` kapısı
> **R1:** *"Kaynak PDF'lerin SHA256'sını commit et, `sf agent adl status` ile index'in `Ready` olduğunu assert etmeden publish etme. Sessiz hatayı not etmişsin ama kapın yok."*

**✅ KABUL.** F-01 markdown'a geçince SHA256 daha da kolay.

---

### F-06 · Data Cloud'a asla gitmeyecek alanlar için denylist
> **R1:** *"Injection yüzeyi Trusted URL'den geniş: `Reseller__c.Name`, `Opportunity.Description`, Chatter postları. `filter_from_agent` doğru ama alan denylist'i ve onları soyan bir selector gerek."*

**✅ KABUL.** ForcedLeak tam olarak bu şekilde çalışıyordu — dış kaynaklı metin CRM alanına giriyor, çalışan agent'a soruyor.

---

# BÖLÜM G — Kesilecekler (tar pit)

| Kod | Ne | R1 tahmini | Karar |
|---|---|---|---|
| **G-01** | `werktageAddieren` Bundesland bazlı tatil tablosu | 3 hafta | **✅ KES** → 9 ulusal tatili sabitle, sınırı README'de yaz |
| **G-02** | CPQ entegrasyonu (Faz 10) | 4 hafta | **👤 SENİN** — aşağıya bak |
| **G-03** | MCP server + MCP client | 2 hafta | **⏸️ ERTELE** → v2 backlog |
| **G-04** | 10 PDF'lik Data Library | 1.5 hafta | **✅ KES** → F-01 |
| **G-05** | 5 subagent × 6 aksiyon | 2 hafta | **✅ KES** → 2 subagent |
| **G-06** | 70 Almanca eval vakası | 2 hafta | **✅ KES** → 25 vaka |
| **G-07** | Agent-to-agent / subagentDelegation | — | **✅ KES** — Salesforce kendi `future_recipes/`'te tutuyor |

**Toplam R1 tahmini tasarruf: ~14 hafta.**

---

### G-02 · CPQ — senin kararın 👤
> **R1:** *"Tamamen kes. End-of-sale Mart 2025 gerçek. Ölü bir ürünle 4 hafta savaşıp 'managed package Apex API'sini sarabiliyorum' kanıtlayacaksın — bunu zaten 5 selector'ınla kanıtlıyorsun."*

**Teknik olarak R1 haklı.** Ama bu senin kararın çünkü:
- CPQ'yu org'a **sen kurdun**, 9 bölümlük bir video planın vardı
- Alman ilanlarında CPQ **bakım/migrasyon işi olarak** hâlâ görünüyor (Cremanski: *"4+ Jahre Erfahrung mit Salesforce CPQ, Billing oder Revenue Cloud Advanced"*)
- Ama greenfield talep **Revenue Cloud Advanced**'e kaymış

**Üç seçenek:**
1. **Tamamen kes** — R1'in önerisi, 4 hafta kazanç
2. **Ayrı projeye taşı** — VoltStream'den çıkar, kendi repo'su olsun, agent'la karışmasın
3. **İnce tut** — CPQ'ya dokunmayan `AngebotService`, sadece veri modeli göster

Benim eğilimim **(2)**: CPQ ölü değil, *ayrı bir hikâye*. Agent projesine bağlamak ikisini birden zayıflatıyor.

---

# BÖLÜM H — Eksikler (yeni iş)

### H-01 · GDPR silme/saklama tasarımı
> **R1:** *"Art. 26(6) altı ay log diyorsun ama `Reseller__c` için saklama ya da anonimleştirme yok. Alman enerji şirketi bunu ilk dakikada sorar."*

**✅ KABUL.** Doğru ve ucuz: `Anonymisierung_Am__c` alanı + saklama politikasını dokümante eden bir bölüm.

---

### H-02 · Teardown hikâyesi
> **R1:** *"ADL source-tracked değil, DSO kaydın var, evaller veri değiştiriyor. `sf project delete` Data Cloud'u temizlemiyor. `scripts/adl/teardown.sh` yaz ve veri kalıntısını dokümante et. Kıdemli mühendisler teardown arar."*

**✅ KABUL.** Bunu hiç düşünmemiştim ve gözlem doğru: kurulum scriptleri yazan çok, teardown yazan az.

---

### H-03 · Betriebsvereinbarung taslağı repoda
> **R1:** *"BetrVG §87(1)(6) ve Art. 26(7)'yi alıntılıyorsun ama artefaktın yok. `Betriebsvereinbarung_AI_Entwurf.md` ekle. MCP'den çok daha fazla Alman-pazarı wow'u."*

**✅ KABUL.** İddiayı belgeye çeviriyor — projenin geri kalanının felsefesiyle aynı: *"README'deki iddia hiçbir şey, diff'lenebilir artefakt bir şey."*

---

### H-04 · Hukuki danışmanlık reddi eval suite'i
> **R1:** *"Giriş açıklaman iyi ama yetmez. 'Ist es rechtlich zulässig wenn ich...' tipi promptlar `leerHinweis` + insana yönlendirme döndürmeli. Refusal kategorin var ama hukuki-danışmanlık reddi yok."*

**✅ KABUL.** Mülakatta sorulacak ilk sorulardan biri, ve şu an cevabım yok.

---

### H-05 · Windows/CI ayrışması
> **R1:** *"Windows'ta geliştiriyorsun, CI ubuntu'da. Yeşil CI + kırmızı local yaşayacaksın. `scripts/win-hacks.ps1` + pre-commit hook."*

**✅ KABUL.** Gerçek bir operasyonel risk, ve zaten iki Windows-spesifik CLI bug'ı biliyoruz.

---

### H-06 · "Neden E.ON'da Power Platform varsa Salesforce?" cevabı yok
> **R1:** *"Tüm pitch'in buna dayanıyor ama cevabını hiç yazmamışsın. Cevap: agent iç kullanım, Experience Cloud değil — ekstra partner lisansı yok, ve E.ON'un zaten ödediği Salesforce CRM'e yazıyor. Power Apps veriyi kopyalar."*

**✅ KABUL — ve bu ciddi bir boşluktu.**

Tüm anlatının menteşesi bu soru, ve dokümanda cevabı yoktu. R1'in verdiği cevap (lisanslama + veri kopyalamama) doğru yönde ama daha güçlendirilmeli.

---

# BÖLÜM I — Kanıt kalitesi

### I-01 · `[V]` etiketlerim fazla iddialı
> **R1:** *"'Agent Script 13 Temmuz 2026'da varsayılan oldu' — benim aramam TDX 2026'da duyurulduğunu gösteriyor ama o tarihi birincil kaynak doğrulamıyor. 'Topics, subagents oldu Nisan 2026' — dokümanlarda hâlâ `GenAiPlugin` görüyorum. `[V]`'lerin %70'ini `[S]`'ye indir, URL veremediğin sürece. Mülakatçı 'bunu nerede okudun?' diye sorar."*

**✅ KABUL — kısmen, ama önemli bir ayrımla.**

R1 haklı: **URL'siz `[V]` bir yükümlülük.** Etiket sistemini sıkılaştıracağım — `[V]` sadece elimde link + tarih varsa.

**Ama iki noktada R1 yanılıyor olabilir:**
- *"Dokümanlarda hâlâ `GenAiPlugin` görüyorum"* → doğru, ama bu terminoloji değişimini çürütmez. `GenAiPlugin` **metadata tipi adı**; "subagent" **UI/kavram adı**. İkisi bir arada var olabilir.
- R1'in kendi kaynağı da arama sonucu, birincil kaynak değil.

**Aksiyon:** her `[V]` iddiası için URL + erişim tarihi eklenecek; veremediğim `[S]`'ye inecek. Bu, dokümanı zayıflatmaz — **savunulabilir** yapar.

---

# Özet tablo

| Statü | Adet |
|---|---|
| ✅ KABUL | 34 |
| ❌ RED | 1 |
| 🟡 AÇIK | 2 |
| 🔬 DOĞRULA | 3 |
| ⏸️ ERTELE | 1 |
| 👤 SENİN | 1 |

**Kabul oranı %79.** R1'in eleştirisi büyük ölçüde isabetli — özellikle kapsam (A-01), veri modeli (C-01, C-02) ve Faz 0 tersine çevirmesi (B-01) konularında.

## Sonraki hakemlere özellikle sorulacaklar

1. **A-04** — Onboarding mi merkez, çapraz rejim köprüsü mü? Sentez mümkün mü?
2. **D-03** — `filter_from_agent` ile alanı testte tutup modelden gizlemek işe yarar mı?
3. **G-02** — CPQ: kes, ayır, yoksa ince tut?
4. R1'in **kaçırdığı** ne var? Bu defteri de ver, "bu 42 maddede eksik olan ne?" diye sor.
