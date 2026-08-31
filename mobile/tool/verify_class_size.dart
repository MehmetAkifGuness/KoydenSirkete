import 'dart:io';

void main() {
  final violations = <String>[];
  final files = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));
  final declaration = RegExp(
    r'^(?:abstract\s+final\s+|abstract\s+|final\s+|base\s+|sealed\s+)?class\s+(\w+)',
    multiLine: true,
  );
  for (final file in files) {
    final source = file.readAsStringSync();
    for (final match in declaration.allMatches(source)) {
      final opening = source.indexOf('{', match.end);
      if (opening < 0) continue;
      final closing = _matchingBrace(source, opening);
      if (closing < 0) {
        violations.add('${file.path}: ${match.group(1)} kapanış süslü parantezi yok');
        continue;
      }
      final startLine = '\n'.allMatches(source.substring(0, match.start)).length + 1;
      final endLine = '\n'.allMatches(source.substring(0, closing)).length + 1;
      final length = endLine - startLine + 1;
      if (length > 300) {
        violations.add('${file.path}: ${match.group(1)} $length satır');
      }
    }
  }
  if (violations.isNotEmpty) {
    stderr.writeln('300 satırı aşan sınıflar:');
    for (final violation in violations) {
      stderr.writeln('- $violation');
    }
    exitCode = 1;
    return;
  }
  stdout.writeln('Tüm sınıflar 300 satır sınırında.');
}

int _matchingBrace(String source, int opening) {
  var depth = 0;
  String? quote;
  var triple = false;
  var lineComment = false;
  var blockComment = false;
  for (var index = opening; index < source.length; index++) {
    final char = source[index];
    final next = index + 1 < source.length ? source[index + 1] : '';
    if (lineComment) {
      if (char == '\n') lineComment = false;
      continue;
    }
    if (blockComment) {
      if (char == '*' && next == '/') {
        blockComment = false;
        index++;
      }
      continue;
    }
    if (quote != null) {
      if (char == '\\') {
        index++;
        continue;
      }
      if (triple && source.startsWith('$quote$quote$quote', index)) {
        index += 2;
        quote = null;
        triple = false;
      } else if (!triple && char == quote) {
        quote = null;
      }
      continue;
    }
    if (char == '/' && next == '/') {
      lineComment = true;
      index++;
      continue;
    }
    if (char == '/' && next == '*') {
      blockComment = true;
      index++;
      continue;
    }
    if (char == "'" || char == '"') {
      quote = char;
      triple = source.startsWith('$char$char$char', index);
      if (triple) index += 2;
      continue;
    }
    if (char == '{') depth++;
    if (char == '}' && --depth == 0) return index;
  }
  return -1;
}
