import 'package:flutter/material.dart';

import '../../../game/presentation/state/game_session_controller.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({required this.session, super.key});

  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const CircleAvatar(radius: 42, child: Icon(Icons.agriculture_outlined, size: 42)),
                const SizedBox(height: 24),
                Text('Kariyerden Şirkete', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                const Text(
                  'Köydeki ilk adımından kendi şirketine uzanan tamamen offline bir kariyer simülasyonuna hoş geldin.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const _IntroItem(icon: Icons.work_outline, text: 'Çalış, eğitim al ve kariyerini geliştir.'),
                const _IntroItem(icon: Icons.location_city_outlined, text: 'Şehir değiştir, yaşam giderlerini yönet.'),
                const _IntroItem(icon: Icons.business_outlined, text: 'Terfi et ve kendi şirketini kur.'),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: session.isBusy ? null : () => _start(context),
                    child: const Text('Oyuna başla'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _start(BuildContext context) async {
    await session.completeOnboarding();
  }
}

class _IntroItem extends StatelessWidget {
  const _IntroItem({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ListTile(leading: Icon(icon, color: Theme.of(context).colorScheme.primary), title: Text(text));
  }
}
