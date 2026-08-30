import 'package:flutter/services.dart';

class BoundedIntegerInputFormatter extends TextInputFormatter {
  BoundedIntegerInputFormatter({this.minimum = 0, this.maximum = 1000000000})
    : assert(minimum <= maximum);

  final int minimum;
  final int maximum;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.trim();
    if (text.isEmpty || (text == '-' && minimum < 0)) return newValue;
    if (!RegExp(r'^-?\d+$').hasMatch(text)) return oldValue;
    final value = BigInt.tryParse(text);
    if (value == null ||
        value < BigInt.from(minimum) ||
        value > BigInt.from(maximum)) {
      return oldValue;
    }
    return newValue;
  }
}
