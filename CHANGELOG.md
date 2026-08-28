# Changelog

## 2.26.0

- Her proje için merkez çalışanlarından ayrı ekip kurma ve çalışan atama sistemi eklendi.
- Yalnızca projeye atanan çalışanlar ilerleme, başarı, gecikme ve kalite hesaplarına katılır.
- Proje ekibi özeti çalışan sayısını, doğru uzman sayısını ve ortalama görev uyumunu gösterir.
- Boş bırakılan proje ekibi ilerlemeyi güvenle duraklatır; günlük şirket gelir ve maaş işlemleri devam eder.
- İşten çıkarılan çalışan tüm proje ekiplerinden temizlenir; yeniden işe alındığında eski atamalar kendiliğinden dönmez.
- Yapılandırılmamış eski kayıtlar tüm merkez çalışanlarını kullanarak önceki oynanışı korur.
- Proje ekipleri SQLite v30 ile kalıcı tutulur; codec, kayıt, hesap ve arayüz akışları hedefli testlerle doğrulandı.

## 2.25.0

- Merkez ve bayi çalışanları günlük işlerden, başarılı piyasa sonuçlarından ve gelişim eğitimlerinden deneyim kazanır.
- Başlangıç, uzman, kıdemli ve lider basamakları; deneyim, performans ve şirket bütçesi şartlı terfi sistemiyle eklendi.
- Çalışanlar deneyimlerine göre zam talep edebilir; kabul ve ret kararları maaş, moral, sadakat ve tükenmişliği etkiler.
- Piyasa baskısıyla artan tükenmişlik etkin çalışan gücünü düşürür; olumlu dönemler ve gelişim eğitimi toparlanma sağlar.
- Uzmanlığa dayalı görev uyumu aktif projelerin ilerleme hızını, gecikme riskini ve kalite sonucunu etkiler.
- Kıdem, deneyim, tükenmişlik, görev uyumu, terfi ve zam kararları merkez ile bayi ekranlarına eklendi.
- Yeni alanlar mevcut çalışan JSON kaydında tutulur; eski kayıtlar güvenli başlangıç değerleriyle açılır ve SQLite v29 korunur.
- Çalışan ilerlemesi, kayıt uyumluluğu, uzun dönem ekonomi ve merkez/bayi arayüzleri 80 otomatik testle doğrulandı.

## 2.24.0

- On beş şirket projesine müşteri türü, sözleşme teslim süresi ve temel gecikme riski eklendi.
- Aktif proje günleri kalıcı olarak izlenir; süre aşımı teslimat sonucunu doğrudan gecikmeli yapar.
- Ekip performansı, uzman çalışanlar, şirket seviyesi ve tahmini süre etkin gecikme olasılığını belirler.
- Tamamlanan projeler reddedildi, düşük, standart, yüksek veya mükemmel kalite sonucu üretir.
- Kalite ödül tutarını, gecikme ise ödülü ve kalite puanını etkiler; sonuç şirket finans hareketine yansır.
- Son proje sonucu ve aktif sözleşmenin müşteri, süre, gecikme ve kalite tahmini şirket ekranında gösterilir.
- Aktif gün ve son sonuç SQLite v29 migrasyonuyla saklanır; eski kayıtlar güvenli varsayılanlarla açılır.
- Katalog, sonuç kuralları, kayıt codec'i, ekonomi, sezon daveti ve arayüz 96 otomatik testle doğrulandı.

## 2.23.0

- Şirket proje kataloğu 7 projeden 15 projeye çıkarıldı.
- Projeler kısa, orta, büyük ve stratejik sözleşme olmak üzere dört kategoriye ayrıldı.
- Yeni projeler maliyet, ödül, risk, uzmanlık ve önerilen şirket seviyesi bakımından kademeli olarak dengelendi.
- Proje portföyü kategori başlıkları altında gruplandı ve sözleşme türü her proje kartında görünür hâle getirildi.
- Katalog bütünlüğü, kategori dağılımı ve mevcut proje seçim akışı hedefli otomatik testlerle doğrulandı.

## 2.22.0

