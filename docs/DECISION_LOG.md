# Karar Defteri — Agent Tasarımı

Kardeş modellerden gelen her öneri buraya girer, bir statü alır. Amaç: aynı tartışmayı
iki kez yapmamak, ve hakemlerin **ayrıştığı** yerleri kaybetmemek.

**Kaynak dosya:** [AGENT_DESIGN_FOR_REVIEW.md](AGENT_DESIGN_FOR_REVIEW.md)

## Statüler

| | Anlamı |
|---|---|
| ✅ **KABUL** | Uygulanacak. |
| ❌ **RED** | Uygulanmayacak, gerekçesiyle. |
| ⚔️ **ÇELİŞKİ** | Hakemler ayrışıyor. |
| 🔬 **DOĞRULA** | Ampirik doğrulama şart. |
| ⏸️ **ERTELE** | Doğru fikir, v1 değil. |
| 👤 **SENİN** | Stratejik karar. |

## Hakemler

| Kod | Karakteri |
|---|---|
| **R1** | Sert, kapsam kesmede acımasız. Bir gerçek kod hatası buldu (`THG_Meldung__c` junction'ı). |
| **R2** | Dengeli, çalışan `DateUtils` kodu verdi, R1'i dokuz noktada çürüttü. |
| **R3** | En teknik. Üç kişinin de kaçırdığı bir **mimari boşluk** ve bir **portfolyo katili** buldu. |

---

# 🔴 R3'ün üç kritik bulgusu

## N-01 · `BusinessHours` standart nesnesi zaten var ✅ KABUL

> **R3:** *"Bölgesel tatiller için custom `DateUtils` planlıyorsun. **[V]** Salesforce'ta 15+ yıldır `BusinessHours` nesnesi var. Bölgesel iş günlerini ve tatilleri natif yönetiyor. Setup'ta her Bundesland için bir Business Hours kaydı yaratıp `BusinessHours.add(id, startDate, intervalInMilliseconds)` çağırıyorsun."*

**Bu, tar pit'i kesmiyor — buharlaştırıyor.**

R1 "3 hafta, 9 ulusal tatili sabitle, sınırı dokümante et" dedi.
R2 "erteleyin" dedi.
R3 "**standart nesne zaten var**" dedi.

Üçü de aynı problemi gördü, ama R3 tek doğru cevabı verdi. Ben Custom Metadata tatil tablosu tasarlıyordum — Salesforce'un on beş yıldır sahip olduğu şeyi yeniden icat ediyordum.

BDEW'in 10-iş-günü TAB kuralı artık ücretsiz geliyor, ve **`Feiertagskalender` Setup'ta veri olarak durduğu için** Fronleichnam/Reformationstag farkı bir Apex problemi değil, bir konfigürasyon satırı.

**G-01 (tatil tar pit'i) kapandı.**

---

## N-02 · Parametreler de üretiliyor — mimari sınırımdaki delik ✅ KABUL

> **R3:** *"'Sayılar hesaplanır, dil üretilir' diyorsun ama **parametrelerin de üretildiğini** kaçırmışsın. Kullanıcı 'Vogtland' diye sorup sonraki turda 'Eichfrist' derse, LLM 18 karakterlik Salesforce ID'sini bağlam penceresinden çıkarıp Apex'e geçirmek zorunda. **Sık sık başarısız olacak.**"*

**Üç hakemden sadece R3 bunu gördü, ve tasarımın en temel iddiasını deliyor.**

§8.1'de şunu yazdım: *"Sayılar hesaplanır. Dil üretilir. Sadece dış dokümanlar getirilir."* Tablo üç satırlıydı ve **dördüncü satır eksikti: parametreler.**

`PruefeEichrechtErklaerung(Id meldungId)` — o `meldungId` nereden geliyor? LLM'den. Yani deterministik Apex'in girdisi **halüsinasyona açık.**

**R3'ün çözümü:**
1. Agent Script'te açık durum değişkeni: `current_ladestandort_id`
2. Bir `ResolveRecordId` aksiyonu: bulanık string alır, **SOSL** koşar, tam ID'yi session değişkenine yazar
3. Aşağı akış aksiyonları **değişkenden okur**, bağlamdan değil
4. Apex, generic exception fırlatmak yerine `"ID eksik veya geçersiz, lütfen netleştirin"` döndürür — session çökmesin

**§8.1'deki mimari sınır tablosu düzeltilecek** ve dördüncü satır eklenecek.

---

## N-05 · Developer Edition hibernasyonu — portfolyo katili ✅ KABUL

> **R3:** *"Dev org'larda Data Cloud provisioning **14 gün kadar kısa bir hareketsizlikte** duraklıyor. İşe alan yönetici başvurudan 3 hafta sonra portfolyona bakarsa, Data Cloud index'in askıya alınmış olabilir ve **agent sessizce çalışmaz.**"*

Bunu kimse düşünmedi, ben dahil. Ve senaryo gerçekçi: başvuru gönderilir, iki hafta sonra teknik ekibe düşer, açarlar, **hiçbir şey çalışmaz** — ve hata mesajı bile yok, çünkü Search Index hazır değilken agent sessizce boş dönüyor *(bunu zaten `[V]` olarak biliyoruz)*.

**Aksiyon:**
- README'nin **en üstünde** "org'u uyandırma" talimatı
- Zamanlanmış bir ping mekanizması *(scheduled Apex veya GitHub Actions cron)*
- Ve daha iyisi: **demo, Data Cloud olmadan da çalışmalı** *(X-06 kararına bağlanıyor — RAG'ı kesmenin bir sebebi daha)*

---

# ⚠️ P-00 · "Sandbox-only" — oylama 2-1, ama soru anlamını yitirdi

| | Pozisyon |
|---|---|
| **R1** | Sert kapı |
| **R2** | Tavsiye — *"docs list Testing Center as available in Developer Edition"* |
| **R3** | **[V] Sert kapı** — *"Official docs state explicitly: 'Agent testing is available only in sandboxes.'"* + DE Einstein limiti **~110 request veya aylık 1.5M token** |

**Ama R3 aynı zamanda soruyu ortadan kaldıran çözümü verdi** *(N-10)*: eval'i platformdan çıkar. O zaman sandbox olup olmadığı önemsizleşiyor.

**🔬 DOĞRULA** — yine de ölçülecek, ama artık plan buna bağlı değil.

---

## N-10 · Platform dışı eval harness ✅ KABUL *(R3 — planı kurtaran fikir)*

> **R3:** *"CI'ı ikiye ayır. PR'larda **tam 3 deterministik test** natif koş — Salesforce eval metadata'sını bildiğini kanıtlamak için. **80 vakalık generative suite'i platform dışına taşı** (Promptfoo vb.), `sf agent preview --json` çağıran ve **kendi ucuz API anahtarınla** LLM-as-judge koşan bir GitHub Action'a."*

Bu, üç ayrı problemi tek hamlede çözüyor:

| Problem | Nasıl çözülüyor |
|---|---|
| Sandbox kısıtı *(P-00)* | Generative kısım zaten platformda koşmuyor |
| Kredi tükenmesi *(B-03, H-07)* | Kendi API anahtarım, DE allowance'ı değil |
| Non-determinizm CI'ı bloke ediyor *(E-02)* | Deterministik kısım natif ve %100 yeşil; yargılı kısım dışarıda |

Ve **metadata yine commit'li kalıyor** — yani "Salesforce eval altyapısını biliyorum" iddiası korunuyor, ama ona bağımlı olmuyorum.

R3'ün ifadesiyle: 3 natif test **bildiğini kanıtlar**, 80 dış test **çalıştığını kanıtlar**.

---

# ⚔️ Çelişkiler — üç yönlü

### X-01 · Jenerik saat nesnesi

| R1 | R2 | R3 |
|---|---|---|
| **Öldür** — selective olmayan sorgu | **Tut** — referential integrity | **Tut** — *"4 tipli lookup'ı koru, cascading delete ve referential integrity için. Ama tam birinin dolu olduğunu zorlayan validation rule ekle. **Polimorfik text alanları SOQL join'lerini yok eder.**"* |

**Oylama 2-1 tutmak yönünde.** R3, R1'in önerdiği alternatifi (polimorfik text) açıkça reddediyor.

**KARAR: TUT** — 4 lookup + "tam biri dolu" validation rule. Ama R1'in selective-sorgu itirazı gerçek, o yüzden **v1'de sadece 2 lookup doldurulacak** (`Bezug_Reseller__c`, `Bezug_Ladepunkt__c`), diğer ikisi şemada durup kullanılmayacak. Sorgular tek lookup üzerinden selective kalır.

**Çelişki kapandı.**

---

### X-02 · `AgentActionResult` envelope'u

| R1 | R2 | R3 |
|---|---|---|
| `rechtsgrundlage`/`konsequenz`'i **çıkar** | **Tut** | **Çok ağır.** *"LLM'i 5 ayrı alanı eşleştirmeye zorlama. **String formatlamayı Apex'te yap.** Tek `Markdown_Report` + `Status` döndür. **Apex atfı ve sonucu birleştirsin ki LLM fiziksel olarak düşüremesin.**"* |

**R3 çelişkiyi çözdü ve ikisinden de iyi.**

R1'in korkusu: LLM alanları yeniden ifade eder → assert kırılır.
R2'nin değeri: zorunlu atıf.

R3'ün çözümü ikisini birden karşılıyor: **Apex birleştirirse LLM düşüremez.** Atıf metnin *içinde*, ayrı bir alanda değil — dolayısıyla ne düşürülebilir ne de yeniden ifade edilebilir.

**Yeni envelope:**
```apex
public class AgentActionResult {
    @InvocableVariable public String bericht;      // Apex-formatlı markdown, atıf gömülü
    @InvocableVariable public String status;       // OK | WARNUNG | BLOCKIERT
    @InvocableVariable public List<String> datensaetze;  // kayıt-Id atfı (X-05)
}
```

`leerHinweis` kalkıyor — `bericht`'in içine giriyor. Test tarafı `status` ve `bericht` üzerinde string assert'iyle çalışıyor.

**Çelişki kapandı. `filter_from_agent` sentezine de gerek kalmadı.**

---

### X-03 · Kaç subagent
R1: 2 · R2: 3 · R3: değinmedi

**KARAR: 3** *(R2'nin gruplaması)*, ama üçüncüsü ancak ilk ikisinin routing doğruluğu ölçüldükten sonra.

---

### X-06 · Data Library / RAG v1'de

| R1 | R2 | R3 |
|---|---|---|
| PDF'i markdown'a çevir, onları indexle | **v1'de tamamen kes** | **Tut ama düzelt:** *"Ham PDF yükleme. TAB'ları ve MessEG'i offline'da **düzleştirilmiş hiyerarşik Markdown**'a çevir. **Her chunk'ta bağlamı yeniden belirt** (`# 38. BImSchV — § 6 Abs 4`). Data Cloud Markdown başlıklarını temiz parse eder."* |

R3 ayrıca **neden** başarısız olacağını açıklıyor: *"Section Aware Chunking ve V2 Small embedding **İngilizce için optimize**; karmaşık Alman kanun PDF'lerini katlediyor. Tabloları tamamen düşürüyor ve paragrafları üst başlıklarından koparıyor — 'Abs. 4'ün '§ 6'ya ait olduğu bilgisi kayboluyor."*

**KARAR:** R1+R3 hemfikir (markdown), R3 kritik detayı ekledi (**her chunk'ta bağlamı yeniden yaz**). Ama R2'nin "v1'de kes" argümanı N-05 (hibernasyon) ile güçlendi.

**Sentez:** RAG **v1.1**'e ertelenir, markdown dosyaları **şimdi** hazırlanır ve repoya girer. Böylece v1 Data Cloud'suz çalışır *(hibernasyona bağışık)*, ve RAG eklendiğinde içerik hazır.

---

### X-07 · `available_when` vs `ruleExpressions`

| R1 | R2 | R3 |
|---|---|---|
| Agent Script otoriter *(tahmin)* | `ruleExpressions` otoriter | **[S]** *"`available_when` prompt üretiminde **statik** olarak araçları filtreler. `ruleExpressions` planner'ın reasoning döngüsünde **sürekli** değerlendirilir. İzin kapısı için `available_when` kullan; **`ruleExpressions`'tan kaçın** — gecikme ve debugging cehennemi."* |

**R3'ün cevabı açık ara en teknik ve tek işlemsel olan.** İkisinin *ne zaman* değerlendirildiğini ayırıyor ve bundan bir tavsiye çıkarıyor.

**KARAR: `available_when`.** Yine de doğrulanacak (R3 kendi de `[S]` işaretlemiş), ama artık tahmin değil hipotez.

Not: bu, `ruleExpressions`'ı tasarımın "az bilinen guardrail" listesinden düşürüyor — R3'e göre kullanmamak daha doğru.

---

### X-08 · Custom groundedness scorer

| R1 | R2 | R3 |
|---|---|---|
| Hijyen | **Wow #3** | **Kes** — *"LLM-as-a-judge standart AI pratiği, kredi ağır, etkileyici değil."* |

**Oylama 2-1 kesme yönünde.**

Ama N-10 bunu da değiştiriyor: eval platform dışına taşınırsa, scorer **Promptfoo tarafında ücretsiz** hale geliyor. O zaman "kredi ağır" argümanı düşüyor.

**KARAR:** `AiAgentScorerDefinition` metadata'sı **yazılmayacak** *(R3 haklı — Salesforce metadata'sı olarak pahalı ve etkisiz)*. Groundedness kontrolü **platform dışı harness'ta** yapılacak. İşlev korunur, maliyet ve "wow" iddiası düşer.

---

### 🆕 X-10 · `Netzbetreiber__c` ve `Reseller__c` custom object mı olmalı?

| R1 | R2 | R3 |
|---|---|---|
| Custom object doğru | Custom object doğru — *"Account semantik olarak uymuyor, Account veri modeliyle sonsuza kadar savaşırsın"* | **[V] Account + RecordType.** *"B2B iş varlığı için bağımsız custom object **temel bir mimari hata**. Standard Sharing Rules, Account Teams ve Partner Communities'i yok sayıyorsun. **Alman enterprise mimarları seni bundan çakar.**"* |

**Yeni çelişki ve en ciddi olanı.**

**Benim değerlendirmem — R3 iki farklı şeyi birleştiriyor:**

- **`Reseller__c`** → R3 haklı olabilir. Bu **gerçekten bir B2B iş varlığı**: adresi var, kişileri var, fırsatları var. Klasik Salesforce mimarisinde bu `Account` + RecordType olurdu.
- **`Netzbetreiber__c`** → R3 muhtemelen aşırı genelleme yapıyor. Bu bir **kayıt/registry**, müşteri değil. R2'nin argümanı burada güçlü: BDEW kodu external ID olarak temiz, ve Account veri modeli (sharing, teams, communities) bir registry için gereksiz yük.

**Ama pratik gerçek:** `Reseller__c` **zaten var**, 108 testin, üç trigger'ın, iki selector'ın ve tüm mevcut repo'nun temeli. `Account`'a taşımak **haftalar** ve bu defterdeki tüm hız tavsiyeleriyle çelişiyor.

**KARAR:**
- `Netzbetreiber__c` → **custom object kalır** *(2-1)*
- `Reseller__c` → **kalır**, ama README'de trade-off **açıkça yazılır**: *"Gerçek bir implementasyonda bu Account + RecordType olurdu; burada custom object çünkü proje kanal-partner modelinin kendisini göstermek üzere kuruldu."*

R3'ün asıl uyarısı zaten bu: mülakatta sorulacak. Cevabı hazır olsun yeter.

**👤 SENİN** — tamamen yeniden yazmak istersen ayrı bir karar.

---

### X-11 · MCP server

| R1 | R2 | R3 |
|---|---|---|
| **Gimmick, öldür** — *"Alman enerji yöneticisi bunu güvenlik riski olarak duyar"* | Opsiyonel cila | **TUT — ama E.ON'a bağla.** *"E.ON kurulumcu portalını Power Platform'da kuruyor. Agentforce compliance motorunu MCP server olarak açarsan, **dış bir Power Platform uygulaması onu doğrudan sorgulayabilir** — tam olarak onların mimari yarığını köprülüyorsun."* |

**R3, R1'in itirazını tersine çevirdi.**

R1: *"agent'ı Claude'a açtım demek güvenlik riski gibi duyulur."*
R3: *"Claude'a açmıyorsun. **Onların kendi Power Platform'una** açıyorsun."*

Ve bu, tüm anlatının menteşesine oturuyor *(H-06)*: E.ON'un Salesforce'u var ama partner ağını Power Platform'da kuruyor. MCP server, "iki platformu birleştir" cevabının **çalışan hali** oluyor.

**KARAR: ⏸️ ERTELE ama öldürme.** v1'de değil — ama v2 backlog'unda ve README'de bir paragraf olarak, R3'ün çerçevesiyle.

---

# 🆕 R3'ün diğer yeni maddeleri

### N-03 · Bağlam kesme — `LIMIT 5` ✅ KABUL
> **R3:** *"`ListeAblaufendeFristen`'in belirtilmiş limiti yok. 100 son tarih doluyorsa, 100 kaydı JSON olarak LLM'e döndürmek bağlam penceresini patlatır. Apex **sert `LIMIT 5`** uygulamalı ve kesilmiş string döndürmeli: `'...ve 95 tane daha'`."*

Basit, bariz, kimse söylemedi. Her liste döndüren aksiyona uygulanacak.

### N-04 · Exception'ları LLM'e taşı ✅ KABUL
> **R3:** *"Kullanıcının bir alana FLS'i yoksa `WITH USER_MODE` `QueryException` fırlatır veya boş döner. `@InvocableMethod` sarmalayıcılarında **global try/catch** olmalı ve `AgentActionResult` içinde temizlenmiş hata payload'u döndürmeli — `'Bu kaydı görme yetkim yok'` gibi — ki LLM kullanıcıya söylesin, **özür uydurmasın.**"*

R2'nin failure-mode sözleşmesini *(D-08)* tamamlıyor. İkisi birleşince dört mod da kapsanıyor.

### N-06 · Sie/Du kayması ✅ KABUL
> **R3:** *"**[V]** Almanca Beta ve LLM'ler sürekli 'Du' ile 'Sie' arasında kayıyor, kurumsal personayı yok ediyor. Tüm subagent'larda 'Du'yu yasaklayan, 'Sie'yi zorlayan açık sistem talimatı gerek."*

Çok Alman-spesifik ve kesinlikle doğru. Bir Alman iş bağlamında "Du" kullanan agent **anında amatör** görünür. Ve bir eval kategorisi: her cevapta "Sie" register kontrolü.

### N-07 · Temel model kayması ✅ KABUL — *hiç düşünmemiştim*
> **R3:** *"Salesforce, Agentforce'u çalıştıran modelleri **sürüm sabitlemene izin vermeden** değiştiriyor ve güncelliyor. Ağustos 2026'da mükemmel çalışan promptlar Eylül'de bozulabilir. Tasarımında **sürümlenmiş prompt registry'si veya fallback stratejisi yok.** Bu sistemin temel model kaymasından nasıl sağ çıkacağını dokümante etmelisin."*

Bu, portfolyo için özellikle kritik: repo **aylarca** duracak ve her ay biri açıp deneyecek.

**Aksiyon:** prompt'lar sürümlenip commit'lenecek, eval sonuçları tarih damgasıyla saklanacak, ve README'de *"bu sonuçlar şu tarihte, şu model kuşağıyla alındı"* notu olacak. Kayma olduğunda **fark ölçülebilir** — ki bu tek başına bir bulgu.

### N-08 · Betriebsrat toggle'ı ⭐ ✅ KABUL
> **R3:** *"Bir Custom Metadata anahtarı — `Works_Council_Compliance_Mode` — `ssot__TelemetryTraceSpan__dlm`'den `running_user` ID'sini mantıksal olarak temizleyen ve performans raporlamasını bloke eden. **BetrVG §87(1)(6)'yı doğrudan kod tabanının içinde** ele almak, akıl almaz bir Alman-pazarı ayırt edicisi."*

R1 `Betriebsvereinbarung_AI_Entwurf.md` **belgesi** önermişti. R3 aynı şeyi **çalışan koda** çeviriyor.

Fark büyük: belge bir iddia, toggle bir **kanıt**. *"Betriebsrat endişesini biliyorum"* ile *"agent'ın çalışan izleme yeteneğini kapatan bir anahtar yazdım"* aynı lig değil.

**İkisi de yapılacak** — belge + toggle.

### N-09 · Zaman yolculuğu demo modu ⭐ ✅ KABUL
> **R3:** *"Agent'a ve `DateUtils`'e `Override_Today__c` değişkeni enjekte et. Kullanıcı 'Bugünün Aralık 2027 olduğunu varsay' diyebilsin. Agent bağlamı değiştirir ve **tüm Eichfrist son tarihleri kırmızıya döner.** Muhteşem bir canlı demo."*

Ucuz ve etkili. Ve bir yan faydası daha var: `DateUtils`'in her metodu zaten `referenceDate` parametresi alıyor *(R2'nin kodu öyle yazılmış)* — yani altyapı hazır, sadece agent değişkenine bağlanacak.

Test tarafında da işe yarıyor: yıl sınırı ve artık yıl testleri *(C-07)* aynı mekanizmayla.

---

# Kesin kararlar — üç hakemin uzlaştığı

| Ne | R1 | R2 | R3 |
|---|---|---|---|
| **Kapsamı sert kes** | ✓ | ✓ | ✓ |
| **Faz 0 önce** | ✓ | ✓ | ✓ |
| **CPQ'yu kes** | ✓ | ✓ | ✓ *"%30 zamanını yer, sıfır getiri"* |
| **Adversarial refutation'ı kes** | ✓ | ✓ | ✓ *"saf akademik tiyatro"* |
| **Agent-to-agent'ı kes** | ✓ | ✓ | ✓ *"kırılgan, dokümansız, izlenemez"* |
| **MCP client'ı kes** | ✓ | ✓ | ✓ *"use case arayan süslü REST callout"* |
| **G1 form metriklerini atla** | ✓ | ✓ | ✓ |
| **CI kapısını böl** | ✓ | ✓ | ✓ |
| **Ham PDF indexleme** | ✓ | ✓ | ✓ |
| **E.ON'u koddan çıkar** | ✓ | ✓ | ✓ |
| **Mimari sınır doğru** | ✓ | ✓ | ✓ *"the boundary is perfect"* |
| **Blast-radius = wow #1** | ✓ | ✓ | ✓ *"staff-level güvenlik hamlesi"* |
| **§6 Abs. 4 köprüsü = üst sıra** | #1 | #2 | #3 |
| **Tek komutluk yeniden üretim** | ✓ | ✓ | — |

---

# Diğer maddeler *(önceki hakemlerden, değişmedi)*

| Kod | Madde | Statü |
|---|---|---|
| C-02 | `Ladepunkt__c` ↔ `THG_Meldung__c` junction eksik | ✅ KABUL |
| C-04 | 860 DSO numarası yapma, 5 seed et | ✅ KABUL |
| C-06 | Formül vs Apex ayrımı; hesaplanan değeri envelope'ta göster | ✅ KABUL |
| C-07 | Yıl sınırı / artık yıl / null formül testleri | ✅ KABUL |
| D-01 | Bulkification — `List<Id>` girer, `List<AgentActionResult>` çıkar | ✅ KABUL |
| D-04 | Idempotency key | ✅ KABUL |
| D-05 | FLS'i kanıtlayan güvenlik testi | ✅ KABUL *(üç hakem de)* |
| D-06 | Köprüyü üreten tek komutluk seed | ✅ KABUL |
| D-07 | R2'nin `DateUtils` kodu — **N-01 ile revize** | ✅ KABUL |
| D-08 | Failure-mode sözleşmeleri | ✅ KABUL *(N-04 ile birleşti)* |
| E-02 | Deterministik %100 + yargılı ≥%85 | ✅ KABUL |
| E-03 | Boş `expectedActions` pre-commit koruması | ✅ KABUL |
| E-06 | Genişletilmiş test kategorileri | ✅ KABUL |
| E-10 | **R2'nin beş düşman utterance'ı** | ✅ KABUL — eval çekirdeği |
| F-06 | Data Cloud'a gitmeyecek alan denylist'i | ✅ KABUL |
| F-07 | Telemetri DMO haritası + join anahtarı | ✅ KABUL |
| H-01…H-06 | GDPR, teardown, Betriebsvereinbarung, hukuki red, Windows, "neden Salesforce" | ✅ KABUL |
| H-07 | Krediyi CI kapısı yap | ✅ KABUL |
| H-08 | "Sayılar Apex'ten geldi" kanıtı | ✅ KABUL |
| H-09 | Klonlama sonrası tek komut | ✅ KABUL |
| I-01 | `[V]` etiketlerine URL ekle | ✅ KABUL |
| G-02 | CPQ | 👤 **SENİN** |

---

# Özet

| Statü | Adet |
|---|---|
| ✅ KABUL | 52 |
| ⚔️ ÇELİŞKİ (açık) | 1 *(X-10, kısmen çözüldü)* |
| 🔬 DOĞRULA | 4 |
| ⏸️ ERTELE | 3 |
| ❌ RED | 1 |
| 👤 SENİN | 2 |

**Üç hakem, on bir noktada çelişti. Onunu çözdüm.**

R3, önceki iki çelişkiyi (**X-02** envelope, **X-07** gating) ikisinden de iyi bir cevapla kapattı, ve **X-11**'de R1'in kararını tersine çevirdi.

---

# v1 kapsamı — nihai

**Nesneler (4):** `Ladestandort__c` · `Ladepunkt__c` · `Netzanschluss_Antrag__c` · `Compliance_Frist__c` *(2 lookup aktif)*
`Reseller__c` ve `Netzbetreiber__c` mevcut/eklenir. `THG_Meldung__c` + junction köprü için gerekli.
**Kesilenler:** `Foerderantrag__c`, tüm CPQ.

**Agent:** 3 subagent, subagent başına ≤4 aksiyon, hepsi bulk.
**Zorunlu ilk aksiyon:** `ResolveRecordId` *(N-02)*.

**Eval:** PR'da 3 deterministik natif test · platform dışı harness'ta 20 Almanca vaka.
**Çekirdek:** R2'nin beş düşman utterance'ı *(E-10)*.

**Wow (üç hakemin uzlaştığı sıra):**
1. Blast-radius Escalation Gap CI'da
2. §6 Abs. 4 çapraz rejim köprüsü
3. `Works_Council_Compliance_Mode` toggle *(N-08)*
4. Zaman yolculuğu demo modu *(N-09)*

**Ölçek:** ~4 nesne · ~15 Apex sınıfı · 3 subagent · ~12 aksiyon · 23 test vakası.
İlk tasarımın yaklaşık **üçte biri.**

## Dördüncü hakeme sorulacak

1. **X-10** — `Reseller__c` gerçekten `Account` + RecordType olmalı mıydı? Mevcut 108 testi yeniden yazmaya değer mi, yoksa dokümante edilmiş bir trade-off yeter mi?
2. **N-02** — `ResolveRecordId` + session değişkeni deseni parametre halüsinasyonunu gerçekten çözer mi, yoksa sadece bir adım geriye mi iter?
3. **N-07** — temel model kaymasına karşı savunma: sürümlenmiş prompt registry'si yeterli mi?
4. Ve: **üç hakem de ne kaçırdı?**
