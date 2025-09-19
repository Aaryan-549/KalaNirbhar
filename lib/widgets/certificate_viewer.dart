import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_theme.dart';

class CertificateViewer extends StatelessWidget {
  final Map<String, dynamic> certificate;
  final bool showDetails;

  const CertificateViewer({
    super.key,
    required this.certificate,
    this.showDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryBlue,
            AppTheme.lightBlue,
            Colors.white,
          ],
          stops: const [0.0, 0.3, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildProductInfo(),
            if (showDetails) ...[
              const SizedBox(height: 20),
              _buildBlockchainInfo(),
              const SizedBox(height: 20),
              _buildActions(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.verified,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'प्रामाणिकता प्रमाणपत्र',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                ),
              ),
              Text(
                'Certificate of Authenticity',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'VERIFIED',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            certificate['productName'] ?? 'Handicraft Product',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Created by ${certificate['artisanName'] ?? 'Anonymous Artisan'}',
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textLight,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              _buildInfoItem('शिल्प प्रकार', certificate['craftType'] ?? 'Traditional Craft'),
              const SizedBox(width: 20),
              _buildInfoItem('स्थान', certificate['location'] ?? 'India'),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              _buildInfoItem('निर्माण दिनांक', _formatDate(certificate['createdAt'])),
              const SizedBox(width: 20),
              _buildInfoItem('Trust Score', '${certificate['trustScore'] ?? 98.5}%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textLight,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _buildBlockchainInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.link,
                color: AppTheme.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Blockchain Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          _buildBlockchainDetail('Network', certificate['network'] ?? 'Polygon Mumbai'),
          _buildBlockchainDetail('Token ID', certificate['tokenId'] ?? 'N/A'),
          _buildBlockchainDetail('Contract', _shortenAddress(certificate['contractAddress'] ?? '')),
          _buildBlockchainDetail('Transaction', _shortenAddress(certificate['transactionHash'] ?? '')),
        ],
      ),
    );
  }

  Widget _buildBlockchainDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textLight,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.textDark,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _viewOnBlockchain(),
            icon: const Icon(Icons.open_in_new, size: 18),
            label: const Text('View on Blockchain'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _shareCertificate(context),
            icon: const Icon(Icons.share, size: 18),
            label: const Text('Share'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryBlue,
              side: const BorderSide(color: AppTheme.primaryBlue),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _viewOnBlockchain() async {
    final url = certificate['explorerUrl'] as String?;
    if (url != null && await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _shareCertificate(BuildContext context) {
    final tokenId = certificate['tokenId'] as String?;
    final shareText = 'Check out this verified handicraft certificate on KalaNirbhar!\n\n'
        'Product: ${certificate['productName']}\n'
        'Artisan: ${certificate['artisanName']}\n'
        'Verified on Blockchain ✓\n\n'
        'Verify: https://kalanirbhar.com/verify/$tokenId';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Certificate'),
        content: SelectableText(shareText),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              // In a real app, you'd use the share plugin
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Certificate link copied!')),
              );
            },
            child: const Text('Copy Link'),
          ),
        ],
      ),
    );
  }

  String _shortenAddress(String address) {
    if (address.length <= 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}