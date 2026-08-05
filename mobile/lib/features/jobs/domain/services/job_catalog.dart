import '../entities/job.dart';

abstract final class JobCatalog {
  static const version = 1;

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
