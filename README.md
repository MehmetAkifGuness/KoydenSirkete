# Müdür

Android-first, tamamen offline kariyer ve şirket simülasyonu.

## Kesin çalışma sınırı

- APK kurulduktan sonra internet, hesap, Google Play Games, backend veya Docker gerekmez.
- Uygulama uçak modunda çalışır.
- Oyun kuralları cihazdaki Dart `domain/application` katmanında çalışır.
- İlerleme SQLite veritabanında cihazda saklanır.
- Android manifestinde `INTERNET` izni yoktur.

## Teknoloji

- Flutter + Dart
- SQLite + sqflite
- Material 3
- Feature-first klasörleme
- SOLID bağımlılık yönü: presentation → application → domain ← data adapter

## v0.1.0 kapsamı

- Tek oyuncu kaydı
- Para, enerji, bilgi, tecrübe
- Para kazanma eylemi ve günlük azalan kazanç
- Dinlenme ve enerji yenileme
- Ücretsiz pratik, standart kurs ve yoğun eğitim
- Gün/saat ilerlemesi
- Yerel kayıt ve kayıt şema sürümü

## v1.0.0 kapsamı

- Onboarding ve yerel yeni oyun sıfırlama
- Dokunma mini oyunu ve performans bonusu
- İş ilanları, çalışma görevleri, maaş ve performans
- Kariyer yolu ve terfi
- Şehir değişimi ve günlük yaşam giderleri
- Şirket kurma, çalışan alma ve proje yönetimi
- SQLite v2-v7 geriye dönük migrasyonları

## v1.0.1 stabilizasyonu

- Yerel kayıt hatalarında tekrar deneme ekranı
- Kontrollü kayıt hatası mesajları

## v1.1.0 içerik genişletmesi

- Finans kariyer hattı ve yeni iş ilanları
- Finans/lojistik çalışma görevleri
- Uzmanlık eğitimi
- Sahil kenti ve Teknoloji vadisi

## v1.2.0 günlük hedefler

- Her oyun gününde üç üretken aksiyonluk günlük hedef.
- Hedef tamamlanınca cihazda saklanan ₺120 ödül.
- Kazanç, çalışma ve eğitim aksiyonlarının günlük takibi.

## v1.3.0 ilerleme sistemi

- Toplam kazanç, görev, eğitim ve proje istatistikleri.
- Tek seferlik ödüllü başarılar.
- Profil üzerinden başarı ve ilerleme ekranı.

## v1.4.0 şirket derinliği

- Üç şirket seviyesi ve çalışan kapasitesi.
- Seviye bazlı üç proje türü.
- Proje maliyeti, ödülü, ilerleme hızı ve deneyim kazanımı.

## v2.0.0 offline gerçek zamanlı sürüm

- Yalnızca foreground'da ilerleyen oyun saati: 20 gerçek saniye = 1 oyun saati.
- Eş zamanlı aktivite, gerçek her 60 saniyede 10 enerji yenilenmesi ve sporla 1000'e kadar maksimum enerji.
- Uygulama kapalıyken de enerji açılışta geçen gerçek süreye göre tamamlanır.
- 10 mesleki yetenek, 1000 üst sınır, çoklu yetenek eğitimleri ve göreve göre süre/enerji verimliliği.
- Türkiye'nin 81 ili, 2025 ADNKS nüfuslarıyla nüfusa bağlı teknoloji, ekonomi, maaş ve iş fırsatları.
- 20 rol, cihaz içinde seed tabanlı gizli bot rekabeti ve günlük başvuru sonucu.
- Ayrı `İşim` ve `Şirketim` ekranları; her oyun gününde değişen işveren görevleri.
- İki oyun günü görev başlatılmadığında yalnızca foreground gün geçişinde işten çıkarılma.
- SQLite şema v23; eski kayıtlar sıfırlanmadan okunur. Para 24 oyun saati boyunca negatif kalırsa iflas sistemi devreye girer. Aktif işlerde 50 TL bedelli, bekleme süresi olmayan 20 dilimli Esnaf Çarkı kullanılabilir.

## v2.1.0 ekonomi tutarlılığı ve sadeleştirme

- Şehir maaş katsayısı ilan, işe giriş, terfi, şehir değişikliği ve eski kayıt yükleme akışlarının tamamında uygulanır.
- Yaşanılan şehirde sahip olunan ev günlük kirayı kaldırır.
- Sahip olunan araç şehirler arası taşınma maliyetini araç seviyesine göre düşürür.
- Kullanılmayan kayıt alanları ve sahte tema seçenekleri kaldırıldı; merkezi sınıflar sorumluluklarına ayrıldı.

