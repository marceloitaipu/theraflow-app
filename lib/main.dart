import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'src/app_router.dart';
import 'src/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar dados de localização para português
  await initializeDateFormatting('pt_BR', null);
  
  // TODO: Inicialize Firebase aqui no projeto real:
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const TheraFlowApp());
}

class TheraFlowApp extends StatelessWidget {
  const TheraFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TheraFlow',
      theme: AppTheme.light(),
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
