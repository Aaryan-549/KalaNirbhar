import 'package:flutter/material.dart';
import 'marketplace_page.dart';

class EtsyMarketplaceScreen extends StatelessWidget {
  const EtsyMarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MarketplacePage(
      marketplaceName: 'Etsy',
      marketplaceColor: Color(0xFFD56638),
      logoAsset: 'assets/etsy.png',
    );
  }
}