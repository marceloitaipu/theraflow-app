import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'src/app_router.dart';
import 'src/theme/app_theme.dart';
import 'src/providers/theme_provider.dart';
import 'src/database/database_helper.dart';
import 'src/services/incremental_sync_service.dart';
import 'src/services/subscription_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar dados de localização para português
  await initializeDateFormatting('pt_BR', null);
  
  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Inicializar banco de dados local
  await DatabaseHelper.instance.database;
  
  // Inicializar sincronização incremental
  await IncrementalSyncService.instance.initialize();
  
  // Inicializar serviço de assinaturas
  await SubscriptionService.instance.initialize();
  
  // Inicializar tema
  final themeProvider = ThemeProvider();
  await themeProvider.initialize();
  
  runApp(
    ChangeNotifierProvider.value(
      value: themeProvider,
      child: const TheraFlowApp(),
    ),
  );
}

class TheraFlowApp extends StatelessWidget {
  const TheraFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp.router(
      title: 'TheraFlow',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeProvider.themeMode,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      locale: const Locale('pt', 'BR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
    );
  }
}
