import 'package:flutter/material.dart';

import '../../app/theme/app_palette.dart';
import '../../features/game/domain/entities/player_state.dart';
import '../../features/game/presentation/state/game_session_controller.dart';

class GameAccountRoute extends StatelessWidget {
  const GameAccountRoute({
    required this.session,
    required this.child,
    super.key,
  });

  final GameSessionController session;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: session,
    builder: (context, _) => Column(
      children: [
        GameAccountBar(state: session.state),
        Expanded(child: child),
      ],
    ),
  );
}

class GameAccountBar extends StatelessWidget {
  const GameAccountBar({required this.state, super.key});

  final PlayerState state;

  @override
  Widget build(BuildContext context) => Material(
    color: AppPalette.background,
    child: SafeArea(
      bottom: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppPalette.outlineMuted)),
        ),
        child: GameAccountSummary(state: state),
      ),
    ),
  );
}

class GameAccountSummary extends StatelessWidget {
  const GameAccountSummary({required this.state, super.key});

  final PlayerState state;

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.end,
    spacing: 7,
    runSpacing: 6,
    children: [
      _AccountPill(
        label: 'Kişisel cüzdan',
        amount: state.money,
        icon: Icons.account_balance_wallet_outlined,
        color: AppPalette.primary,
      ),
      _AccountPill(
        label: 'Şirket kasası',
        amount: state.companyFunds,
        icon: Icons.business_outlined,
        color: AppPalette.tertiary,
      ),
    ],
  );
}

class _AccountPill extends StatelessWidget {
  const _AccountPill({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  final String label;
  final int amount;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .10),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 5),
        Text(
          '$label · ₺$amount',
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}
