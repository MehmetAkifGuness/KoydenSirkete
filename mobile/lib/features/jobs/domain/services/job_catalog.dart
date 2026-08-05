import '../entities/job.dart';

abstract final class JobCatalog {
  static const version = 2;

  static const jobs = <Job>[
    Job(
      id: 1,
      title: 'Mağaza asistanı',
      company: 'Bereket Market',
      description: 'Müşterilere yardımcı ol, stokları takip et ve satış deneyimi kazan.',
      salary: 120,
      minimumKnowledge: 0,
      minimumExperience: 0,
      careerTrack: 'perakende',
      level: 1,
      nextJobId: 2,
    ),
    Job(
      id: 2,
      title: 'Mağaza sorumlusu',
      company: 'Bereket Market',
      description: 'Mağaza operasyonunu yönet, ekibi koordine et ve satış hedeflerine ulaş.',
      salary: 220,
      minimumKnowledge: 12,
      minimumExperience: 10,
      careerTrack: 'perakende',
      level: 2,
      nextJobId: 3,
    ),
    Job(
      id: 3,
      title: 'Bölge yöneticisi',
      company: 'Bereket Market',
      description: 'Birden fazla mağazanın performansını yönet ve büyüme planını uygula.',
      salary: 350,
      minimumKnowledge: 20,
      minimumExperience: 25,
      careerTrack: 'perakende',
      level: 3,
      nextJobId: null,
    ),
    Job(
      id: 4,
      title: 'Muhasebe asistanı',
      company: 'Köprü Finans',
      description: 'Temel finans kayıtlarını düzenle ve işletmelerin nakit akışını takip et.',
      salary: 180,
      minimumKnowledge: 8,
      minimumExperience: 5,
      careerTrack: 'finans',
      level: 1,
      nextJobId: 5,
    ),
    Job(
      id: 5,
      title: 'Finans uzmanı',
      company: 'Köprü Finans',
      description: 'Bütçe analizleri hazırla ve stratejik finans kararlarına katkı sağla.',
      salary: 320,
      minimumKnowledge: 20,
      minimumExperience: 20,
      careerTrack: 'finans',
      level: 2,
      nextJobId: null,
    ),
    Job(
      id: 6,
      title: 'Lojistik koordinatörü',
      company: 'Ufuk Lojistik',
      description: 'Tedarik akışını planla ve operasyonların zamanında ilerlemesini sağla.',
      salary: 280,
      minimumKnowledge: 15,
      minimumExperience: 15,
      careerTrack: 'lojistik',
      level: 1,
      nextJobId: null,
    ),
  ];

  static Job? findById(int? id) {
    for (final job in jobs) {
      if (job.id == id) {
        return job;
      }
    }
    return null;
  }
}
