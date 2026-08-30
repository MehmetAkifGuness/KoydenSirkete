import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/input/bounded_integer_input_formatter.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/app_page.dart';
import '../../domain/entities/debug_state_patch.dart';
import '../../../skills/domain/entities/skill_id.dart';
import '../../../skills/domain/entities/skill_profile.dart';
import '../state/game_session_controller.dart';

class DeveloperDataPage extends StatefulWidget {
  const DeveloperDataPage({required this.session, super.key});

  final GameSessionController session;

  @override
  State<DeveloperDataPage> createState() => _DeveloperDataPageState();
}

class _DeveloperDataPageState extends State<DeveloperDataPage> {
  late final Map<String, TextEditingController> _fields;
  late final Map<SkillId, TextEditingController> _skillFields;

  @override
  void initState() {
    super.initState();
    final state = widget.session.state;
    _fields = {
      'money': TextEditingController(text: '${state.money}'),
      'energy': TextEditingController(text: '${state.energy}'),
      'maxEnergy': TextEditingController(text: '${state.maxEnergy}'),
      'knowledge': TextEditingController(text: '${state.knowledge}'),
      'experience': TextEditingController(text: '${state.experience}'),
      'day': TextEditingController(text: '${state.day}'),
      'hour': TextEditingController(text: '${state.hour}'),
      'careerLevel': TextEditingController(text: '${state.careerLevel}'),
      'companyFunds': TextEditingController(text: '${state.companyFunds}'),
      'performance': TextEditingController(text: '${state.performance}'),
    };
    _skillFields = {
      for (final skill in SkillId.values)
        skill: TextEditingController(text: '${state.skills[skill]}'),
    };
  }

  @override
  void dispose() {
    for (final controller in _fields.values) {
      controller.dispose();
    }
    for (final controller in _skillFields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }
    return AppPage(
      title: 'Geliştirici verileri',
      subtitle: 'Yalnızca debug sürümünde kullanılabilir',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          AppInfoCard(
            accent: AppPalette.warning,
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: AppPalette.warning),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Değerler güvenli oyun sınırları içinde kaydedilir.',
                    style: TextStyle(
                      color: AppPalette.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const AppSectionHeader(
            title: 'Oyun durumu',
            caption: 'Temel ilerleme değerleri',
          ),
          const SizedBox(height: 12),
          for (final entry in _fields.entries)
            _field(entry.key, _label(entry.key)),
          const SizedBox(height: 12),
          const AppSectionHeader(
            title: 'Yetenekler',
            caption: '0–1000 arası değerler',
          ),
          const SizedBox(height: 12),
          for (final skill in SkillId.values) _skillField(skill),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: widget.session.isBusy ? null : _save,
            icon: const Icon(Icons.save_rounded),
            label: const Text('Verileri kaydet'),
          ),
        ],
      ),
    );
  }

  String _label(String key) => const {
    'money': 'Para',
    'energy': 'Enerji',
    'maxEnergy': 'Maksimum enerji',
    'knowledge': 'Genel bilgi',
    'experience': 'Tecrübe',
    'day': 'Oyun günü',
    'hour': 'Oyun saati (0–23)',
    'careerLevel': 'Kariyer seviyesi',
    'companyFunds': 'Şirket kasası',
    'performance': 'Performans (0–100)',
  }[key]!;

  Widget _field(String key, String label) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: TextField(
      controller: _fields[key],
      keyboardType: const TextInputType.numberWithOptions(signed: true),
      inputFormatters: [
        BoundedIntegerInputFormatter(minimum: key == 'money' ? -1000000000 : 0),
      ],
      decoration: InputDecoration(labelText: label),
    ),
  );

  Widget _skillField(SkillId skill) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: TextField(
      controller: _skillFields[skill],
      keyboardType: const TextInputType.numberWithOptions(signed: false),
      inputFormatters: [
        BoundedIntegerInputFormatter(maximum: SkillProfile.maxValue),
      ],
      decoration: InputDecoration(
        labelText: '${skill.label} (0–${SkillProfile.maxValue})',
      ),
    ),
  );

  Future<void> _save() async {
    final values = <String, int?>{
      for (final entry in _fields.entries)
        entry.key: int.tryParse(entry.value.text.trim()),
    };
    if (values.values.any((value) => value == null)) {
      return _show('Tüm alanlara geçerli tam sayı gir.');
    }
    final skillValues = <SkillId, int?>{
      for (final entry in _skillFields.entries)
        entry.key: int.tryParse(entry.value.text.trim()),
    };
    if (skillValues.values.any((value) => value == null)) {
      return _show('Tüm yetenek alanlarına geçerli tam sayı gir.');
    }
    final message = await widget.session.updateDebugState(
      DebugStatePatch(
        money: values['money']!,
        energy: values['energy']!,
        maxEnergy: values['maxEnergy']!,
        knowledge: values['knowledge']!,
        experience: values['experience']!,
        day: values['day']!,
        hour: values['hour']!,
        careerLevel: values['careerLevel']!,
        companyFunds: values['companyFunds']!,
        performance: values['performance']!,
        skills: {
          for (final entry in skillValues.entries) entry.key: entry.value!,
        },
      ),
    );
    if (mounted && message != null) _show(message);
  }

  void _show(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
}
