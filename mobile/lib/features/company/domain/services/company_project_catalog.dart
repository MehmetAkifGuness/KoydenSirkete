import '../entities/company_project.dart';

abstract final class CompanyProjectCatalog {
  static const version = 2;

  static const projects = <CompanyProject>[
    CompanyProject(id: 1, name: 'Yerel üretim', description: 'Dengeli maliyet ve istikrarlı gelir.', cost: 100, reward: 500, progressPerEmployee: 10, experienceReward: 5),
    CompanyProject(id: 2, name: 'Dijital pazar', description: 'Daha yüksek gelir, daha uzun geliştirme süreci.', cost: 180, reward: 900, progressPerEmployee: 8, experienceReward: 10),
    CompanyProject(id: 3, name: 'Kurumsal çözüm', description: 'Büyük müşteriler için yüksek getirili proje.', cost: 300, reward: 1500, progressPerEmployee: 6, experienceReward: 18),
  ];

  static CompanyProject byId(int id) => projects.firstWhere((project) => project.id == id, orElse: () => projects.first);
}
