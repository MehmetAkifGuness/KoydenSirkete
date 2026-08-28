import '../entities/company_project.dart';
import '../entities/company_specialty.dart';

abstract final class CompanyProjectCatalog {
  static const version = 4;

  static const projects = <CompanyProject>[
    CompanyProject(
      id: 1,
      name: 'Yerel üretim',
      description: 'Dengeli maliyet ve istikrarlı gelir.',
      cost: 100,
      reward: 500,
      progressPerEmployee: 10,
      experienceReward: 5,
      riskPercent: 8,
      recommendedCompanyLevel: 1,
      specialty: CompanySpecialty.operations,
    ),
    CompanyProject(
      id: 2,
      name: 'Dijital pazar',
      description: 'Daha yüksek gelir, daha uzun geliştirme süreci.',
      cost: 180,
      reward: 900,
      progressPerEmployee: 8,
      experienceReward: 10,
      riskPercent: 12,
      recommendedCompanyLevel: 1,
      specialty: CompanySpecialty.technology,
    ),
    CompanyProject(
      id: 3,
      name: 'Kurumsal çözüm',
      description: 'Büyük müşteriler için yüksek getirili proje.',
      cost: 300,
      reward: 1500,
      progressPerEmployee: 6,
      experienceReward: 18,
      riskPercent: 18,
      recommendedCompanyLevel: 2,
      specialty: CompanySpecialty.finance,
    ),
    CompanyProject(
      id: 4,
      name: 'Ulusal dağıtım sözleşmesi',
      description: 'Birden fazla şehirde teslimat gerektiren büyük anlaşma.',
      cost: 1000,
      reward: 6000,
      progressPerEmployee: 4,
      experienceReward: 30,
      riskPercent: 25,
      recommendedCompanyLevel: 2,
      specialty: CompanySpecialty.logistics,
    ),
    CompanyProject(
      id: 5,
      name: 'Kamu teknoloji ihalesi',
      description: 'Yüksek bütçeli ve uzun soluklu dönüşüm projesi.',
      cost: 2500,
      reward: 15000,
      progressPerEmployee: 3,
      experienceReward: 50,
      riskPercent: 32,
      recommendedCompanyLevel: 3,
      specialty: CompanySpecialty.technology,
    ),
    CompanyProject(
      id: 6,
      name: 'Global büyüme anlaşması',
      description: 'En deneyimli şirketler için stratejik ortaklık.',
      cost: 6000,
      reward: 35000,
      progressPerEmployee: 2,
      experienceReward: 80,
      riskPercent: 40,
      recommendedCompanyLevel: 3,
      specialty: CompanySpecialty.leadership,
    ),
    CompanyProject(
      id: 7,
      name: 'Özel dönüşüm ortaklığı',
      description: 'Yalnızca sezon davetiyle alınabilen prestij sözleşmesi.',
      cost: 8000,
      reward: 60000,
      progressPerEmployee: 2,
      experienceReward: 120,
      riskPercent: 20,
      recommendedCompanyLevel: 3,
      specialty: CompanySpecialty.leadership,
      requiresSeasonInvitation: true,
    ),
  ];

  static CompanyProject byId(int id) => projects.firstWhere(
    (project) => project.id == id,
    orElse: () => projects.first,
  );
}
