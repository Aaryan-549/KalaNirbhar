import 'package:flutter/material.dart';
import 'marketplace_page.dart';

class AmazonMarketplaceScreen extends StatelessWidget {
  const AmazonMarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MarketplacePage(
      marketplaceName: 'Amazon',
      marketplaceColor: Color(0xFF232F3E),
      logoAsset: 'assets/amazon-logo.png',
    );
  }
}