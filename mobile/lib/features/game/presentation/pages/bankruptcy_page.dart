import 'package:flutter/material.dart';

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
    final gold = Theme.of(context).colorScheme.primary;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 58, color: gold),
                    const SizedBox(height: 18),
                    Text('İflas ettin', style: TextStyle(color: gold, fontFamily: 'serif', fontSize: 28, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    const Text(
                      'Paran 24 oyun saati boyunca negatif kaldı.\nKariyer planın sıfırlanıyor.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFFD1C9B8), height: 1.5),
                    ),
                    const SizedBox(height: 26),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _isRestarting ? null : _restart,
                        icon: const Icon(Icons.restart_alt),
                        label: const Text('Baştan başla'),
                      ),
                    ),
                  ],
                ),
              ),
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
