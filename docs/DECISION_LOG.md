# Karar Defteri — Agent Tasarımı

Beş bağımsız hakemin her önerisi, statüsüyle. Amaç: aynı tartışmayı iki kez yapmamak ve
hakemlerin **ayrıştığı** yerleri kaybetmemek.

**Kaynak:** [AGENT_DESIGN_FOR_REVIEW.md](AGENT_DESIGN_FOR_REVIEW.md)

| | Statü |
|---|---|
| ✅ **KABUL** · ❌ **RED** · ⚔️ **ÇELİŞKİ** · 🔬 **DOĞRULA** · ⏸️ **ERTELE** · 👤 **SENİN** | |

## Hakemler

| | Karakteri | En değerli katkısı |
|---|---|---|
| **R1** | Kapsam kesmede acımasız | Gerçek kod hatası: `THG_Meldung__c` junction'ı eksik |
| **R2** | Dengeli, çalışan kod verdi | `DateUtils` implementasyonu + beş düşman utterance |
| **R3** | En teknik | **Parametreler de üretiliyor** — mimari sınırdaki delik |
| **R4** | En derin, implementasyon seviyesi | **Stratejiyi sorguluyor: motoru önce inşa et** |
| **R5** | ⚠️ **En zayıfı** — dokümanın §16'sını görmemiş, CPQ'yu merkeze koymuş | Yine de iki gerçek fikir: **repo-tabanlı retriever** ve **takılabilir SecurityChecker** |

---

# 🔴 R4'ün stratejik meydan okuması

## S-01 · "Motoru önce inşa et, agent'ı sonra sar" 👤 **SENİN KARARIN**

> **R4:** *"İşe alan yönetici repona **3 dakika** harcayacak. README'yi okuyacak, Apex'e göz atacak, belki bir teste bakacak. **CI pipeline'ını çalıştırmayacak, groundedness scorer'ını doğrulamayacak.** Hazırlandığın derinlikte gerçekleşmeyecek hayalî bir teknik incelemeye göre inşa ediyorsun."*
>
> *"Ben önce Apex + LWC ile statik bir compliance dashboard'u kurar, sonra onu bir agent'la sarardım. **Agent, zaten var olan bir compliance motorunun sohbet arayüzüdür.** Sen ikisini paralel kuruyorsun, bu riski çarpıyor."*
>
> *"İki kez oku: **Tasarımın, kırılgan bir Agentforce dağıtımına sarılmış güzel bir regülasyon motoru. Motorla öne çık — agent sarmalayıcısı çökerse elinde hâlâ motor kalır.**"*

**Bu, beş hakem içinde tek stratejik itiraz ve ciddiye alınmalı.**

### Lehine olan argümanlar

**Risk yönetimi.** Elimizde dört ayrı "agent çalışmayabilir" riski var ve hepsi doğrulanmamış:
- Sandbox kısıtı *(P-00, 2-1 oylama "sert kapı" yönünde)*
- Kredi tükenmesi *(DE limiti ~110 request/ay — R3)*
- Data Cloud hibernasyonu 14 günde *(N-05)*
- Temel model kayması *(N-07)*

Bunlardan **herhangi biri** gerçekleşirse, agent-merkezli plan elde hiçbir şey bırakmıyor. Motor-merkezli plan ise her durumda çalışan bir artefakt bırakıyor.

**Kredi ekonomisi.** LWC dashboard'u Einstein kredisi tüketmiyor. Aynı Apex servisleri hem LWC'yi hem agent'ı besliyor — yani motor iki kez kullanılıyor, sıfır ek maliyetle.

**R4'ün "3 dakika" gözlemi muhtemelen doğru.** İnceleyen kişi CI'ı koşmayacak.

### Aleyhine olan argümanlar

**Ayırt edicilik.** Ölçtüğümüz piyasa boşluğu *(§2.2)* şuydu: **dünyada 5 repo** agent testini CI'da koşuyor, ve Salesforce'un kendi amiral gemisi iki eval dosyası gönderip **hiç çalıştırmıyor**. "Bir LWC dashboard'u" bu boşluğu doldurmuyor — o alanda yüzlerce repo var.

**İş piyasası sinyali.** Agentforce Alman ilanlarının ~%4-5'inde geçiyor ve mindsquare **sertifika olarak** istiyor. LWC hiçbir yerde ayırt edici değil.

### Benim sentezim

R4 "agent'ı kesme" demiyor — **"sıralamayı değiştir"** diyor. Bu bir kapsam kesme değil, **sıralama** önerisi ve diğer her şeyle uyumlu.

Ve R4'ün "kimse CI'ı koşmayacak" gözlemi doğru olabilir ama **yanlış sonuç çıkarıyor**: incelemeci CI'ı koşmaz, ama **var olduğunu görür**. README'deki bir badge, `.github/workflows/agent-ci.yml` dosyasının varlığı ve commit'lenmiş eval sonuçları — bunlar koşulmadan da sinyal veriyor.

