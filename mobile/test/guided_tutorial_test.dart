import 'package:flutter_test/flutter_test.dart';

import 'package:kariyerden_sirkete/features/company/domain/services/company_service.dart';
import 'package:kariyerden_sirkete/features/economy/domain/entities/economy_difficulty.dart';
import 'package:kariyerden_sirkete/features/onboarding/data/onboarding_demo_repository.dart';
import 'package:kariyerden_sirkete/features/onboarding/presentation/models/guided_tutorial_step.dart';

void main() {
  test('uygulamalı eğitim tüm temel oyun alanlarını kapsar', () {
    expect(guidedTutorialSteps, hasLength(16));
    expect(
      guidedTutorialSteps.map((step) => step.destination).toSet(),
      containsAll(GuidedTutorialDestination.values),
    );
    expect(
      guidedTutorialSteps.map((step) => step.taskType),
      containsAll([
        GuidedTutorialTask.topBar,
        GuidedTutorialTask.dashboardShortcut,
        GuidedTutorialTask.earning,
        GuidedTutorialTask.training,
        GuidedTutorialTask.sport,
        GuidedTutorialTask.jobApplication,
        GuidedTutorialTask.work,
        GuidedTutorialTask.finance,
        GuidedTutorialTask.cityMove,
        GuidedTutorialTask.assets,
        GuidedTutorialTask.companyEstablishment,
        GuidedTutorialTask.companySections,
        GuidedTutorialTask.feedbackPreferences,
      ]),
    );
    expect(
      guidedTutorialSteps.where((step) => step.task.trim().isEmpty),
      isEmpty,
    );
  });

  test('demo her adımın maddi ve kariyer koşullarını hazırlar', () async {
    final repository = OnboardingDemoRepository()
      ..reset(EconomyDifficulty.normal)
      ..prepareForStep(12);
    final state = await repository.load();

    expect(state, isNotNull);
    expect(state!.careerLevel, greaterThanOrEqualTo(3));
    expect(state.money, greaterThanOrEqualTo(CompanyService.establishmentCost));
    expect(state.energy, state.maxEnergy);
    expect(state.employment, isNotNull);
  });

  test('öğretici metinleri geçerli Türkçe karakterleri korur', () {
    final text = guidedTutorialSteps
        .expand((step) => [step.title, step.description, step.task])
        .join(' ');

    expect(text, contains('Üst'));
    expect(text, contains('İlk'));
    expect(text, isNot(contains('\uFFFD')));
    expect(text, isNot(contains('Ã')));
  });
}
