import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
    _skillFields = {for (final skill in SkillId.values) skill: TextEditingController(text: '${state.skills[skill]}')};
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
    return Scaffold(
      appBar: AppBar(title: const Text('Geliştirici verileri')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Bu ekran yalnızca debug APK içinde bulunur. Değerler oyun kurallarındaki güvenli sınırlar içinde kaydedilir.', style: Theme.of(context).textTheme.bodyMedium),
              ),
            ),
            const SizedBox(height: 12),
            _field('money', 'Para'),
            _field('energy', 'Enerji'),
            _field('maxEnergy', 'Maksimum enerji'),
            _field('knowledge', 'Genel bilgi'),
            _field('experience', 'Tecrübe'),
            _field('day', 'Oyun günü'),
            _field('hour', 'Oyun saati (0-23)'),
            _field('careerLevel', 'Kariyer seviyesi'),
            _field('companyFunds', 'Şirket kasası'),
            _field('performance', 'Performans (0-100)'),
            const Padding(
              padding: EdgeInsets.only(top: 8, bottom: 10),
              child: Text('Yetenekler', style: TextStyle(fontFamily: 'serif', fontSize: 20, fontWeight: FontWeight.w700)),
            ),
            for (final skill in SkillId.values) _skillField(skill),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: widget.session.isBusy ? null : _save,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Verileri kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String key, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: _fields[key],
        keyboardType: const TextInputType.numberWithOptions(signed: true),
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      ),
    );
  }

  Widget _skillField(SkillId skill) {
    return _fieldController(_skillFields[skill]!, '${skill.label} (0-${SkillProfile.maxValue})');
  }

  Widget _fieldController(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(signed: false),
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      ),
    );
  }

  Future<void> _save() async {
    final values = <String, int?>{
      for (final entry in _fields.entries) entry.key: int.tryParse(entry.value.text.trim()),
    };
    if (values.values.any((value) => value == null)) {
      _show('Tüm alanlara geçerli tam sayı gir.');
      return;
    }
    final skillValues = <SkillId, int?>{
      for (final entry in _skillFields.entries) entry.key: int.tryParse(entry.value.text.trim()),
    };
    if (skillValues.values.any((value) => value == null)) {
      _show('Tüm yetenek alanlarına geçerli tam sayı gir.');
      return;
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
        skills: {for (final entry in skillValues.entries) entry.key: entry.value!},
      ),
    );
    if (mounted && message != null) {
      _show(message);
    }
  }

  void _show(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
