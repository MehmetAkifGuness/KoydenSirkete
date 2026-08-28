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
}