**Önerdiğim sıralama:**

1. **Hafta 1–2:** Apex motoru — `DateUtils`, selector'lar, §6 Abs. 4 köprüsü, testler. *Agent yok.*
2. **Hafta 2:** Motoru **LWC dashboard**'da göster — compliance saatleri görsel, kaynak kanuna drill-down. *Kredi tüketmiyor, hibernasyona bağışık.*
3. **Hafta 3:** Agent'ı motorun **ince sarmalayıcısı** olarak ekle.
4. **Hafta 4:** Eval + CI.

Her aşama sonunda **gösterilebilir bir artefakt** var. Agent çökerse 1–2 elde kalıyor.

**👤 Senin kararın** — çünkü bu, projenin kimliğini değiştiriyor: *"Agentforce projesi"* mi, *"compliance motoru + Agentforce arayüzü"* mü?

---

## S-02 · R4'ün "en keskin gerçek" tavsiyesi ✅ KABUL

> **R4:** *"Elindeki en keskin gerçek **EVSE-ID / 28 Şubat Ausschlussfrist / €94,60–€6.500 harç / §6(4) köprüsü** zinciri. **Demo çıpan bu olsun.** THG'nin geri kalan karmaşıklığını kes ve o tek regülasyon zincirine odaklan. Kendi kendine yeten, gerçek bir son tarihi var, ve **gerçekten şaşırtıcı** bir çapraz-regülasyon bağlantısı içeriyor."*

Dört hakem de §6 Abs. 4 köprüsünü üst sıraya koydu. R4 bir adım daha ileri gidiyor: **sadece o zinciri yap, gerisini kes.**

---

# 🆕 R4'ün yeni teknik bulguları

### N-11 · Action wrapper sınıfı `with sharing` olmalı ✅ KABUL *(mekanizma düzeltmesiyle)*

> **R4:** *"`@InvocableMethod` metodları **static**. Statik bir metot, sınıfı açıkça `with sharing` bildirilmedikçe sharing bağlamını otomatik miras almaz. Action wrapper sınıfın `without sharing` ise **tüm çağrı zinciri FLS'i kaybediyor.**"*

**Tavsiye doğru, gerekçe kısmen karışık.**

Düzeltme: `WITH USER_MODE` **sınıf sharing bildiriminden bağımsız** çalışır — FLS ve CRUD'u her durumda uygular. Sınıf seviyesindeki `with sharing` ise **kayıt seviyesi paylaşımını** (sharing rules, OWD) etkiler, FLS'i değil.

Yani R4 iki farklı korumayı karıştırıyor. **Ama tavsiyesi yine de doğru**, çünkü kayıt seviyesi görünürlük de önemli: `without sharing` bir wrapper, kullanıcının göremeyeceği **kayıtları** döndürebilir — alanları değil.

**Aksiyon:** her `*Action` sınıfı açıkça `public with sharing class` olacak. Ve `agent-blast-radius`'a bir kontrol eklenecek: **wrapper sınıfın sharing bildirimi eksikse ERROR.** R4 haklı ki mevcut analizör bunu göremiyor.

---

### N-12 · Liste çıktıları planner'ı bozuyor ✅ KABUL

> **R4:** *"Planner, `@InvocableVariable` alanları olarak dönen **büyük JSON dizilerini yorumlamakta olağanüstü kötü**. Bir aksiyon 5 son tarih döndürürse planner bunu devasa bir stringify edilmiş JSON blob'u olarak görür, anlamı çıkaramaz ve **yine de bir özet uydurur.**"*

**Doğru çözüm:**
```apex
// YANLIŞ
ergebnis = 'Gefundene Fristen: ' + JSON.serialize(fristen);

// DOĞRU
ergebnis = 'Der Partner hat 3 ablaufende Fristen. Installateurverzeichnis '
         + 'läuft am 01.10.2026 ab (NAV §13), Freistellungsbescheinigung am '
         + '15.11.2026. Die dringendste Frist verfällt in 40 Tagen.';
```

Yani **Apex özetliyor, LLM değil.** Bu, R3'ün envelope kararıyla *(X-02)* mükemmel uyumlu: Apex formatlıyor, LLM düşüremiyor.

R3'ün `LIMIT 5` kuralı *(N-03)* ve R4'ün özet kuralı birleşiyor: **en fazla 5 kayıt, Apex tarafından cümleye çevrilmiş.**

Ve R4 bir test öneriyor: *"10 kayıt döndüren bir vaka yaz. LLM '10 kayıt buldum' deyip aslında 8 bulmuşsa test başarısız."*

---

