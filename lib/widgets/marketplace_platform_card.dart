import 'package:flutter/material.dart';

class MarketplacePlatformCard extends StatelessWidget {
  final String platformName;
  final String platformIcon;
  final Color backgroundColor;
  final VoidCallback? onTap;

  const MarketplacePlatformCard({
    super.key,
    required this.platformName,
    required this.platformIcon,
    required this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      child: Center(
        child: Text(
          platformName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}