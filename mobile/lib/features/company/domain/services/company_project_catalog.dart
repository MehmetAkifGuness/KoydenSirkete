import '../entities/company_project.dart';

abstract final class CompanyProjectCatalog {
  static const version = 3;

  static const projects = <CompanyProject>[
    CompanyProject(
      id: 1,
      name: 'Yerel üretim',
      description: 'Dengeli maliyet ve istikrarlı gelir.',
      cost: 100,
      reward: 500,
      progressPerEmployee: 10,
      experienceReward: 5,
    ),
    CompanyProject(
      id: 2,
      name: 'Dijital pazar',
      description: 'Daha yüksek gelir, daha uzun geliştirme süreci.',
      cost: 180,
      reward: 900,
      progressPerEmployee: 8,
      experienceReward: 10,
    ),
    CompanyProject(
      id: 3,
      name: 'Kurumsal çözüm',
      description: 'Büyük müşteriler için yüksek getirili proje.',
      cost: 300,
      reward: 1500,
      progressPerEmployee: 6,
      experienceReward: 18,
    ),
    CompanyProject(
      id: 4,
      name: 'Ulusal dağıtım sözleşmesi',
      description: 'Birden fazla şehirde teslimat gerektiren büyük anlaşma.',
      cost: 1000,
      reward: 6000,
      progressPerEmployee: 4,
      experienceReward: 30,
    ),
    CompanyProject(
      id: 5,
      name: 'Kamu teknoloji ihalesi',
      description: 'Yüksek bütçeli ve uzun soluklu dönüşüm projesi.',
      cost: 2500,
      reward: 15000,
      progressPerEmployee: 3,
      experienceReward: 50,
    ),
    CompanyProject(
      id: 6,
      name: 'Global büyüme anlaşması',
      description: 'En deneyimli şirketler için stratejik ortaklık.',
      cost: 6000,
      reward: 35000,
      progressPerEmployee: 2,
      experienceReward: 80,
    ),
  ];

  static CompanyProject byId(int id) => projects.firstWhere(
    (project) => project.id == id,
    orElse: () => projects.first,
  );
}