- Tamamlanan rekabet sezonlarının sıralaması, puanı, galibiyet/mağlubiyet sayısı ve ödülleri kalıcı geçmişe eklendi.
- Sezon kapanışı geçmiş kaydını yalnızca bir kez oluşturur; en güncel 1000 sezon saklanır.
- Şirket ekranından açılan sezon geçmişi sayfası sonuçları yeniden eskiye sıralar ve özet istatistikleri gösterir.
- Geçmiş mevcut rekabet JSON verisinde tutulduğu için SQLite v28 ve eski kayıt uyumluluğu korundu.
- Sezon kapanışı, kayıt codec'i ve geçmiş ekranı hedefli otomatik testlerle doğrulandı.

## 2.21.0

- Piyasa olay havuzu 6 sabit olaydan fırsat, tehdit, iş gücü ve dengeli kategorilerindeki 16 olaya çıkarıldı.
- Her 30 günlük sezonda dört kategoriyi zorunlu olarak içeren beş benzersiz olay deterministik biçimde seçilir.
- Değişken beşinci olay ve sezona göre değişen sıra, aynı olay dizilerinin sık tekrar etmesini önler.
- Bir sezonun son olayıyla sonraki sezonun ilk olayının aynı olması engellendi.
- Yedi günlük olay dönemleri sezon başlangıcına hizalandı; son dönem sezon bitişinde taşmadan tamamlanır.
- Şirket ekranına aktif dönemi ve sezonun beş olayını gün aralıklarıyla gösteren olay takvimi eklendi.
- Havuz dengesi, 64 sezonluk çeşitlilik, tekrarsız sınırlar, ekonomik limitler, takvim kapsamı ve arayüz otomatik testlerle doğrulandı.
- Takvim oyun günü ve sezon numarasından hesaplandığı için SQLite v28 ve eski kayıt uyumluluğu korundu.

## 2.20.0

- Sezon derecelerine para ödülünden bağımsız kupa, sponsorluk, özel proje daveti ve itibar ödülleri eklendi.
- Birincilik mevcut kalıcı kupa ilerlemesini, ikincilik sonraki sezon tüm şirket gelirlerine %8 sponsor desteğini sağlar.
- Üçüncülük tek kullanımlık özel dönüşüm projesini açar; davet proje sonuçlandığında tüketilir ve tekrar kullanılamaz.
- Dördüncülük şirket aşamalarında kullanılan kalıcı 5 itibar kazandırır; beşincilik ek ödül sağlamaz.
- Her sezon sonucu ödül türü, derece, değer ve kullanım durumuyla rekabet kaydında saklanır; eski kayıtlar ek migrasyon olmadan açılır.
- Şirket ekranına aktif sponsor, kullanılabilir davet, sezon itibarı, derece tablosu ve son ödül geçmişi eklendi.
- Derece eşleşmeleri, tek seferlik kapanış, gelir süresi, itibar, davet tüketimi, kayıt güvenliği ve arayüz otomatik testlerle doğrulandı.

## 2.19.0

- Proje atağı, fiyat liderliği, kalite üstünlüğü ve büyüme hamlesi olmak üzere dört sezon stratejisi eklendi.
- Her strateji belirli rakip uzmanlığına karşı ek rekabet gücü sağlarken gelir veya maaş yüzdesinde dengeli bir bedel oluşturur.
- Proje geçmişi, şirket nakdi, ekip performansı ve bayi sayısı ilgili stratejinin hazırlık bonusunu belirler.
- Strateji sezon başına bir kez seçilir, sezon boyunca değiştirilemez ve yeni sezonda otomatik olarak sıfırlanır.
- Seçim rekabet sezonu JSON verisinde saklanarak SQLite v28 ve eski kayıt uyumluluğu korundu.
- Şirket ekranına avantaj, ekonomik bedel, hazırlık nedeni ve geri alınamaz seçim onayı eklendi.
- Strateji kataloğu, seçim kuralları, piyasa etkileri, kayıt uyumluluğu ve arayüz akışı otomatik testlerle doğrulandı.

## 2.18.0

- Rekabet sezonlarına talep patlaması, yüksek enflasyon, personel krizi ve teknoloji dönüşümü kuralları eklendi.
- Her ana kural 30 gün boyunca sabit kalır ve dört sezonluk deterministik sırayla tekrar eder.
- Sezon gelir ve maaş yüzdeleri, yedi günlük piyasa olaylarıyla kontrollü biçimde birleştirilir.
- Kuralın satış, finans, liderlik veya teknoloji uzmanlığına sahip oyuncu ekibi ve rakibi eşit +5 rekabet gücü kazanır.
- Sezon koşulları rakiplerin finansal büyümesine ve proje ilerlemesine de uygulanır.
- Aktif kural, açıklaması, ekonomik yüzdeleri, avantajlı uzmanlığı ve iki tarafın güç etkileri şirket ekranında görünür hâle getirildi.
- Sezon rotasyonu, ekonomik hesap, uzmanlık eşitliği, rekabet simülasyonu ve arayüz görünürlüğü otomatik testlerle doğrulandı.

