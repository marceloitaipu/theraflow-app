import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'firebase_options.dart';

import 'src/app_router.dart';
import 'src/config/app_config.dart';
import 'src/theme/app_theme.dart';
import 'src/providers/theme_provider.dart';
import 'src/database/database_helper.dart';
import 'src/services/incremental_sync_service.dart';
import 'src/services/subscription_service.dart';
import 'src/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Mostra qualquer erro fatal de inicialização na tela (visível mesmo em release)
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  try {
    await _bootstrap();
  } catch (e, st) {
    runApp(_StartupErrorApp(error: e, stack: st));
  }
}

Future<void> _bootstrap() async {
  // Inicializar dados de localização para português
  await initializeDateFormatting('pt_BR', null);

  // Inicializar databaseFactory para web/desktop (sqflite não suporta nativamente)
  if (kIsWeb) {
    if (!AppConfig.isWebTestMode) {
      databaseFactory = databaseFactoryFfiWeb;
    }
  } else if (defaultTargetPlatform != TargetPlatform.android &&
      defaultTargetPlatform != TargetPlatform.iOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Inicializar Firebase (guard contra dupla inicialização nativa no Android)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') rethrow;
  }

  // Inicializar auth (desabilita reCAPTCHA Enterprise em debug web)
  await AuthService.instance.initialize();

  // Inicializar banco de dados local e sync.
  // Na web em modo de teste funcional, o app usa Firestore direto.
  if (!AppConfig.isWebTestMode) {
    try {
      await DatabaseHelper.instance.database;
      if (!kIsWeb) {
        await IncrementalSyncService.instance.initialize();
      }
    } catch (e) {
      debugPrint('Falha ao inicializar DB local/sync: $e');
    }
  }

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

class _StartupErrorApp extends StatelessWidget {
  final Object error;
  final StackTrace stack;
  const _StartupErrorApp({required this.error, required this.stack});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.red.shade900,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Erro fatal na inicialização',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    error.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  SelectableText(
                    stack.toString(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
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
