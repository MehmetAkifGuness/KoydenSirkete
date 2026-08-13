import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/app_page.dart';

class BankruptcyPage extends StatefulWidget {
  const BankruptcyPage({required this.onRestart, super.key});

  final Future<void> Function() onRestart;

  @override
  State<BankruptcyPage> createState() => _BankruptcyPageState();
}

class _BankruptcyPageState extends State<BankruptcyPage> {
  bool _isRestarting = false;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Kariyer durdu',
      subtitle: 'Finansal durum yeniden kurulmalı.',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: AppInfoCard(
            accent: AppPalette.error,
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.warning_amber_outlined,
                  size: 36,
                  color: AppPalette.error,
                ),
                const SizedBox(height: 18),
                const Text(
                  'Finansal kriz',
                  style: TextStyle(
                    color: AppPalette.error,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Paran 24 oyun saati boyunca negatif kaldı. Bu kariyer döngüsünü kapatıp yeni bir başlangıç yapmalısın.',
                  style: TextStyle(
                    color: AppPalette.textSecondary,
                    height: 1.5,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isRestarting ? null : _restart,
                    icon: const Icon(Icons.restart_alt_rounded),
                    label: const Text('Yeni kariyer başlat'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _restart() async {
    setState(() => _isRestarting = true);
    await widget.onRestart();
  }
}