## 2.17.0

- Rakip şirketlere birbirinden farklı bayi açma, işe alım, finans ve proje geliştirme hızları eklendi.
- Her rakibin bayi, çalışan, şirket kasası, tamamlanan proje ve aktif proje ilerlemesi sezon günüyle deterministik olarak hesaplanır.
- Sezon başından itibaren oluşan değişimler dört rakip kartında canlı olarak gösterilir.
- Rakiplerin büyüme odağı ve aktif proje yüzdesi, şirket takip ekranında profil özellikleriyle birlikte sunulur.
- Operasyonel ilerleme rakip gücüne en fazla 12 puan katkı sağlayarak sezon rekabetine gerçek ancak kontrollü etki eder.
- Yeni sistem kayıt alanı gerektirmediği için SQLite v28 ve mevcut oyun kayıtlarıyla uyumluluk korunur.
- Sezon sınırları, deterministik ilerleme, rakiplerin ayrışması, güç bonusu ve arayüz görünürlüğü otomatik testlerle doğrulandı.

## 2.16.0

- Dört rakibe benzersiz lider, karakter, sektör uzmanlığı, güçlü yön ve zayıflık profili eklendi.
- Her piyasa dönemine sektör kimliği verildi; uzmanlık eşleşmesi rakip gücüne kontrollü +4 katkı sağlar.
- Rakiplerin güçlü ve zayıf piyasa koşulları günlük rekabet skorunu ve deterministik sezon puanlarını doğrudan etkiler.
- Aktif rakibin profil etkisi piyasa kartında; dört rakibin tüm stratejik özellikleri ayrı profil panelinde görünür hâle getirildi.
- Profil kataloğu piyasa hesaplamasından ayrılarak mevcut servis API'si ve eski kayıt uyumluluğu korundu.
- Rakip profilleri, skor formülü, sezon simülasyonu ve profil arayüzü otomatik testlerle güvenceye alındı.

## 2.15.0

- İlerleme ekranına kişisel kariyer, şirket gücü, stratejik miras ve varlıklardan hesaplanan şeffaf kariyer başarı puanı eklendi.
- Yeni başlangıçtan holding mimarına uzanan yedi unvan seviyesi oluşturuldu.
- 20.000 puandan sonra her 5.000 puanda sonsuza kadar devam eden prestij basamakları açılır; oyun kesin bir bitiş ekranına dönüşmez.
- Çalışma, eğitim ve proje hedefleri tamamlandığında yeni döngüye geçerek tekrar puan hedefi üretir.
- Bölge hâkimiyeti, stratejik şirket işlemleri ve sezon kupaları uzun vadeli puan hedeflerine bağlandı.
- Puan dağılımı, sıradaki eşik ve puan kazandıran yakın hedefler kariyer özetinde birlikte gösterilir.
- Sistem mevcut kayıt verilerinden hesaplandığı için eski oyunlar ek migrasyon olmadan doğru kariyer puanıyla açılır.

## 2.14.0

- Sezon şampiyonlukları sezon numarası, kazanılan puan ve şirket ödülüyle kupa geçmişine kaydedilir.
- Eski kayıtlardaki toplam şampiyonluk sayıları aktarılan kupalara dönüştürülerek avantaj ilerlemesi korunur.
- 1 kupada proje başarı ihtimali +%3, 3 kupada bayi geliri +%4 avantajı açılır.
- 5 kupada bayi maaşları %4 azalır, 8 kupada günlük piyasa rekabet gücü +5 olur.
- Kupa avantajları küçük ve sabit oranlarla sınırlandırılarak şirket ekonomisinin kontrolsüz büyümesi önlendi.
- Şirket ekranına açılan/kilitli avantajları, sıradaki eşiği ve tüm şampiyonluk geçmişini gösteren panel eklendi.

## 2.13.0

