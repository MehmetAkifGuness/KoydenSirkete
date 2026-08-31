import 'dart:io';

void main() {
  final violations = <String>[];
  for (final file
      in Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))) {
    final source = file.readAsStringSync();
    if (RegExp(r'\bTL\b').hasMatch(source)) {
      violations.add('${file.path}: para birimi için TL yerine ₺ kullanın.');
    }
    if (!file.path.endsWith('app_formatters.dart') &&
        source.contains('toStringAsFixed(')) {
      violations.add(
        '${file.path}: ondalık değerleri AppFormatters.decimal ile biçimlendirin.',
      );
    }
  }

  if (violations.isNotEmpty) {
    stderr.writeln(violations.join('\n'));
    exitCode = 1;
    return;
  }
  stdout.writeln('Türkçe sayı, para ve ondalık biçim standardı temiz.');
}
