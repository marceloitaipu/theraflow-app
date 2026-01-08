import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'src/app_router.dart';
import 'src/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
