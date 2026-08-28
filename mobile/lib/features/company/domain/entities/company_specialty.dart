import 'company_employee.dart';

enum CompanySpecialty {
  operations('Operasyon'),
  sales('Satış'),
  finance('Finans'),
  technology('Teknoloji'),
  logistics('Lojistik'),
  leadership('Liderlik');

  const CompanySpecialty(this.label);

  final String label;
}

extension CompanyEmployeeSpecialty on CompanyEmployee {
  CompanySpecialty get specialty {
    final normalized = role.toLowerCase();
    if (normalized.contains('finans')) return CompanySpecialty.finance;
    if (normalized.contains('lojistik')) return CompanySpecialty.logistics;
    if (normalized.contains('dijital') ||
        normalized.contains('veri') ||
        normalized.contains('ürün') ||
        normalized.contains('e-ticaret')) {
      return CompanySpecialty.technology;
    }
    if (normalized.contains('satış') ||
        normalized.contains('müşteri') ||
        normalized.contains('marka') ||
        normalized.contains('iş geliştirme')) {
      return CompanySpecialty.sales;
    }
    if (normalized.contains('operasyon') ||
        normalized.contains('üretim') ||
        normalized.contains('kalite') ||
        normalized.contains('saha') ||
        normalized.contains('satın alma')) {
      return CompanySpecialty.operations;
    }
    if (normalized.contains('yönetici') ||
        normalized.contains('lider') ||
        normalized.contains('insan kaynakları') ||
        normalized.contains('iletişim') ||
        normalized.contains('strateji')) {
      return CompanySpecialty.leadership;
    }
    return CompanySpecialty.operations;
  }

  int jobFitPercentFor(CompanySpecialty target) {
    final own = specialty;
    if (own == target) return 100;
    if ((own == CompanySpecialty.operations &&
            target == CompanySpecialty.logistics) ||
        (own == CompanySpecialty.logistics &&
            target == CompanySpecialty.operations) ||
        (own == CompanySpecialty.sales &&
            target == CompanySpecialty.leadership) ||
        (own == CompanySpecialty.leadership &&
            target == CompanySpecialty.sales)) {
      return 75;
    }
    if ((own == CompanySpecialty.finance &&
            target == CompanySpecialty.leadership) ||
        (own == CompanySpecialty.leadership &&
            target == CompanySpecialty.finance) ||
        (own == CompanySpecialty.technology &&
            target == CompanySpecialty.operations) ||
        (own == CompanySpecialty.operations &&
            target == CompanySpecialty.technology)) {
      return 70;
    }
    return 50;
  }
}