- İkişer şirket satın alma, birleşme ve rakipten pazar payı devri olmak üzere altı tek seferlik stratejik işlem eklendi.
- Teklifler şirket aşaması, bölge hâkimiyeti, sezon şampiyonluğu ve şirket kasası şartlarıyla kademeli açılır.
- Tamamlanan işlemler şirket değerine, itibara ve pazar payına kalıcı katkı sağlar; pasif para üretmez.
- Tüm bedeller yalnızca şirket kasasından düşer ve Finans ekranında ayrı satın alma/birleşme hareketi olarak izlenir.
- Büyük işlemler geri alınamaz uyarısı ve açık maliyet/kazanım özetiyle onay gerektirir.
- Tamamlanan teklif kimlikleri SQLite v28 ile kalıcı saklanır; eski kayıtlar boş işlem geçmişiyle kayıpsız açılır.

## 2.12.0

- Türkiye'nin 81 ili yedi stratejik şirket bölgesine ayrıldı.
- Aynı bölgedeki bayi seviyelerinin toplamı 4 olduğunda bölgesel hâkimiyet ve kalıcı operasyon avantajı açılır.
- Marmara bayi gelirini, Ege proje başarısını, Akdeniz olumlu piyasa kazancını güçlendirir.
- İç Anadolu bayi maaşını, Karadeniz moral kaybını, Doğu Anadolu bayi yatırım maliyetini azaltır.
- Güneydoğu Anadolu günlük proje ilerlemesine katkı sağlar.
- Pazar payı hesabı şehirlerin tamamını açmak yerine bayi yoğunluğu ve kontrol edilen bölgeleri ödüllendirecek şekilde yenilendi.
- Şube ekranına yedi bölgeli ilerleme tablosu, avantaj açıklamaları ve stratejik şehir sıralaması eklendi.

## 2.11.0

- Şirket ilerlemesi yerel girişim, bölgesel şirket, ulusal marka ve holding aşamalarına ayrıldı.
- Aşama geçişleri şirket seviyesi, değerleme, itibar, pazar payı, çalışan sayısı, ekip kalitesi, bayi ve sezon başarısını birlikte değerlendirir.
- Ulaşılan en yüksek aşama kalıcıdır; şirket metrikleri sonradan düşse bile ilerleme gerilemez.
- Şirket ekranına tüm aşamaları ve eksik gereksinimleri aynı anda gösteren yol haritası eklendi.
- Tekrarlanan eski hedef kartları kaldırıldı; temel şirket göstergeleri kompakt panelde korundu.
- En iyi sezon derecesi kalıcı saklanarak aşama şartlarında kullanıldı.
- Eski şirket kayıtları mevcut ilerlemelerine göre otomatik değerlendirilir ve SQLite v27'ye kayıpsız geçirilir.

## 2.10.1

- Esnaf Çarkı'ndaki aynı ödül ve ceza dilimleri, olasılıkları değişmeden çember boyunca ayrıştırıldı.
- İlk ve son dilim dâhil aynı türde iki dilimin yan yana gelmemesi testle güvenceye alındı.

## 2.10.0

- Günlük piyasa sonuçlarını puana dönüştüren 30 oyun günlük şirket rekabet sezonu eklendi.
- Oyuncu şirketi dört kurgu rakiple aynı sıralamada yarışır; rakip güçleri her sezonda kontrollü artar.
- Sezonun ilk üçü şirket kasasına sırasıyla ₺6.000, ₺3.000 ve ₺1.500 ödül kazanır.
- Şampiyonluklar şirket değerlemesi, itibarı ve pazar payına kalıcı katkı sağlar.
- Sezon ilerlemesi, galibiyet/mağlubiyet, son derece ve ödül SQLite v26 ile kalıcı saklanır.
- Eski kayıtlar, kayıt gününe karşılık gelen sezondan veri kaybı olmadan devam eder.

## 2.9.0

- Kişisel cüzdan ve şirket kasası şirket ekranında yan yana, açık adlarla gösterilir.
- Kişisel cüzdandan şirket kasasına sermaye yatırma ve %10 vergili kâr payı çekme eklendi.
- Para aktarımları iki hesapta karşılıklı kaydedilir; vergi ayrı finans hareketi olarak izlenir.
- Şirket geliri, çalışan maaşı, proje, bayi, piyasa ve çalışan geliştirme hareketleri şirket hesabına bağlandı.
- Finans ekranı kişisel ve şirket hareketlerini ayrı bölümlerde ve ayrı yedi günlük netlerle gösterir.
- Şirketle ilgili maliyet ve ödül metinlerinde kullanılan para kaynağı açıkça belirtildi.
- Eski finans kayıtları varsayılan olarak kişisel hesapta açılarak SQLite v25 uyumluluğu korundu.

