class GameRuleException implements Exception {
  const GameRuleException(this.message);

  final String message;

  @override
  String toString() => message;
}