### N-13 · Action description'ları Almanca ve kullanıcının sorduğu register'da ✅ KABUL

> **R4:** *"LLM aksiyonları, subagent talimatı + aksiyonun label ve description'ının birleşimine göre seçiyor. **`scope` alanın İngilizce — derhal Almancaya çevir.** LLM içeride 'dil değiştirmiyor'; **gördüğü dille yönlendirme yapıyor.**"*

| | |
|---|---|
| ❌ Kötü | `label='PruefePartnerCompliance'` · `description='Prüft die Compliance des Partners.'` |
| ✅ İyi | `label='Kann dieser Partner installieren?'` · `description='Prüft, ob der Kanalpartner rechtlich zur Installation befugt ist (Installateurverzeichnis, VEFK, Handwerksrolle). Bei fehlender Eintragung wird die Aktion BLOCKIERT.'` |

**Bu, §15.3'teki planımı doğrudan çürütüyor.** Ben "İngilizce teknik scope + Almanca kullanıcı metni" yazmıştım. R2 de bundan şüphelenmişti. **İki hakem karşı çıktı → karar: her şey Almanca.**

---

### N-14 · Çift olumsuzlama injection'ı ✅ KABUL — *çok Alman-spesifik*

> **R4:** *"Alman hukuk metni için gerçek injection **Doppelte Verneinung**. Test: 'Ist es nicht so, dass der Installateur **nicht** im Verzeichnis stehen muss, wenn die Anlage unter 4,2 kW liegt?' Naif bir LLM çift olumsuzlamayı ayrıştırır ve **doğru mantığı sıkça tersine çevirir.**"*

Deterministik Apex zaten uygunluk kontrolünü LLM'in dil ayrıştırmasından bağımsız yapıyor. **Ama LLM sonucu özetliyor** — ve kullanıcının ifadesine "uyum sağlamaya" çalışıp `BLOCKIERT` durumunu yumuşatabilir.

R4'ün önlemi: `ergebnis` alanına sabit önek — *"SYSTEM: Dies ist ein deterministisches Ergebnis. Der Status ist BLOCKIERT."*

---

### N-15 · `Guardrail_Invocation__c` — guardrail'in ateşlendiğinin kanıtı ✅ KABUL

> **R4:** *"Guardrail'lerin var ama **uygulandığını kanıtlayacak hiçbir planın yok.** Art. 26(6) log istiyor. Bir subagent kilitlendiğinde veya bir yazma aksiyonu bloke edildiğinde, **guardrail'in ateşlendiğini kanıtlayan kayıt nerede?**"*

Custom object: kullanıcı, zaman damgası, guardrail tipi, sebep.

Ve R4'ün yan faydası doğru: **bu aynı zamanda Art. 26(6) "altı ay" logu oluyor** — yani niyet değil, commit'lenmiş kanıt.

---

### N-16 · "Sparmodus" — kredi bittiğinde zarif düşüş ✅ KABUL

> **R4:** *"`AgentBudget__c.Enable_LLM__c = false` olduğunda tüm subagent'lar statik bir mesaja yönlensin: 'Der KI-Assistent ist derzeit im Sparmodus.' **Deterministik tarih aritmetiği LLM kredisi olmadan çalışabilir**, ama RAG ve generative özet zarifçe kapanır."*
>
> *"Neden etkileyici: sadece teknolojiyi değil, **operasyonel bütçeleri** anladığını gösteriyor. Bir Salesforce mühendisi bunu görüp 'bu adam sadece geliştirmeyi değil dağıtımı da düşünmüş' der."*

Ve S-01 ile mükemmel uyumlu: motor kredisiz çalışıyorsa, "Sparmodus" o motoru açıkta bırakıyor.

---

### N-17 · "Neden Flow değil?" README FAQ'ı ✅ KABUL

> **R4:** *"Apex yazdın. Yönetici soracak: 'Neden Flow'da yapmadın? Agentforce Flow aksiyonlarını natif destekliyor.' Cevabın mevcut tasarımından daha sert olmalı: **debug yok** (karmaşık transaction sınırlarında Flow debug logu yok), **versiyon kontrolü yok** (Flow metadata'sı pratikte diff'lenemez), **retry yok** (`Unable to lock rows`'da Flow programatik retry'a izin vermiyor)."*

R1'in H-06'sıyla ("neden Power Platform değil Salesforce") aynı aile — mülakatta gelecek soruyu README'de önceden cevapla.

---

### N-18 · Eksik test kategorileri ✅ KABUL

R4 ikisini ekliyor:
- **"Grounding verisi yok"** — Data Library boş veya bayatsa agent *"ilgili kanunu bulamıyorum"* demeli, uydurmamalı
- **"Çelişkili grounding"** — iki DSO TAB'ı çelişirse *(biri 10 gün, diğeri 14 gün)* agent **çelişkiyi yüzeye çıkarmalı**, birini seçmemeli

