import 'package:flutter/material.dart';

import 'loyalty_banner.dart';

/// Dashboard home loyalty hero — delegates to [LoyaltyBanner].
class DashboardCashbackHero extends StatelessWidget {
  const DashboardCashbackHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoyaltyBanner(mode: LoyaltyBannerMode.dashboard);
  }
}
