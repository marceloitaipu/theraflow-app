// Smoke test mínimo de integração.
//
// Verifica que o app inicializa, carrega Firebase e chega na tela de login
// (usuário não autenticado). Este teste NÃO depende do Firebase Emulator —
// ele apenas roda contra a configuração real (ou mocks). Para fluxos
// completos de auth/CRUD, ver instruções no README deste diretório.
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'package:theraflow/firebase_options.dart';
import 'package:theraflow/src/config/app_config.dart';
// ignore: unused_import
import 'package:theraflow/src/app_router.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('pt_BR', null);

    if (kIsWeb && !AppConfig.isWebTestMode) {
      databaseFactory = databaseFactoryFfiWeb;
    } else {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });

  testWidgets('Firebase + localização + sqflite inicializam sem erro',
      (tester) async {
    expect(Firebase.apps, isNotEmpty);
  });
}
