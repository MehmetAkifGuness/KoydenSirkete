import 'package:flutter_test/flutter_test.dart';
import 'package:kariyerden_sirkete/core/utils/app_formatters.dart';

void main() {
  test('Türkçe sayı ve para biçimi tutarlıdır', () {
    expect(AppFormatters.integer(1234567), '1.234.567');
    expect(AppFormatters.integer(-1234), '-1.234');
    expect(AppFormatters.money(1234567), '₺1.234.567');
    expect(AppFormatters.money(-1234), '-₺1.234');
    expect(AppFormatters.money(50, showPositiveSign: true), '+₺50');
  });

  test('Türkçe ondalık ve tarih biçimi tutarlıdır', () {
    expect(AppFormatters.decimal(1.5), '1,50');
    expect(AppFormatters.compactNumber(1250), '1,3 B');
    expect(AppFormatters.date(DateTime(2026, 8, 30)), '30.08.2026');
  });
}
