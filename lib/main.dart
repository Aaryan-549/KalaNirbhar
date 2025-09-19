import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/ai_assistant_provider.dart';
import 'screens/language_selection_screen.dart';
import 'services/dynamic_localization_service.dart';
import 'utils/app_theme.dart';

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
            debugShowCheckedModeBanner: false,
            home: const LanguageSelectionScreen(),
            builder: (context, child) {
              // Initialize localization when language changes
              if (appProvider.selectedLanguage.isNotEmpty) {
                DynamicLocalizationService.initialize(appProvider.selectedLanguage);
              }
              return child!;
            },
          );
        },
      ),
    );
  }
}