## v2.2.0 varlık ekonomisi

- Ev sahipliği hem gerçek kira hesabında hem şehir kartlarında aynı kuralla değerlendirilir.
- Ev ve arabalar onay sonrasında alış fiyatının %70'i karşılığında satılabilir.
- Şehir maaş katsayısı dengeli `0.95–1.25x` aralığına indirildi.

## v2.3.0 ev ve proje dengesi

- Yaşanılan şehirde boş tutulan ev günlük konut giderini kaldırır.
- Ev fiyatları sabit olarak ₺200.000, ₺400.000 ve ₺600.000 seviyelerine getirildi.
- Şirket kurulduğunda tüm proje türleri seçilebilir; proje değişiminde mevcut ilerleme onayla sıfırlanır.

## v2.4.0 okunabilirlik ve hareket

- Ana, ikincil ve soluk metin renkleri koyu yüzeylerde en az `4.5:1` kontrast sağlayacak şekilde yenilendi.
- Yüzeyle aynı olan ikincil vurgu rengi, okunabilir açık mavi vurguya dönüştürüldü.
- Alt sekmeler, özellik sayfaları, ekran durumları, kartlar ve ilerleme çubukları akıcı geçişlerle güncellendi.
- Sistem animasyonları kapatıldığında hareket efektleri otomatik devre dışı kalır.

## v2.5.0 finans ve uzun vadeli büyüme

- Son 30 günlük gerçek para hareketlerini kategori bazında saklayan Finans ekranı.
- Konut, yemek, fatura, ulaşım, kiralık ev bakımı ve kira gelirinden oluşan günlük bütçe.
- Gelire göre yumuşak yaşam standardı artışı ve en fazla %25'e çıkan kontrollü enflasyon.
- Aylık ev fiyatının %1'i brüt kira ve %8 bakım sonrası net getiri.
- Şirket değerlemesi, itibar, pazar payı, altı büyüme hedefi ve üç büyük sözleşme.
- Ev, kiralama ve şirket büyümesi dahil 12 ödüllü başarı.
- SQLite v25 geriye dönük kayıt geçişi.
- Şehir giderleri ₺90–₺1.000, maaş katsayısı `0.95–1.25x` aralığına dengelendi.
- Şirket kuruluşu ₺15.000; seviye yatırımları ₺25.000/₺75.000 yapıldı ve çalışansız pasif gelir kaldırıldı.
- Bayi yatırımları 60–220 oyun günlük geri dönüş aralığına taşındı.

## v2.6.0 şirket stratejisi

- Her projede net ödül, başarı ihtimali, önerilen şirket seviyesi ve tahmini süre birlikte gösterilir.
- Operasyon, satış, finans, teknoloji, lojistik ve liderlik uzmanlıkları proje hızını ve riskini etkiler.
- Proje başarısızlığında işletme maliyeti şirket kasasından düşer.
- Şehir ekonomisine uygun çalışanlar bayi gelirine günlük uzmanlık katkısı sağlar.
- Bayiler şirket seviyesiyle sınırlı olarak seviye 3'e yükseltilebilir; kapasite ve gelir her seviyede artar.

## v2.7.0 çalışan gelişimi ve görev çeşitliliği

- Merkez ve bayi çalışanları şirket bütçesiyle eğitilerek kalıcı +5 performans kazanabilir.
- Eğitim maliyeti performansla birlikte artar ve gelişim 100 performansta tamamlanır.
- Gelişen çalışanlar projeleri hızlandırır, başarı ihtimalini ve bayi üretkenliğini yükseltir.
- İşverenlerin günlük görev havuzu 12 şablona ve 4–6 seçeneğe genişletildi.

## v2.8.0 piyasa, rakipler ve ekip bağlılığı

- Yedi günde bir değişen altı piyasa koşulu şirket gelirini ve personel maliyetini etkiler.
- Dört kurgu rakip; ekip gücü, şirket seviyesi, bayiler ve tamamlanan projeler üzerinden günlük rekabet oluşturur.
- Moral çalışanların etkin performansını, sadakat ise ayrılma riskini belirler.
- Proje ve pazar başarısı morali değiştirir; çalışan geliştirme performans, moral ve sadakati birlikte yükseltir.
- Şirket ekranında piyasa dönemi, günlük kasa etkisi, rakip güçleri ve ekip riskleri görünür.
- Eski SQLite v25 kayıtları yeni alanlar için güvenli varsayılanlarla açılır.

## v2.9.0 kişisel ve şirket finansı

