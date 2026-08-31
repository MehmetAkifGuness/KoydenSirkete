import 'dart:io';

import 'package:path/path.dart' as path;

void main() {
  final root = Directory.current.absolute;
  final libRoot = Directory(path.join(root.path, 'lib'));
  final sourceFiles = libRoot
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .map((file) => path.normalize(file.absolute.path))
      .toSet();

  final reachable = <String>{};
  final pending = <String>[path.join(libRoot.path, 'main.dart')];
  final directive = RegExp(r'''(?:import|export|part)\s+['"]([^'"]+)['"]''');
  const packagePrefix = 'package:kariyerden_sirkete/';

  while (pending.isNotEmpty) {
    final current = path.normalize(pending.removeLast());
    if (!sourceFiles.contains(current) || !reachable.add(current)) continue;
    final contents = File(current).readAsStringSync();
    for (final match in directive.allMatches(contents)) {
      final uri = match.group(1)!;
      String? target;
      if (uri.startsWith(packagePrefix)) {
        target = path.join(libRoot.path, uri.substring(packagePrefix.length));
      } else if (!uri.contains(':')) {
        target = path.join(path.dirname(current), uri);
      }
      if (target != null) pending.add(path.normalize(target));
    }
  }

  final orphaned = sourceFiles.difference(reachable).toList()..sort();
  final pubspec = File(path.join(root.path, 'pubspec.yaml')).readAsStringSync();
  final projectText = [
    ...sourceFiles.map((file) => File(file).readAsStringSync()),
    ...Directory(path.join(root.path, 'test'))
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .map((file) => file.readAsStringSync()),
    ...Directory(path.join(root.path, 'integration_test'))
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .map((file) => file.readAsStringSync()),
    File(path.join(root.path, 'analysis_options.yaml')).readAsStringSync(),
  ].join('\n');

  final dependencies = _declaredPackages(pubspec);
  final unusedPackages = dependencies
      .where((name) => !projectText.contains('package:$name/'))
      .toList();
  final assets = _declaredAssets(pubspec);
  final missingAssets = assets
      .where((asset) => !File(path.join(root.path, asset)).existsSync())
      .toList();
  final unreferencedAssets = assets
      .where((asset) => !projectText.contains(asset))
      .toList();

  if (orphaned.isNotEmpty ||
      unusedPackages.isNotEmpty ||
      missingAssets.isNotEmpty ||
      unreferencedAssets.isNotEmpty) {
    for (final file in orphaned) {
      stderr.writeln(
        'Ulaşılamayan kaynak: ${path.relative(file, from: root.path)}',
      );
    }
    for (final package in unusedPackages) {
      stderr.writeln('Kullanılmayan bağımlılık: $package');
    }
    for (final asset in missingAssets) {
      stderr.writeln('Eksik varlık: $asset');
    }
    for (final asset in unreferencedAssets) {
      stderr.writeln('Kullanılmayan varlık: $asset');
    }
    exitCode = 1;
    return;
  }

  stdout.writeln('Kaynak, bağımlılık ve varlık hijyeni temiz.');
}

Set<String> _declaredPackages(String pubspec) {
  final result = <String>{};
  var inDependencies = false;
  for (final line in pubspec.split('\n')) {
    if (line == 'dependencies:' || line == 'dev_dependencies:') {
      inDependencies = true;
      continue;
    }
    if (line.isNotEmpty && !line.startsWith(' ')) inDependencies = false;
    final match = RegExp(r'^  ([a-zA-Z0-9_]+):').firstMatch(line);
    if (inDependencies && match != null && match.group(1) != 'flutter') {
      result.add(match.group(1)!);
    }
  }
  return result;
}

List<String> _declaredAssets(String pubspec) {
  final result = <String>[];
  var inAssets = false;
  for (final line in pubspec.split('\n')) {
    if (line.trim() == 'assets:') {
      inAssets = true;
      continue;
    }
    if (inAssets && line.startsWith('    - ')) {
      result.add(line.substring(6).trim());
    } else if (inAssets && line.trim().isNotEmpty) {
      inAssets = false;
    }
  }
  return result;
}
