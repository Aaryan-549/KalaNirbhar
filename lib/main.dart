import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/ai_assistant_provider.dart';
import 'screens/language_selection_screen.dart';
import 'screens/amazon_marketplace_screen.dart';
import 'screens/etsy_marketplace_screen.dart';
import 'screens/flipkart_marketplace_screen.dart';
import 'screens/AddProductScreen.dart';
import 'screens/home_screen.dart';
import 'services/dynamic_localization_service.dart';
import 'utils/app_theme.dart';
import 'widgets/chat_bubble.dart';

// Global navigator key for navigation from anywhere in the app
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KalaNirbharApp());
}

class KalaNirbharApp extends StatelessWidget {
  const KalaNirbharApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => AIAssistantProvider()),
      ],
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return MaterialApp(
            title: 'KalaNirbhar',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            home: const LanguageSelectionScreen(),
            routes: {
              '/home': (context) => const HomeScreen(),
              '/amazon-marketplace': (context) => const AmazonMarketplaceScreen(),
              '/etsy-marketplace': (context) => const EtsyMarketplaceScreen(),
              '/flipkart-marketplace': (context) => const FlipkartMarketplaceScreen(),
              '/add-product': (context) => const AddProductScreen(),
            },
            onGenerateRoute: (settings) {
              // Handle dynamic routes if needed
              switch (settings.name) {
                case '/language-selection':
                  return MaterialPageRoute(
                    builder: (context) => const LanguageSelectionScreen(),
                  );
                default:
                  return null;
              }
            },
            onUnknownRoute: (settings) {
              // Fallback route for unknown routes
              return MaterialPageRoute(
                builder: (context) => const LanguageSelectionScreen(),
              );
            },
            builder: (context, child) {
              // Initialize localization service when language is selected
              if (appProvider.selectedLanguage.isNotEmpty) {
                DynamicLocalizationService.initialize(appProvider.selectedLanguage);
              }
              
              // Return the child widget (the app content)
              return child!;
            },
          );
        },
      ),
    );
  }
}

// Optional: App-wide error handling widget
class AppErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;

  const AppErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
              const SizedBox(height: 24),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                error,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Try Again',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}