- Kişisel cüzdan; maaş, ek kazanç, kira geliri ve yaşam giderlerini yönetir.
- Şirket kasası; çalışan, proje, bayi, piyasa ve şirket yatırımlarını yönetir.
- Oyuncu kişisel cüzdandan şirkete sermaye aktarabilir ve şirketten %10 vergili kâr payı çekebilir.
- Transferler ve tüm şirket hareketleri Finans ekranında kişisel hesaptan ayrı izlenir.
- Şirket ekranındaki maliyet ve ödüllerde paranın hangi hesaptan çıktığı açıkça gösterilir.
- Mevcut SQLite v25 kayıtları yeni hesap etiketi bulunmadığında kişisel hesap varsayımıyla açılır.

## v2.10.0 piyasa rekabet sezonu

- Şirketler 30 oyun günlük sezonlarda dört kurgu rakibe karşı sıralanır.
- Her günlük piyasa galibiyeti 3 sezon puanı kazandırır; sonuçlar şirket ekranındaki canlı tabloda gösterilir.
- İlk üç sıra şirket kasasına ₺6.000, ₺3.000 ve ₺1.500 sezon ödülü getirir.
- Şampiyonluklar şirket değeri, itibarı ve pazar payını kalıcı olarak geliştirir.
- Sezon verileri SQLite v26 içinde saklanır; eski kayıtlar mevcut oyun gününün sezonundan devam eder.

## v2.11.0 şirket aşamaları

- Şirketler yerel girişim, bölgesel şirket, ulusal marka ve holding aşamalarında ilerler.
- Para tek başına yeterli değildir; itibar, pazar payı, ekip kalitesi, çalışan, bayi ve sezon sonuçları birlikte değerlendirilir.
- Ulaşılan aşama gerilemez ve şirket ekranındaki yol haritasında tüm gereksinimler canlı gösterilir.
- Eski kayıtlar mevcut şirket verilerinden otomatik değerlendirilerek SQLite v27'ye yükseltilir.

## v2.12.0 stratejik bölgeler

- 81 şehir Marmara, Ege, Akdeniz, İç Anadolu, Karadeniz, Doğu Anadolu ve Güneydoğu Anadolu bölgelerine ayrılır.
- Bir bölgedeki bayi seviyeleri toplamı 4 olduğunda o bölgenin özel şirket avantajı açılır.
- Bölge avantajları bayi geliri, maaş, yatırım, proje, piyasa ve çalışan morali üzerinde gerçek etki oluşturur.
- Pazar payı artık tüm şehirleri doldurmak yerine seçilen bölgelerde yoğunlaşmayı ödüllendirir.
- Şube ekranı bölge ilerlemesini, açılan avantajları ve stratejik şehir seçeneklerini birlikte gösterir.

## v2.13.0 satın alma ve birleşmeler

- Şirket ekranında iki satın alma, iki birleşme ve iki rakip pazar payı devri bulunur.
- İşlemler aşama, bölge ve sezon başarısına göre açılır; maliyet yalnızca şirket kasasından ödenir.
- Tamamlanan teklifler şirket değerini, itibarını ve pazar payını kalıcı artırır ve tekrar satın alınamaz.
- İşlem geçmişi SQLite v28'de saklanır; eski kayıtlar veri kaybı olmadan yükseltilir.

## v2.14.0 kupa geçmişi ve avantajlar

- Şampiyonluk kupaları sezon, puan ve ödül bilgileriyle kalıcı geçmişte saklanır.
- 1, 3, 5 ve 8 kupa eşiklerinde proje, bayi geliri, bayi maaşı ve rekabet gücü avantajları açılır.
- Bonuslar düşük sabit oranlarla sınırlandırılır; yeni gelir kaynağı oluşturmak yerine mevcut şirket sistemlerini güçlendirir.
- Eski kayıtlardaki şampiyonluk sayıları aktarılan kupa olarak korunur.

## v2.15.0 devam eden kariyer puanı

- Kişisel kariyer, şirket gücü, stratejik miras ve varlıklar ayrı puan kategorileri olarak hesaplanır.
- Yedi kariyer unvanından sonra her 5.000 puanda yeni bir prestij seviyesi açılır; sabit bir oyun sonu bulunmaz.
- Çalışma, eğitim ve proje serileri tekrar eden hedefler üretirken bölgeler, anlaşmalar ve kupalar uzun vadeli puan sağlar.
- Kariyer özeti mevcut kayıttan anlık hesaplandığı için eski ilerlemeler otomatik olarak doğru puanı alır.

## v2.16.0 rakip şirket profilleri