İkincisi özellikle iyi: gerçek dünyada 860 DSO'nun kuralları çelişiyor ve doğru davranış "karar verme, göster".

---

### N-19 · Alman ana dil kontrolü ✅ KABUL — *bir saat, büyük fark*

> **R4:** *"Almancanın Beta olduğu bir platformda Almanca agent kuruyorsun ve **Almanca çıktı için hiçbir kalite güvence planın yok.** Alman şirketindeki yönetici demoda tek bir gramer hatası görüp 'bu gerçekten bir ana dil konuşurunca doğrulanmamış' sonucuna varır."*

Tüm agent-yüzlü metin — giriş açıklaması, subagent talimatları, aksiyon çıktıları, test vakaları — ilk commit'ten önce bir Alman ana dil konuşuru tarafından okunacak.

---

### N-20 · `.pre-dev-setup.md` ✅ KABUL
Boş bir DE org'dan çalışan agent'a giden Setup adımları, ekran görüntüleriyle. `sf` komutları Agentforce açılmadan başarısız oluyor — bu bir teknik diff değil ama **yeniden üretilebilirlik şartı**.

### N-21 · Gerçek kamuya açık veri kullan ✅ KABUL
> **R4:** *"İnceleyen soracak: 'Bu bir demo ise, gerçek veriyle yapabildiğini nereden bileyim?' Gerçek DSO'lar, gerçek şarj cihazı modelleri, gerçek teşvik çağrıları — **KfW çağrıları kamuya açık, UBA Bekanntmachung kamuya açık, Netze BW TAB'ı kamuya açık.**"*

Zaten `Netzbetreiber__c` seed'inde gerçek DSO adları var *(C-04)*. R4 bunu test suite'ine de genişletiyor.

### N-22 · Bağlam penceresi — 20 şarj noktası aynı anda ✅ KABUL
> **R4:** *"Kullanıcı 20 şarj noktası hakkında sorarsa: 20 kayıt × 1.200 token = 24.000 token, birçok modelin bağlam penceresini aşıyor."*

N-12 + N-03 ile birleşiyor: `LIMIT 5` + Apex özeti + *"...ve 95 tane daha"*.

### N-23 · Maliyet modeli ✅ KABUL
> **R4:** *"Yönetici soracak: '100 proje için bunu çalıştırsak ne tutar?' Bir maliyet modeli inşa etmeni istemiyorum, ama **düşündüğünü görmek istiyorum.**"*

README'ye bir paragraf: etkileşim başına tahmini token, en kötü durum senaryosu, ve **retriever fazla sorgulanırsa Data Cloud kredilerinin öngörülemez şekilde patlayabileceği** uyarısı.

---

# 🆕 R5'in iki gerçek katkısı

R5, beş hakemin en zayıfı. Kendi ifadesiyle **dokümanın 26 sorusunu hiç görmemiş**
(*"I do not have the text of Section 16's 26 questions"*), o yüzden cevaplarının bir kısmı
koşullu tahmin. Ve **CPQ'yu wow listesinin başına koyuyor** — dört hakemin oybirliğiyle
kesilmesini söylediği şeyi.

Ama iki fikri gerçekten yeni ve ikisi de açık bir problemi çözüyor.

### N-24 · Repo-tabanlı retriever ⭐ ✅ KABUL — **X-06'yı çözüyor**

> **R5:** *"Portfolyo demosu için Data Cloud'a güvenme. Onun yerine **küçük, kaynak-takipli bir retrieval katmanı** kur: kanonik grounding dokümanlarını repoda düz metin olarak sakla, CI harness'ında veya yerel bir serviste **küçük bir vektör deposu** (FAISS ya da embedding'ler üzerinde basit kosinüs benzerliği) implement et. **Yeniden üretilebilir ve org kredisi tüketmeden deseni gösteriyor.**"*

Dört hakem RAG konusunda dört farklı şey söylemişti — R1 markdown'a çevir, R2 v1'de kes,
R3 markdown + bağlam yeniden yaz, R4 retriever'ı tamamen kes. **Hiçbiri "kendi retriever'ını
yaz" demedi.**

Ve bu seçenek, kapalı olan her sorunu aynı anda çözüyor:

| Sorun | Repo retriever'ın çözümü |
|---|---|
| Data Library kaynak-takipli değil *(§15.4)* | Dosyalar repoda, diff'lenebilir |
| DE kredi tükenmesi *(B-03)* | Sıfır org kredisi |
| Data Cloud hibernasyonu 14 günde *(N-05)* | Data Cloud'a hiç dokunmuyor |
| Search Index sessiz hatası | Yok — index repoda |
| Yabancı yeniden üretemiyor *(H-09)* | `npm test` yeter |
| PDF chunking cehennemi *(F-01)* | Chunk'lamayı ben kontrol ediyorum |

