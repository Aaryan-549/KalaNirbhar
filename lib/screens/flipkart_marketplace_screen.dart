import 'package:flutter/material.dart';
import 'marketplace_page.dart';

class FlipkartMarketplaceScreen extends StatelessWidget {
  const FlipkartMarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MarketplacePage(
      marketplaceName: 'Flipkart',
      marketplaceColor: Color(0xFF2874F0),
      logoAsset: 'assets/flipkart.png',
    );
  }
}