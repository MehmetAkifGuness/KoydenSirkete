enum GuidedTutorialDestination {
  dashboard,
  earning,
  training,
  skills,
  sport,
  jobs,
  employment,
  career,
  finance,
  cities,
  assets,
  company,
  profile,
}

enum GuidedTutorialTask {
  topBar,
  dashboardShortcut,
  earning,
  training,
  acknowledge,
  sport,
  jobApplication,
  work,
  finance,
  cityMove,
  assets,
  companyEstablishment,
  companySections,
  feedbackPreferences,
  finish,
}

class GuidedTutorialStep {
  const GuidedTutorialStep({
    required this.title,
    required this.description,
    required this.task,
    required this.destination,
    required this.taskType,
    this.canAcknowledge = false,
  });

  final String title;
  final String description;
  final String task;
  final GuidedTutorialDestination destination;
  final GuidedTutorialTask taskType;
  final bool canAcknowledge;
}

const guidedTutorialSteps = <GuidedTutorialStep>[
  GuidedTutorialStep(
    title: 'Üst durum çubuğunu kullan',
    description:
        'Kişisel cüzdan, şirket kasası, gün, saat ve enerji her ekranda burada görünür. Hız düğmeleri oyun saatini yönetir; durdur düğmesi karar verirken zamanı bekletir.',
    task: '2x veya 4x hızını ve ardından durdur/devam kontrolünü dene.',
    destination: GuidedTutorialDestination.dashboard,
    taskType: GuidedTutorialTask.topBar,
  ),
  GuidedTutorialStep(
    title: 'Panel kısayollarını tanı',
    description:
        'Panel, mevcut durumunu ve önerilen sonraki hamleyi özetler. Hızlı erişim kartları kazanç, eğitim, iş, şehir, finans ve varlık ekranlarına götürür.',
    task: 'Paneldeki hızlı erişim kartlarından birine dokun.',
    destination: GuidedTutorialDestination.dashboard,
    taskType: GuidedTutorialTask.dashboardShortcut,
  ),
  GuidedTutorialStep(
    title: 'İlk sermayeni kazan',
    description:
        'Kazanç etkinlikleri enerji harcar ve süre sonunda kişisel cüzdana ödeme yapar. Kartlarda ücret, süre, enerji ve günlük sınır birlikte gösterilir.',
    task: 'Refleks oyununu tamamla veya bir kazanç etkinliği başlat.',
    destination: GuidedTutorialDestination.earning,
    taskType: GuidedTutorialTask.earning,
  ),
  GuidedTutorialStep(
    title: 'Bilgine yatırım yap',
    description:
        'Eğitimler kişisel cüzdandan ödenir; enerji ve zaman karşılığında bilgi kazandırır. Aynı anda yürüyen etkinlik kapasitesini de burada görebilirsin.',
    task: 'Maliyet ve getiriyi inceleyip bir eğitim başlat.',
    destination: GuidedTutorialDestination.training,
    taskType: GuidedTutorialTask.training,
  ),
  GuidedTutorialStep(
    title: 'Yetenek portföyünü oku',
    description:
        'İletişim, satış, liderlik ve diğer uzmanlık puanları iş ilanlarının koşullarını belirler. Her kart mevcut seviyeyi ve gelişim oranını gösterir.',
    task: 'Yetenek kartlarını ve ilerleme çubuklarını incele.',
    destination: GuidedTutorialDestination.skills,
    taskType: GuidedTutorialTask.acknowledge,
    canAcknowledge: true,
  ),
  GuidedTutorialStep(
    title: 'Enerji kapasiteni geliştir',
    description:
        'Spor anlık enerji harcar fakat tamamlandığında maksimum enerji kapasiteni kalıcı artırır. Devam eden antrenmanın süresi ayrı kartta izlenir.',
    task: 'Antrenmana başla düğmesini kullan.',
    destination: GuidedTutorialDestination.sport,
    taskType: GuidedTutorialTask.sport,
  ),
  GuidedTutorialStep(
    title: 'İş ilanlarını karşılaştır',
    description:
        'Filtreler uygun ilanları ayırır. Her ilanda maaş, şehir, rütbe, yetenek koşulları ve başvuru maliyeti görünür; başvurular rekabet sonucuna bağlıdır.',
    task: 'Filtreleri incele ve uygun bir ilana başvur.',
    destination: GuidedTutorialDestination.jobs,
    taskType: GuidedTutorialTask.jobApplication,
  ),
  GuidedTutorialStep(
    title: 'Günün görevini yap',
    description:
        'İşim ekranı maaşı, performansı ve günlük görev sayısını özetler. Görev ekranında süre, enerji, performans getirisi ve risk birlikte gösterilir.',
    task: 'Günün görevlerini aç ve bir çalışma görevi başlat.',
    destination: GuidedTutorialDestination.employment,
    taskType: GuidedTutorialTask.work,
  ),
  GuidedTutorialStep(
    title: 'Kariyer rotanı planla',
    description:
        'Kariyer ekranı mevcut rolünü, tamamlanan basamakları, sıradaki terfiyi ve eksik koşulları gösterir. Terfi düğmesi yalnızca tüm koşullar sağlandığında açılır.',
    task: 'Kariyer rotasını ve sıradaki rol koşullarını incele.',
    destination: GuidedTutorialDestination.career,
    taskType: GuidedTutorialTask.acknowledge,
    canAcknowledge: true,
  ),
  GuidedTutorialStep(
    title: 'Finans merkezini kullan',
    description:
        'Ana kartlar kişisel ve şirket bakiyesini ayırır. Hareketler, kredi-yatırım ve 7 günlük özet alt sayfaları para akışını farklı açılardan açıklar.',
    task: 'Üç finans alt sayfasını aç ve demo kredi veya yatırım işlemi yap.',
    destination: GuidedTutorialDestination.finance,
    taskType: GuidedTutorialTask.finance,
  ),
  GuidedTutorialStep(
    title: 'Şehir maliyetlerini karşılaştır',
    description:
        'Şehir ekranında yaşam gideri, maaş çarpanı, nüfus ve taşınma maliyeti karşılaştırılır. Arama, maliyet sıralaması ve uygunluk durumu kararını kolaylaştırır.',
    task: 'Başka bir şehri seçip taşınma onayını tamamla.',
    destination: GuidedTutorialDestination.cities,
    taskType: GuidedTutorialTask.cityMove,
  ),
  GuidedTutorialStep(
    title: 'Varlıklarını yönet',
    description:
        'Evler alt sayfası satın alma, oturma, kiralama ve satışı; arabalar alt sayfası ulaşım avantajı ile alım-satımı yönetir. Tüm işlemler kişisel cüzdanı kullanır.',
    task:
        'Evler ve Arabalar sayfalarını aç; demo hesabına bir varlık satın al.',
    destination: GuidedTutorialDestination.assets,
    taskType: GuidedTutorialTask.assets,
  ),
  GuidedTutorialStep(
    title: 'Kendi şirketini kur',
    description:
        'Şirket kuruluşu kişisel cüzdandan sermaye aktarır ve mevcut iş ilişkisini bitirir. Kurulum kartı maliyet, koşul ve geri alınamaz sonucu onaydan önce gösterir.',
    task: 'Şirket kuruluş onayını tamamla.',
    destination: GuidedTutorialDestination.company,
    taskType: GuidedTutorialTask.companyEstablishment,
  ),
  GuidedTutorialStep(
    title: 'Şirket yönetim alanlarını keşfet',
    description:
        'Operasyon ve bütçe; projeler; büyüme ve pazar; ekip ve adaylar birbirinden ayrıdır. Her alt sayfa yalnızca ilgili kararları ve sonuçlarını gösterir.',
    task: 'Dört şirket alt sayfasını sırayla açıp geri dön.',
    destination: GuidedTutorialDestination.company,
    taskType: GuidedTutorialTask.companySections,
  ),
  GuidedTutorialStep(
    title: 'Profil tercihlerini dene',
    description:
        'Profil; varlık ve kariyer özetlerine, ses-titreşim tercihlerine, turu yeniden başlatmaya ve yeni oyun işlemine erişir. Yeni oyun mevcut kaydı kalıcı sıfırlar.',
    task:
        'Ses ve titreşim deneme düğmelerini kullan, ardından iki tercihi kapat.',
    destination: GuidedTutorialDestination.profile,
    taskType: GuidedTutorialTask.feedbackPreferences,
  ),
  GuidedTutorialStep(
    title: 'Gerçek kariyerine başla',
    description:
        'Tüm işlemleri ayrı demo kaydında denedin. Gerçek kaydın seçtiğin ekonomi zorluğuyla Panel ekranından başlayacak; ilerlemen otomatik olarak SQLite’a yazılacak.',
    task: 'Turu tamamlayıp gerçek kariyerine dön.',
    destination: GuidedTutorialDestination.dashboard,
    taskType: GuidedTutorialTask.finish,
  ),
];