- Dört rakibin lideri, karakteri, sektör uzmanlığı, güçlü yönü ve zayıflığı birbirinden farklıdır.
- Uzmanlık eşleşmeleri ile rakibe özel güçlü/zayıf piyasa koşulları günlük gücü ve sezon sonuçlarını etkiler.
- Aktif profil etkisi günlük piyasa kartında, tüm rakiplerin stratejik özellikleri şirket ekranında görünür.
- Rakip davranışı deterministik kaldığı için aynı kayıt ve oyun gününde aynı sonuç yeniden üretilebilir.

## v2.17.0 rakip şirket ilerlemesi

- Rakiplerin bayi, çalışan, şirket kasası, tamamlanan proje ve aktif proje verileri sezon boyunca gelişir.
- Her rakibin büyüme odağı ve gelişim hızı karakteriyle uyumlu, birbirinden farklı bir şirket yapısı üretir.
- Sezon başından itibaren oluşan tüm sayısal değişimler rakip şirket takip kartlarında görünür.
- Operasyonel büyüme sezon gücüne kontrollü katkı sağlar; aynı kayıt ve oyun gününde aynı sonuç korunur.
- Rakip ilerlemesi mevcut veriden hesaplandığı için yeni kayıt alanı veya veritabanı migrasyonu gerekmez.

## v2.18.0 sezon piyasa kuralları

- Her 30 günlük sezonda talep patlaması, yüksek enflasyon, personel krizi veya teknoloji dönüşümü ana kuralı uygulanır.
- Sezon kuralı gelir ve maaşları etkilerken yedi günlük kısa piyasa olayları değişmeye devam eder.
- Avantajlı uzmanlığa sahip oyuncu ekibi ve rakip şirket aynı +5 rekabet gücünü kazanır.
- Rakip şirket finansı ve proje ilerlemesi aktif sezon koşuluna göre gelişir.
- Aktif kuralın tüm etkileri piyasa ve sezon kartlarında işlem öncesinde görünür.

## v2.19.0 sezon stratejileri

- Her sezon proje, fiyat, kalite veya büyüme stratejilerinden biri seçilebilir.
- Stratejiler rakibin uzmanlığına ve şirketin proje, nakit, ekip veya bayi hazırlığına göre kontrollü rekabet gücü sağlar.
- Güç avantajları gelir marjı veya maaş yüküyle dengelenir ve tüm etkiler seçimden önce gösterilir.
- Seçim sezon boyunca kilitlenir, kayıtla birlikte saklanır ve yeni sezon başladığında sıfırlanır.

## v2.20.0 dereceye bağlı sezon ödülleri

- Birincilik kupa, ikincilik sonraki sezon %8 gelir sponsorluğu, üçüncülük tek kullanımlık özel proje daveti ve dördüncülük kalıcı 5 itibar verir.
- Davet, yalnızca hak kazanıldığında seçilebilen özel dönüşüm projesi sonuçlanınca tüketilir.
- Aktif haklar, derece tablosu ve son sezon ödülleri şirket ekranında birlikte gösterilir.
- Ödül geçmişi mevcut rekabet JSON kaydında tutulduğu için SQLite v28 ve eski kayıt uyumluluğu korunur.

## v2.21.0 dengeli sezon olay havuzu

- On altı piyasa olayı fırsat, tehdit, iş gücü ve dengeli olmak üzere dört kategoriye ayrılır.
- Her sezon beş benzersiz olay içerir; dört kategori garanti edilir ve beşinci olay deterministik olarak değişir.
- Olay sırası sezonlara göre karışır ve sezon sınırında aynı olay art arda gelemez.
- Aktif olay ile sezonun tüm olay takvimi gün aralıkları ve ekonomik etkileriyle şirket ekranında gösterilir.
- Takvim kayıt alanı kullanmadan oyun günü ve sezon numarasından yeniden üretilebilir.

## v2.22.0 sezon geçmişi

- Tamamlanan sezonların sıralaması, puanı, galibiyet/mağlubiyet sayısı ve tüm ödülleri kalıcı olarak saklanır.
- Şirket ekranından açılan geçmiş sayfası sezonları yeniden eskiye gösterir; en iyi derece ve toplam para ödülünü özetler.
- Kayıtlar mevcut rekabet JSON verisinde tutulur ve eski oyun kayıtları boş geçmişle güvenle açılır.

## Çalıştırma

```powershell
cd mobile
flutter pub get
flutter run
```

APK:

```powershell
flutter build apk --release
```

Mağaza dağıtımı için `mobile/android/key.properties.example` dosyasını `key.properties` olarak kopyalayıp gerçek release keystore bilgilerini girin. Bilgi yoksa release derlemesi yalnızca yerel test için debug imzasıyla oluşturulur.
