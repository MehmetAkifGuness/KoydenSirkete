import 'package:flutter/material.dart';

import '../../../game/presentation/state/game_session_controller.dart';
import '../../domain/services/company_service.dart';

class CompanyPage extends StatelessWidget {
  const CompanyPage({required this.session, super.key});

  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Şirket')), 
      body: AnimatedBuilder(
        animation: session,
        builder: (context, _) {
          if (session.state.companyLevel == 0) {
            final check = session.checkCompanyEstablishment();
            return _EstablishmentView(session: session, check: check);
          }
          return _CompanyView(session: session);
        },
      ),
    );
  }
}

class _EstablishmentView extends StatelessWidget {
  const _EstablishmentView({required this.session, required this.check});

  final GameSessionController session;
  final CompanyCheck check;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Kendi şirketini kur', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                const Text('Kariyer yolunu tamamladıktan sonra kendi işini büyütmeye başlayabilirsin.'),
                const SizedBox(height: 14),
                Text(check.reason, style: TextStyle(color: check.isEligible ? Colors.greenAccent : Colors.orangeAccent)),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: check.isEligible && !session.isBusy ? () => _establish(context) : null,
                    child: const Text('Şirket kur · ₺1000'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _establish(BuildContext context) async {
    final message = await session.establishCompany();
    if (!context.mounted || message == null) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _CompanyView extends StatelessWidget {
  const _CompanyView({required this.session});

  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    final state = session.state;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Şirket seviyesi ${state.companyLevel}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                Text('Kasa: ₺${state.companyFunds} · Çalışan: ${state.employeeCount}'),
                const SizedBox(height: 12),
                LinearProgressIndicator(value: state.projectProgress / 100),
                const SizedBox(height: 6),
                Text('Aktif proje: %${state.projectProgress}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.tonalIcon(
          onPressed: session.isBusy ? null : () => _recruit(context),
          icon: const Icon(Icons.person_add_alt_1),
          label: const Text('Çalışan al · ₺200'),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: session.isBusy ? null : () => _advance(context),
          icon: const Icon(Icons.rocket_launch_outlined),
          label: const Text('Projeyi ilerlet · ₺100'),
        ),
      ],
    );
  }

  Future<void> _recruit(BuildContext context) async {
    final message = await session.recruitEmployee();
    if (!context.mounted || message == null) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _advance(BuildContext context) async {
    final message = await session.advanceCompanyProject();
    if (!context.mounted || message == null) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