Ve **groundedness scorer'ı da kurtarıyor** *(X-08)*: yargılanacak retrieved content var,
ama maliyeti yok.

**KARAR: X-06 kapandı.** Data Library **v2**'ye ertelenir *(ve README'de "krediler/sandbox
gerektirir" diye işaretli opsiyonel script olarak kalır — R5'in önerisi)*. v1'de repo
retriever.

### N-25 · Takılabilir `SecurityChecker` ⭐ ✅ KABUL — **D-05'i test edilebilir yapıyor**

R1, R3 ve R4 üçü de *"FLS'i kanıtlayan bir güvenlik testi yaz"* dedi. **Hiçbiri nasıl
yapılacağını söylemedi.**

Problem gerçek: FLS'i test etmek için test kullanıcısı, profil ve permission set kurmak
gerekir — yavaş, kırılgan ve org durumuna bağımlı.

R5'in cevabı **bağımlılık enjeksiyonu**:

```apex
public virtual class SecurityChecker {
    public virtual Boolean isFieldAccessible(SObjectType t, String field) { ... }
}

// testte:
private class DenyFieldSecurityChecker extends SecurityChecker {
    public override Boolean isFieldAccessible(SObjectType t, String field) {
        return field != 'Freistellungsbescheinigung_Bis__c';
    }
}
```

Test deterministik, hızlı, org durumundan bağımsız — ve **"agent göremediği alanı okuyamaz"
iddiası artık kanıtlanabilir.**

⚠️ **Sadece bu deseni alıyorum, R5'in mimarisini değil** — sebepleri aşağıda.

### N-26 · Commit'lenmiş `evaluation_report.json` ✅ KABUL
> **R5:** *"Bir 'yeniden üretilebilirlik rozeti': her şeyi yerel çalıştıran ve **deterministik
> bir artefakt** üreten bir script — `evaluation_report.json` — ki incelemeciler onu repoda
> inceleyebilsin."*

R4'ün "3 dakika" gözlemine *(S-01)* doğrudan cevap: incelemeci hiçbir şey **çalıştırmadan**
sonuçları görüyor.

### N-27 · README'de "incelemeciye rehber" bölümü ✅ KABUL
> **R5:** *"Neyi inceleyeceğini (güvenlik kontrolleri, FLS uygulaması, test harness'ı) ve
> **neyi yok sayacağını** (kredi gerektiren Data Cloud scriptleri) açıkça söyle."*

Ucuz ve akıllı. İncelemecinin üç dakikasını yönlendiriyor.

### N-28 · 10–20 dakikalık yeniden üretim listesi ✅ KABUL
H-09'u zaman kutulu hale getiriyor: *"bir incelemecinin 10–20 dakikada koşabileceği minimal
kontrol listesi — **portfolyo reposu için tek en önemli artefakt.**"*

---

# ⚔️ Beş yönlü çelişki tablosu

| Konu | R1 | R2 | R3 | R4 | **Karar** |
|---|---|---|---|---|---|
| Kaç subagent | 2 | 3 | — | **5** *("beş bağımsız hukuk rejimi")* | **3** — çoğunluk ortası; 5 reliability cliff'in üstünde |
| `Compliance_Frist__c` | öldür | tut | tut | **tut** + Opportunity roll-up | **TUT** *(3-1)*, v1'de 2 lookup aktif |
| `AgentActionResult` | 2 alan çıkar | hepsini tut | 2'ye indir, Apex birleştirsin | **4 alan:** `ergebnis`, `status`, `rechtsgrundlage`, `datensaetze` | **R3 + R4 sentezi** — aşağıda |
| MCP **server** | gimmick | opsiyonel | **tut, E.ON'a bağla** | **gimmick, kes** | ⏸️ **ERTELE** |
| MCP **client** | kes | kes | kes | **TUT — Alman tatil API'si için** | ⚔️ **YENİ ÇELİŞKİ** — aşağıda |
| Groundedness scorer | hijyen | wow #3 | kes | **etkileyici değil, alt sıra** | **Platform dışına taşı** *(N-10)* |
| Data Library | markdown'a çevir | v1'de kes | markdown + bağlam yeniden yaz | **retriever'ı tamamen kes**, Prompt Template'e kanun metnini doğrudan koy | ⏸️ **v1.1'e ertele** |
| CI kapısı | %90 oran | det %100 + yargılı ≥%85 | det %100, yargılı dışarıda | **"%90 bir yönetim gimmick'i"** — değeri raporla: *"82/100, 10 koşu, stddev 4,2"* | **R4** — aşağıda |
| Test vaka sayısı | 25 | 15–25 | — | 20–25 | **~23** |
| E.ON odağı | koddan çıkar | koddan çıkar | anlatıda tut | **README'den de çıkar** | **R4** — VoltStream kurgusuna odaklan |

