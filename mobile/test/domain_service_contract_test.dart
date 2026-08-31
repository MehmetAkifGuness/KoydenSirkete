import 'package:flutter_test/flutter_test.dart';

import 'package:kariyerden_sirkete/features/company/domain/services/company_competitor_catalog.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_finance_recorder.dart';
import 'package:kariyerden_sirkete/features/finance/domain/entities/finance_ledger.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';
import 'package:kariyerden_sirkete/features/jobs/domain/services/job_catalog.dart';
import 'package:kariyerden_sirkete/features/skills/domain/entities/skill_id.dart';
import 'package:kariyerden_sirkete/features/skills/domain/entities/skill_profile.dart';
import 'package:kariyerden_sirkete/features/skills/domain/services/skill_service.dart';
import 'package:kariyerden_sirkete/features/work/domain/services/contextual_work_task_catalog.dart';

void main() {
  group('kalan domain servislerinin sözleşmeleri', () {
    test('rakip kataloğu benzersiz ve güvenli sınırlardadır', () {
      final rivals = CompanyCompetitorCatalog.competitors;
      expect(rivals, hasLength(4));
      expect(rivals.map((item) => item.id).toSet(), hasLength(rivals.length));
      for (final rival in rivals) {
        expect(rival.baseStrength, inInclusiveRange(0, 100));
        expect(rival.branchIntervalDays, greaterThan(0));
        expect(rival.hiringIntervalDays, greaterThan(0));
      }
    });

    test('şirket finans kaydı normal, sınır ve hatalı hesapları korur', () {
      final ledger = CompanyFinanceRecorder.recordDailyOperations(
        PlayerState.initial.copyWith(day: 8),
        revenue: 500,
        payroll: 0,
      );
      expect(ledger.entries, hasLength(1));
      expect(ledger.entries.single.account, FinanceAccount.company);
      expect(
        () => CompanyFinanceRecorder.record(
          PlayerState.initial,
          FinanceCategory.food,
          -1,
        ),
        throwsArgumentError,
      );
    });

    test('yetenek servisi artışı uygular ve aşırı değeri sınırlar', () {
      final service = SkillService();
      final improved = service.improve(PlayerState.initial, {
        SkillId.analysis: SkillProfile.maxValue + 1,
      });
      expect(service.level(improved, SkillId.analysis), SkillProfile.maxValue);
      expect(service.level(PlayerState.initial, SkillId.analysis), 0);
    });

    test(
      'bağlamsal görev kataloğu bilinmeyen sektörü güvenle varsayılanlar',
      () {
        final fallback = ContextualWorkTaskCatalog.forSector('bilinmeyen');
        final jobTasks = ContextualWorkTaskCatalog.forJob(
          JobCatalog.jobs.first,
        );
        expect(fallback.code, 104);
        expect(jobTasks, isNotEmpty);
        expect(
          jobTasks.map((item) => item.code).toSet(),
          hasLength(jobTasks.length),
        );
      },
    );
  });
}
