import 'package:flutter/material.dart';

import '../theme/netube_theme.dart';

class PremiumPage extends StatefulWidget {
  const PremiumPage({super.key});

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  int _selectedPlan = 1;

  static const _plans = [
    _PremiumPlan('Monthly', 'Rp29.000', '/month', 'Flexible, cancel anytime'),
    _PremiumPlan('Annual', 'Rp249.000', '/year', 'Save 28% • Best value'),
    _PremiumPlan('Family', 'Rp59.000', '/month', 'Up to 5 family members'),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: const Color(0xFF090705),
          title: const Text(
            'Netube Premium',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          actions: [
            TextButton(
              onPressed: _showBillingNotice,
              child: const Text(
                'Restore',
                style: TextStyle(color: Color(0xFFFFD36A)),
              ),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              const _PremiumHero(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 26, 16, 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Everything you get',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const _BenefitsCard(),
                    const SizedBox(height: 30),
                    const Text(
                      'Choose your plan',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Change or cancel your plan anytime.',
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(
                      _plans.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 11),
                        child: _PlanCard(
                          plan: _plans[index],
                          selected: _selectedPlan == index,
                          recommended: index == 1,
                          onTap: () => setState(() => _selectedPlan = index),
                        ),
                      ),
                    ),
                    const SizedBox(height: 13),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: _showBillingNotice,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD36A),
                          foregroundColor: const Color(0xFF17100B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Continue with ${_plans[_selectedPlan].name}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'YouTube ads and features inside the official YouTube player are controlled by YouTube and are not removed by Netube Premium. Prices shown are product proposals and must be configured in Google Play Console.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  void _showBillingNotice() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: NetubeColors.surfaceHigh,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              color: Color(0xFFFFD36A),
              size: 34,
            ),
            const SizedBox(height: 14),
            const Text(
              'Google Play Billing required',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 9),
            const Text(
              'This premium experience is ready for billing integration. Add the subscription products in Google Play Console before accepting real payments.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60, height: 1.45),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumHero extends StatelessWidget {
  const _PremiumHero();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(24, 34, 24, 38),
    decoration: const BoxDecoration(
      gradient: RadialGradient(
        center: Alignment.topRight,
        radius: 1.35,
        colors: [Color(0xFF4A2710), Color(0xFF190B0D), Color(0xFF090705)],
      ),
    ),
    child: const Column(
      children: [
        Icon(
          Icons.workspace_premium_rounded,
          color: Color(0xFFFFD36A),
          size: 64,
        ),
        SizedBox(height: 18),
        Text(
          'Entertainment, elevated.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.w900,
            letterSpacing: -.7,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Unlock the best Netube experience across your devices.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white60, fontSize: 15, height: 1.45),
        ),
      ],
    ),
  );
}

class _BenefitsCard extends StatelessWidget {
  const _BenefitsCard();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 7),
    decoration: BoxDecoration(
      color: NetubeColors.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withValues(alpha: .06)),
    ),
    child: const Column(
      children: [
        _Benefit(
          icon: Icons.block_rounded,
          title: 'No Netube ads',
          description: 'Enjoy Netube-owned content without Netube advertising.',
        ),
        _Benefit(
          icon: Icons.download_for_offline_outlined,
          title: 'Offline downloads',
          description: 'Save eligible Netube content and watch it anywhere.',
        ),
        _Benefit(
          icon: Icons.hd_rounded,
          title: 'Best available quality',
          description:
              'Stream Netube content at its highest available quality.',
        ),
        _Benefit(
          icon: Icons.devices_rounded,
          title: 'Watch across devices',
          description: 'Keep your Premium access wherever you sign in.',
        ),
        _Benefit(
          icon: Icons.diamond_outlined,
          title: 'Premium badge & early access',
          description: 'Stand out and try selected new Netube features first.',
        ),
      ],
    ),
  );
}

class _Benefit extends StatelessWidget {
  const _Benefit({
    required this.icon,
    required this.title,
    required this.description,
  });
  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0x18FFD36A),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: const Color(0xFFFFD36A), size: 21),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 3),
              Text(
                description,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.selected,
    required this.recommended,
    required this.onTap,
  });
  final _PremiumPlan plan;
  final bool selected;
  final bool recommended;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? const Color(0xFF241C10) : NetubeColors.surface,
    borderRadius: BorderRadius.circular(18),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? const Color(0xFFFFD36A) : Colors.white10,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? const Color(0xFFFFD36A) : Colors.white30,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        plan.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      if (recommended) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD36A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'BEST VALUE',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plan.note,
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                text: plan.price,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
                children: [
                  TextSpan(
                    text: plan.period,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _PremiumPlan {
  const _PremiumPlan(this.name, this.price, this.period, this.note);
  final String name;
  final String price;
  final String period;
  final String note;
}