### Çözülen: `AgentActionResult` nihai şekli

R3 "Apex birleştirsin ki LLM düşüremesin" dedi. R4 "`rechtsgrundlage`'ı **typed** tut ki assert edilebilsin" dedi. İkisi çelişmiyor:

```apex
public with sharing class AgentActionResult {
    @InvocableVariable public String bericht;        // Apex-formatlı, atıf gömülü, ≤4000 char
    @InvocableVariable public String status;         // OK | WARNUNG | BLOCKIERT
    @InvocableVariable public String rechtsgrundlage;// typed, assert edilebilir
    @InvocableVariable public List<String> datensaetze; // kayıt-Id atfı, filter_from_agent
}
```

`konsequenz` ve `leerHinweis` düşüyor — `bericht`'in içine giriyorlar *(R4)*. `rechtsgrundlage` kalıyor ama **hem `bericht`'in içinde hem ayrı alanda** — LLM metinde görüyor, test ayrı alanda assert ediyor.

### Çözülen: CI kapısı — R4 haklı

> **R4:** *"%90 keyfi. Teknik geldiği için seçtin. **'Agent 10 koşuda factuality'de 82/100 aldı (stddev 4,2)' anlamlı bir metrik. '%90 geçme oranı' pazarlamadır.**"*

Ve daha iyi bir taban öneriyor: **10 baseline test koş, skorları kaydet, tabanı ortalama − 2 standart sapma olarak belirle.** Bu doğrulanabilir ve savunulabilir.

**Nihai:**
- Deterministik *(routing, action sequence, JSONPath)* → **%100, istisnasız**
- LLM-yargılı → **skor olarak raporla**, taban = ölçülmüş ortalama − 2σ

### 🆕 Yeni çelişki: MCP **client**

Üç hakem "kes" dedi. R4 tersine çeviriyor ve somut bir kullanım veriyor:

> **R4:** *"`mcpTool`'u **dış bir API çağırmak** için kullan — bir DSO'nun yanıt süresi API'si, ya da **§19 Abs. 2 iki-ay saatini hesaplamak için bir Alman resmî tatil API'si.** Bu, custom kodlanmış bir HTTP callout'u declarative bir MCP tool'a çeviriyor. Neredeyse kimsenin göndermediği bir platform yeteneği."*

**Ama N-01 bunu büyük ölçüde gereksiz kılıyor:** R3 `BusinessHours` standart nesnesini gösterdi — tatil hesabı için dış API'ye gerek yok.

**KARAR: ❌ RED.** R4'ün örneği `BusinessHours` tarafından çözülmüş bir problemi çözüyor. Ve *"declarative HTTP callout"* iddiası, dört hakemden üçünün "use case arayan çözüm" değerlendirmesini değiştirmiyor.

---

# ⚠️ Hakemlerde yakaladığım hatalar

Defterin dürüst kalması için, hakemlerin de yanıldığı yerler:

### R4-hata-1 · JSON kaçış tavsiyesi yanlış
> **R4:** *"`AgentActionResult` yapıcısında tüm string alanları `String.escapeSingleQuotes()` VE `String.escapeHtml4()`'ten geçir."*

**İkisi de yanlış araç.**
- `escapeSingleQuotes()` **SOQL injection** içindir, JSON için değil
- `escapeHtml4()` Alman umlaut'larını HTML entity'lerine çevirir — `ü` → `&uuml;` — yani **çıktıyı bozar**

Doğrusu: Apex `@InvocableVariable`'ları zaten otomatik serialize ediyor ve kaçışı kendi yapıyor. R4'ün altını çizdiği **risk gerçek** (JSON parse hatası → sessiz planner hatası), ama **çözümü değil**. Bunu bir test vakasıyla doğrulayacağım: içinde tırnak, ters bölü ve umlaut olan Almanca metin döndüren bir aksiyon.

