abstract final class AppFormatters {
  static String integer(int value) {
    final digits = value.abs().toString();
    final buffer = StringBuffer();
    for (var index = 0; index < digits.length; index++) {
      if (index > 0 && (digits.length - index) % 3 == 0) buffer.write('.');
      buffer.write(digits[index]);
    }
    return '${value < 0 ? '-' : ''}$buffer';
  }

  static String money(int value, {bool showPositiveSign = false}) {
    final sign = value < 0 ? '-' : (showPositiveSign && value > 0 ? '+' : '');
    return '$sign₺${integer(value.abs())}';
  }

  static String decimal(num value, {int fractionDigits = 2}) =>
      value.toStringAsFixed(fractionDigits).replaceFirst('.', ',');

  static String date(DateTime value) {
    final local = value.toLocal();
    return '${_twoDigits(local.day)}.${_twoDigits(local.month)}.${local.year}';
  }

  static String compactNumber(int value) {
    if (value >= 1000000) {
      return '${decimal(value / 1000000, fractionDigits: 1)} Mn';
    }
    if (value >= 1000) {
      return '${decimal(value / 1000, fractionDigits: 1)} B';
    }
    return integer(value);
  }

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');
}
