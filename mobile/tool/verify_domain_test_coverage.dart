import 'dart:io';

void main() {
  final services = Directory('lib/features')
      .listSync(recursive: true)
      .whereType<File>()
      .where(
        (file) =>
            file.path.endsWith('.dart') &&
            file.path.replaceAll('\\', '/').contains('/domain/services/'),
      );
  final tests = Directory('test')
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('_test.dart'))
      .map((file) => file.readAsStringSync())
      .join('\n');
  final declaration = RegExp(
    r'^(?:abstract final\s+)?class\s+(\w+(?:Service|Catalog|Generator|Recorder))\b',
    multiLine: true,
  );
  final missing = <String>[];
  for (final file in services) {
    for (final match in declaration.allMatches(file.readAsStringSync())) {
      final name = match.group(1)!;
      if (!tests.contains(name)) missing.add('$name (${file.path})');
    }
  }
  if (missing.isNotEmpty) {
    stderr.writeln('Doğrudan domain testi bulunmayan servisler:');
    for (final item in missing..sort()) {
      stderr.writeln('- $item');
    }
    exitCode = 1;
    return;
  }
  stdout.writeln('Tüm domain servisleri doğrudan otomatik test kapsamına bağlı.');
}