### R4-hata-2 · `with sharing` mekanizması karışık
`WITH USER_MODE` sınıf sharing bildiriminden bağımsız çalışır. Tavsiye doğru, gerekçe değil *(N-11'de düzeltildi)*.

### R4/araştırma çelişkisi · Data Library Max Tokens
R4 **4.096** (maksimum) diyor, benim araştırmam Salesforce'un resmî grounding rehberinden **1.200** buldu — ve gerekçesi vardı: embedding modelinin sequence uzunluğu.

**🔬 DOĞRULA.** İkisi de mantıklı gerekçe veriyor. Data Library'ye geçilirse ölçülecek.

### R1-hata · "Referans sayfası yok ⇒ sandbox-only"
Non-sequitur, ilk deftere kaydedilmişti. ❌ RED olarak duruyor.

### R5-hata-1 · CPQ'yu wow listesinin başına koyuyor ❌ RED
> **R5:** *"Apex destekli CPQ aksiyonu + deterministik test harness'ı — **wow #1**, tek
> geliştirici için fizibilite: **Yüksek**."*

**Dört hakem oybirliğiyle CPQ'yu kes dedi**, ve gerekçeleri kanıta dayanıyordu: CPQ 27 Mart
2025'te end-of-sale, API'si sadece Apex, ve tek public üretim hesabı (360Learning) **%50'nin
üzerinde `Unable to lock rows`** raporluyor. R4 bunu *"zamanının %30'unu yer, sıfır getiri"*
diye özetledi.

R5 bunların hiçbirine değinmiyor — muhtemelen §2.3 ve §15.5'i görmediği için. **Reddediliyor.**

### R5-hata-2 · Güvenlik facade'ının içinde SOQL injection açığı ❌ RED
```apex
public static List<SObject> safeQuery(String soql, ...) {
    List<SObject> rows = Database.query(soql);   // ← ham string
```
Güvenliği uygulamak için yazılmış sınıfın kendisi **dinamik SOQL enjeksiyon vektörü**. R5
bunu 6. bölümde kabul ediyor (*"asla ham kullanıcı girdisini soql string'ine geçirme"*) ama
**kod yine de öyle yapıyor.**

Mevcut Selector desenim zaten bunu çözüyor: sorgular statik, `WITH USER_MODE` ile.

### R5-hata-3 · Reflection tabanlı dispatch Agentforce için yanlış ❌ RED
`invokeAction(className, methodName, payload)` → `Type.forName().newInstance()`.

**Agentforce zaten `@InvocableMethod`'u doğrudan çağırıyor.** Araya bir dispatcher koymak,
platformun kendi mekanizmasını devre dışı bırakıp yerine kırılgan bir reflection katmanı
koyuyor — ve `@InvocableVariable` description'larının reasoning engine'e ulaşmasını da
engelliyor *(ki N-13'e göre routing'in çalışması tam olarak onlara bağlı)*.

Ayrıca mevcut dört katmanlı mimarime beşinci bir katman ekliyor.

**Alınan:** takılabilir `SecurityChecker` *(N-25)*. **Reddedilen:** facade + reflection.

### R5-hata-4 · "Ağır işler için İngilizce'ye düş" ❌ RED *(3-1)*
> **R5:** *"Almancayı UI/diyalog ve küçük testler için kullan; ağır retrieval/LLM işleri için
> **İngilizce fallback** tut."*

**R4 bunu doğrudan çürütüyor:** *"LLM içeride dil değiştirmiyor; **gördüğü dille yönlendirme
yapıyor.**"* R2 de aynı yönde şüphe belirtmişti. Karışık dil, routing doğruluğunu düşürüyor
— tam da kaçınmak istediğimiz şey.

**N-13 geçerli kalıyor: her şey Almanca.**

---

# Dört hakemin **oybirliğiyle** uzlaştığı

| | R1 | R2 | R3 | R4 |
|---|---|---|---|---|
| Kapsamı sert kes | ✓ | ✓ | ✓ | ✓ |
| **Faz 0'ı bugün doğrula** | ✓ | ✓ | ✓ | ✓ |
| CPQ'yu kes | ✓ | ✓ | ✓ | ✓ |
| Adversarial refutation'ı kes | ✓ | ✓ | ✓ | ✓ |
| Agent-to-agent'ı kes | ✓ | ✓ | ✓ | ✓ |
| G1 form metriklerini atla | ✓ | ✓ | ✓ | ✓ |
| CI kapısını böl | ✓ | ✓ | ✓ | ✓ |
| Ham PDF indexleme | ✓ | ✓ | ✓ | ✓ |
| Mimari sınır doğru | ✓ | ✓ | ✓ | ✓ *("strongest architectural claim")* |
| **Blast-radius = wow #1** | ✓ | ✓ | ✓ | ✓ |
| §6 Abs. 4 köprüsü üst sırada | #1 | #2 | #3 | #2 |
| FLS güvenlik testi şart | ✓ | ✓ | ✓ | ✓ |
| Tek komutluk yeniden üretim | ✓ | ✓ | — | ✓ |

**Dört bağımsız hakemin oybirliği, bu maddelerde tartışmayı kapatıyor.**

---

# Nihai v1 kapsamı

**Nesneler (3 çekirdek):** `Ladestandort__c` · `Ladepunkt__c` · `Compliance_Frist__c`
Mevcut: `Reseller__c`. Köprü için: `THG_Meldung__c` + junction.
**Ertelenen:** `Netzbetreiber__c`, `Netzanschluss_Antrag__c`, `Foerderantrag__c`, Data Library (v2)
**Kesilen:** tüm CPQ

**Apex:** ~12 sınıf, hepsi `with sharing`, hepsi bulk, hepsinin testi
**Agent:** 3 subagent, ≤4 aksiyon, **hepsi Almanca** *(N-13)*
**İlk aksiyon:** `ResolveRecordId` *(N-02)*
**Eval:** PR'da 3 deterministik natif · platform dışı harness'ta 20 Almanca vaka
**Çekirdek:** R2'nin beş düşman utterance'ı + R4'ün çift olumsuzlaması

**Wow sırası (dört hakemin uzlaştığı):**
1. Blast-radius Escalation Gap CI'da
2. §6 Abs. 4 çapraz rejim köprüsü
3. `Works_Council_Compliance_Mode` toggle *(R3)*
4. Zaman yolculuğu demo modu *(R3)*
5. Sparmodus / kredi düşüşü *(R4)*

---

# Hafta 1 — dört hakemin uzlaştığı plan

R4'ün günlük planı, diğerlerinin tavsiyeleriyle birleştirilmiş:

| Gün | İş | Amaç |
|---|---|---|
| **1** | Agentforce'u aç. `sf agent test list` koş. **Çıktıyı ham haliyle `PHASE0_VERIFICATION.md`'ye yaz.** | Hata verirse dur ve planı değiştir |
| **2** | `DateUtils.eichfristEnde` + unit testleri *(R2'nin kodu, `BusinessHours` ile revize)* | Kredi tüketmeyen deterministik çekirdek |
| **3** | `THGService.pruefeEichrechtErklaerung` — **§6 Abs. 4 köprüsü** + testler | Kahraman mantık |
| **4** | `PruefeEichrechtErklaerungAction` sarmalayıcısı, **`with sharing`** ile. Deploy. *Agent script yok.* | Apex tarafı bitti |
| **5** | Tek subagent, tek aksiyonluk dummy agent. Publish. `sf agent preview --prompt "Können wir die THG-Meldung einreichen?"` | **Dikey dilim doğrulaması** |

> **R4:** *"5. gün çalışırsa, tüm dikey yığının (veri modeli → DateUtils → Apex aksiyon → agent çağrısı) sağlam olduğunu kanıtlamışsın. Geri kalan her şey o dilimi ölçeklemek. **5. gün başarısız olursa sadece bir hafta kaybettin** — ve yedeğin Apex servisi + LWC dashboard'u, ki o bile Alman enerji şirketi için ilk %1'lik portfolyo parçası."*

---

# Özet

| Statü | Adet |
|---|---|
| ✅ KABUL | 76 |
| ⚔️ ÇELİŞKİ (açık) | 1 *(X-10, `Reseller__c` → `Account`)* |
| 🔬 DOĞRULA | 5 |
| ⏸️ ERTELE | 5 |
| ❌ RED | 7 |
| 👤 SENİN | 2 *(S-01 sıralama, G-02 CPQ)* |

**Beş hakem, on altı noktada çelişti. On beşini çözdüm.**

Ölçek: ilk tasarımın **yaklaşık dörtte biri.**

## Hakem kalitesi — dürüst değerlendirme

| | Kabul | Red | Not |
|---|---|---|---|
| R1 | 34 | 1 | Kapsam kesme ve gerçek kod hatası |
| R2 | yüksek | 0 | Çalışan kod, beş düşman utterance |
| R3 | yüksek | 0 | **Mimari delik + `BusinessHours` + hibernasyon** |
| R4 | yüksek | 2 | En derin teknik, ama iki hatalı tavsiye |
| R5 | **2** | **4** | Dokümanı görmemiş, CPQ'yu merkeze koymuş — ama iki fikri gerçekten yeni |

R5 düşük isabetli ama **sıfır değil**: repo-tabanlı retriever, dört hakemin dört farklı
şekilde çözmeye çalıştığı grounding problemini tek hamlede kapattı. Zayıf bir hakemin bile
bir fikri planı değiştirebiliyor — defterin işe yaradığının kanıtı.

## Senin vereceğin iki karar

1. **S-01** — Motor önce mi, agent önce mi? *(R4'ün stratejik itirazı)*
2. **G-02** — CPQ: kes / ayrı projeye taşı / ince tut?

## Beşinci hakeme sorulacak

1. **S-01** — R4'ün "3 dakika" gözlemi doğruysa, agent-merkezli plan hâlâ doğru mu?
2. **X-10** — `Reseller__c` `Account` olmalı mıydı? 108 testi yeniden yazmaya değer mi?
3. **N-11** — `with sharing` + `WITH USER_MODE` etkileşiminin gerçek semantiği ne?
4. Ve: **dört hakem de ne kaçırdı?**
