import '../entities/job.dart';

abstract final class JobEmployerCatalog {
  static const version = 1;
  static const employerCount = 24;

  static const _employersByTrack = <String, List<String>>{
    'satış ve perakende': [
      'Bereket Market',
      'Anadolu Mağazaları',
      'Pusula Perakende',
      'KentSepet',
      'Birlik Ticaret',
      'Rota Mağazacılık',
    ],
    'finans': [
      'Köprü Finans',
      'Güven Varlık',
      'Denge Finans',
      'Mavi Finans',
      'Zirve Mali Hizmetler',
      'Atlas Finans',
    ],
    'lojistik': [
      'Ufuk Lojistik',
      'Kervan Taşımacılık',
      'Rota Kargo',
      'Anadolu Dağıtım',
      'Liman Lojistik',
      'Akış Lojistik',
    ],
    'dijital ve operasyon': [
      'Yeni Ufuk Teknoloji',
      'Piksel Teknoloji',
      'VeriKüre',
      'Kodova Dijital',
      'İleri Yazılım',
      'Dönüşüm Teknoloji',
    ],
  };

  static final employers = List<String>.unmodifiable(
    _employersByTrack.values.expand((employers) => employers),
  );

  static String select({
    required Job job,
    required int cityId,
    required int day,
  }) {
    final employers = _employersByTrack[job.careerTrack];
    if (employers == null || employers.isEmpty) return job.company;
    final seed = (job.id * 92821 + cityId * 68917 + day * 31337).abs();
    return employers[seed % employers.length];
  }
}
