class CompanyExpansionState {
  const CompanyExpansionState({this.completedDealIds = const <String>[]});

  final List<String> completedDealIds;

  bool hasCompleted(String dealId) => completedDealIds.contains(dealId);

  CompanyExpansionState complete(String dealId) => hasCompleted(dealId)
      ? this
      : CompanyExpansionState(
          completedDealIds: List<String>.unmodifiable([
            ...completedDealIds,
            dealId,
          ]),
        );
}