## 2.8.0

- Altı farklı, yedişer günlük piyasa dönemi şirket gelir ve personel maliyetlerini etkiler.
- Dört kurgu rakip şirket; ekip performansı, şirket seviyesi, bayi ve proje geçmişine göre günlük pazar rekabeti oluşturur.
- Çalışanlara kalıcı moral ve sadakat eklendi; piyasa sonuçları üretkenliği ve ayrılma riskini değiştirir.
- Çalışan geliştirme artık performansın yanında moral ve sadakati de yükseltir.
- Şirket ekranına piyasa etkisi, rakip güçleri, çalışan iyilik hâli ve risk göstergeleri eklendi.
- Eski çalışan kayıtları veri kaybı olmadan varsayılan moral ve sadakatle yükseltilir.
- Şirket ekonomisi ve çalışan durumları 180 oyun günlük regresyon simülasyonuyla doğrulandı.

## 2.7.0

- Merkez ve bayi çalışanlarına şirket kasasından finanse edilen kalıcı performans geliştirmesi eklendi.
- Geliştirme bedeli çalışan performansına göre artar; her eğitim +5 performans kazandırır ve 100 seviyesinde durur.
- Çalışan gelişimi proje hızına, başarı ihtimaline ve bayi gelirine doğrudan yansır.
- Günlük işveren görev havuzu 6'dan 12 dengeli şablona, günlük seçenek sayısı 4–6 aralığına çıkarıldı.

## 2.6.0

- Şirket projelerine başarı ihtimali, önerilen şirket seviyesi, ekip uzmanlığı ve tahmini tamamlanma süresi eklendi.
- Altı çalışan uzmanlığı proje hızını ve başarı ihtimalini; şehirle eşleşen uzmanlık ise bayi gelirini etkiler.
- Başarısız projeler işletme maliyeti oluşturur; yüksek ödüllü sözleşmeler artık hazırlıksız ekipler için gerçek risk taşır.
- Bayiler şirket seviyesine bağlı olarak iki kez yükseltilebilir; her seviye +3 kapasite ve %25 brüt gelir sağlar.
- Bayi yükseltme ve proje stratejisi eski SQLite v25 kayıtlarıyla uyumlu tutuldu.

## 2.5.0

- Son 30 günü kategori bazında saklayan kalıcı finans günlüğü ve Finans ekranı eklendi.
- Konut, yemek, fatura, ulaşım, kira geliri ve kiralık ev bakım giderleri günlük bütçede ayrıştırıldı.
- Gelire bağlı yaşam standardı yumuşatıldı; enflasyon artışı aylık %1 ve en fazla %25 olacak şekilde dengelendi.
- Şirket değerlemesi, itibar, pazar payı, altı uzun vadeli hedef ve üç büyük sözleşme eklendi.
- Ev, kiralama ve şirket büyümesine bağlı başarı kataloğu 12 hedefe genişletildi.
- SQLite kayıt şeması finans geçmişi için v25'e yükseltildi.
- Esnaf Çarkı 20 dilime çıkarıldı: 7 boş, 5 adet -50 TL, 3 adet -100 TL ve istenen ödül dağılımı uygulandı.
- Hızlı görev ödülü 10 doğruda ₺150, 11 doğruda ₺165 olacak ve en fazla ₺300 temel ödüle ulaşacak şekilde dengelendi.
- Şehir giderleri doğrusal nüfus hesabından oynanabilir ₺90–₺1.000 eğrisine geçirildi; maaş katsayısı `0.95–1.25x` aralığına çekildi.
- Şirket kuruluş ve yükseltme maliyetleri uzun vadeli ilerlemeye göre ayarlandı; çalışansız şirketin pasif kazancı kaldırıldı.
- Bayi açılışları 60–220 oyun günlük hedef geri dönüş süresine göre dengelendi ve 30/100 günlük ekonomi regresyonları eklendi.

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
- Şehir maaş katsayısı ilk dengelemede `0.90–1.50x` aralığına indirildi; kayıtlı istihdam maaşları açılışta yenilenir.

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
