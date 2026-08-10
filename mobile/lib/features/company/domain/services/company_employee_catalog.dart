import '../entities/company_employee.dart';

abstract final class CompanyEmployeeCatalog {
  static const candidates = <CompanyEmployee>[
    CompanyEmployee(id: 1, name: 'Ayşe Demir', role: 'Operasyon uzmanı', performance: 62, dailySalary: 30),
    CompanyEmployee(id: 2, name: 'Mehmet Kaya', role: 'Satış temsilcisi', performance: 74, dailySalary: 40),
    CompanyEmployee(id: 3, name: 'Zeynep Yılmaz', role: 'Dijital uzmanı', performance: 86, dailySalary: 55),
    CompanyEmployee(id: 4, name: 'Ali Şahin', role: 'Lojistik sorumlusu', performance: 68, dailySalary: 35),
    CompanyEmployee(id: 5, name: 'Elif Çelik', role: 'Finans analisti', performance: 91, dailySalary: 70, requiredCompanyLevel: 2),
    CompanyEmployee(id: 6, name: 'Can Aydın', role: 'Proje yöneticisi', performance: 95, dailySalary: 90, requiredCompanyLevel: 3),
    CompanyEmployee(id: 7, name: 'Seda Arslan', role: 'Müşteri ilişkileri', performance: 79, dailySalary: 45),
    CompanyEmployee(id: 8, name: 'Burak Koç', role: 'Üretim planlama', performance: 57, dailySalary: 25),
    CompanyEmployee(id: 9, name: 'Hakan Yıldız', role: 'Satın alma uzmanı', performance: 65, dailySalary: 32),
    CompanyEmployee(id: 10, name: 'Derya Acar', role: 'İnsan kaynakları uzmanı', performance: 72, dailySalary: 42),
    CompanyEmployee(id: 11, name: 'Emre Çetin', role: 'Veri analisti', performance: 83, dailySalary: 58),
    CompanyEmployee(id: 12, name: 'İrem Koç', role: 'Marka yöneticisi', performance: 77, dailySalary: 50),
    CompanyEmployee(id: 13, name: 'Onur Erdem', role: 'Saha operasyonu', performance: 61, dailySalary: 28),
    CompanyEmployee(id: 14, name: 'Aslı Güneş', role: 'Kalite uzmanı', performance: 69, dailySalary: 36),
    CompanyEmployee(id: 15, name: 'Mert Özkan', role: 'E-ticaret uzmanı', performance: 88, dailySalary: 60, requiredCompanyLevel: 2),
    CompanyEmployee(id: 16, name: 'Buse Kılıç', role: 'Müşteri deneyimi yöneticisi', performance: 81, dailySalary: 48, requiredCompanyLevel: 2),
    CompanyEmployee(id: 17, name: 'Kerem Arslan', role: 'Finans planlama uzmanı', performance: 87, dailySalary: 68, requiredCompanyLevel: 2),
    CompanyEmployee(id: 18, name: 'Selin Aksoy', role: 'Lojistik planlama uzmanı', performance: 75, dailySalary: 52, requiredCompanyLevel: 2),
    CompanyEmployee(id: 19, name: 'Tolga Yavuz', role: 'İş geliştirme uzmanı', performance: 90, dailySalary: 75, requiredCompanyLevel: 2),
    CompanyEmployee(id: 20, name: 'Ceren Polat', role: 'İç iletişim yöneticisi', performance: 84, dailySalary: 57, requiredCompanyLevel: 2),
    CompanyEmployee(id: 21, name: 'Baran Kurt', role: 'Bölge satış yöneticisi', performance: 89, dailySalary: 78, requiredCompanyLevel: 3),
    CompanyEmployee(id: 22, name: 'Ece Şimşek', role: 'Ürün yöneticisi', performance: 92, dailySalary: 82, requiredCompanyLevel: 3),
    CompanyEmployee(id: 23, name: 'Oğuzhan Kaya', role: 'Operasyon yöneticisi', performance: 94, dailySalary: 88, requiredCompanyLevel: 3),
    CompanyEmployee(id: 24, name: 'Melis Taş', role: 'Strateji direktörü', performance: 97, dailySalary: 110, requiredCompanyLevel: 3),
  ];

  static List<CompanyEmployee> available(int companyLevel, Iterable<int> hiredIds) {
    final hired = hiredIds.toSet();
    return candidates
        .where((candidate) => candidate.requiredCompanyLevel <= companyLevel && !hired.contains(candidate.id))
        .toList(growable: false);
  }

  static List<CompanyEmployee> legacyDefaults(int count) {
    if (count <= 0) {
      return const <CompanyEmployee>[];
    }
    return List<CompanyEmployee>.generate(
      count,
      (index) {
        if (index < candidates.length) {
          return candidates[index];
        }
        final employeeNumber = index + 1;
        return CompanyEmployee(
          id: 1000 + index,
          name: 'Eski çalışan $employeeNumber',
          role: 'Genel görevli',
          performance: 60,
          dailySalary: 30,
        );
      },
      growable: false,
    );
  }
}
