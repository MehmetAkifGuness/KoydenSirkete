# Changelog

## 2.5.0

- Son 30 günü kategori bazında saklayan kalıcı finans günlüğü ve Finans ekranı eklendi.
- Konut, yemek, fatura, ulaşım, kira geliri ve kiralık ev bakım giderleri günlük bütçede ayrıştırıldı.
- Gelire bağlı yaşam standardı yumuşatıldı; enflasyon artışı aylık %1 ve en fazla %25 olacak şekilde dengelendi.
- Şirket değerlemesi, itibar, pazar payı, altı uzun vadeli hedef ve üç büyük sözleşme eklendi.
- Ev, kiralama ve şirket büyümesine bağlı başarı kataloğu 12 hedefe genişletildi.
- SQLite kayıt şeması finans geçmişi için v25'e yükseltildi.
- Esnaf Çarkı 20 dilime çıkarıldı: 7 boş, 5 adet -50 TL, 3 adet -100 TL ve istenen ödül dağılımı uygulandı.
- Hızlı görev ödülü 10 doğruda ₺150, 11 doğruda ₺165 olacak ve en fazla ₺300 temel ödüle ulaşacak şekilde dengelendi.

## 2.4.0

- Koyu tema metin ve vurgu renkleri erişilebilir kontrast için yenilendi.
- İkincil vurgu renginin yüzeyle aynı olması nedeniyle kaybolan metin ve ikonlar düzeltildi.
- Alt navigasyon, uygulama durumları ve sayfa açılışlarına fade/slide/scale geçişleri eklendi.
- Kart ve ilerleme değişimleri animasyonlu hale getirildi; azaltılmış hareket tercihi desteklendi.

## 2.3.0

- Ev sahipliği tüm şehirlerde günlük kişisel gider muafiyeti sağlayacak şekilde güncellendi.
- Ev fiyatları ₺200.000, ₺400.000 ve ₺600.000 olarak sabitlendi.
- Tüm şirket projeleri ilk şirket seviyesinde açıldı; proje değişiminde ilerleme güvenli biçimde sıfırlanır.

## 2.2.0

- Şehir kartlarındaki kira göstergesi gerçek kira hesabıyla ortaklaştırıldı; ev sahibi olunan her şehir doğru biçimde kira muaf gösterilir.
- Ev ve araba satışları, onay ekranı ve %70 ikinci el değeriyle eklendi.
- Şehir maaş katsayısı `0.90–1.50x` aralığına dengelendi; kayıtlı istihdam maaşları açılışta yenilenir.

## 2.1.0

- Şehir maaş katsayısı ilan, işe giriş, terfi, taşınma ve eski kayıt yükleme akışlarında ortaklaştırıldı.
- Ev sahipliğinin günlük kirayı kaldırması ve araç sahipliğinin taşınma maliyetini düşürmesi doğrulandı.
- Varlık etkileri şehir ve iş ekranlarında görünür hale getirildi.
- Kullanılmayan kalıcı alanlar ve sahte tema seçenekleri kaldırıldı.
- Merkezi oturum sınıfları sorumluluklarına ayrıldı; kod tabanı standart Dart biçimine getirildi.

## 2.0.0

- Foreground gerçek zamanlı saat eklendi: 20 gerçek saniye = 1 oyun saati; arka planda zaman ilerlemiyor.
- Tekil aktif aktivite, enerji yenilenmesi, spor ve 200 maksimum enerji sınırı tamamlandı.
- Genel bilgi korunarak 10 yetenekli eğitim/verimlilik sistemi eklendi.
- 81 Türkiye ili, şehir ekonomisi, maaş katsayısı ve fırsat kataloğu eklendi.
- 20 rol, gizli seed tabanlı bot rekabeti ve günlük başvuru bekleme kuralı eklendi.
- `İşim` ve `Şirketim` ekranları ayrıldı; günlük dinamik işveren görevleri ve iki günlük devamsızlıkta kovulma eklendi.
- SQLite şeması v10'dan v17'ye geriye dönük migration'larla genişletildi; 24 oyun saatlik iflas kontrolü, eğitim filtreleme ekranı ve sınırlı Esnaf Çarkı eklendi.

## 1.5.0–1.9.0

- Gerçek zamanlı aktivite temeli, spor, yetenekler, şehir ekonomisi, kariyer rolleri ve bot başvuruları aşamalı olarak uygulandı.

## 1.4.0

- Şirket seviyeleri, çalışan kapasitesi ve yükseltme sistemi eklendi.
- Üç farklı şirket projesi ve seviye bazlı proje kilitleri eklendi.
- Tamamlanan proje sayısı ve şirket ilerleme istatistikleri kaydediliyor.

## 1.3.0

- Toplam kazanç, çalışma, eğitim ve proje istatistikleri eklendi.
- Tek seferlik ödüllü başarı sistemi eklendi.
- Profil ekranına ilerleme ve başarılar ekranı eklendi.

## 1.2.0

- Günlük üretkenlik hedefi eklendi.
- Günlük hedef ödülü tek seferlik ve yerel olarak kaydediliyor.
- Eğitim aksiyonları günlük takip sistemine bağlandı.

## 1.1.0

- İkinci finans kariyer hattı ve yeni iş ilanları eklendi.
- Finans, lojistik ve uzmanlık görevleri eklendi.
- Uzmanlık programı eğitimi eklendi.
- Sahil kenti ve Teknoloji vadisi şehirleri eklendi.
- Yerel iş, eğitim ve şehir katalogları v2 oldu.

## 1.0.1

- Yerel kayıt okuma hataları için tekrar deneme ekranı eklendi.
- Oyun eylemlerindeki kayıt hataları kullanıcıya kontrollü şekilde gösteriliyor.
- Flutter tarafından üretilen geçici dosyalar Git dışında tutuldu.

## 1.0.0

- Tamamen offline oynanabilir ilk tam sürüm tamamlandı.
- Onboarding, yerel yeni oyun sıfırlama ve SQLite v2-v7 migrasyonları eklendi.
- İş görevleri, maaş, performans, kariyer/terfi, şehir giderleri ve şirket yönetimi tamamlandı.
- Eski kayıtların korunması için geriye dönük varsayılanlar eklendi.

## 0.3.0

- Sürümlü offline iş kataloğu eklendi.
- Bilgi ve tecrübe gereksinimleriyle başvuru uygunluğu eklendi.
- Aktif iş SQLite v2 migration ile cihazda saklanıyor.

## 0.2.0

- 8 saniyelik dokunma tabanlı para kazanma mini oyunu eklendi.
- Seri performansına göre %10, %20 ve %35 bonus kademeleri eklendi.
- Mini oyun ödülü mevcut enerji, zaman ve günlük kazanç kurallarına bağlandı.

## 0.1.0

- Tamamen offline Flutter/Dart uygulama çekirdeği oluşturuldu.
- SQLite/sqflite yerel kayıt eklendi.
- Para kazanma, dinlenme, enerji ve zaman kuralları eklendi.
- Üç eğitim seçeneği ve bilgi/tecrübe kazanımı eklendi.
- Application service ve repository portlarıyla SOLID bağımlılık yönü kuruldu.
