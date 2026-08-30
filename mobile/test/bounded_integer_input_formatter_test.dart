import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kariyerden_sirkete/core/input/bounded_integer_input_formatter.dart';

void main() {
  test('negatif, taşan ve aşırı büyük sayı girişlerini reddeder', () {
    final unsigned = BoundedIntegerInputFormatter(maximum: 1000);
    const empty = TextEditingValue.empty;

    expect(unsigned.formatEditUpdate(empty, _value('-1')).text, isEmpty);
    expect(unsigned.formatEditUpdate(empty, _value('1001')).text, isEmpty);
    expect(
      unsigned.formatEditUpdate(empty, _value('999999999999999999999')).text,
      isEmpty,
    );
    expect(unsigned.formatEditUpdate(empty, _value('750')).text, '750');
  });

  test('işaretli alan yalnızca tanımlı güvenli aralığı kabul eder', () {
    final signed = BoundedIntegerInputFormatter(minimum: -10, maximum: 10);
    const empty = TextEditingValue.empty;

    expect(signed.formatEditUpdate(empty, _value('-')).text, '-');
    expect(signed.formatEditUpdate(empty, _value('-10')).text, '-10');
    expect(signed.formatEditUpdate(empty, _value('-11')).text, isEmpty);
    expect(signed.formatEditUpdate(empty, _value('11')).text, isEmpty);
  });
}

TextEditingValue _value(String text) => TextEditingValue(
  text: text,
  selection: TextSelection.collapsed(offset: text.length),
);
