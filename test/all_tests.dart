// Arquivo principal para executar todos os testes do TheraFlow
// Execute com: flutter test
//
// Para executar todos os testes de uma vez:
//   flutter test test/
//
// Ou execute este arquivo diretamente (importa todos os testes):

import 'models/package_test.dart' as package_test;
import 'models/user_test.dart' as user_test;
import 'models/session_test.dart' as session_test;
import 'models/business_test.dart' as business_test;
import 'models/app_module_test.dart' as app_module_test;
import 'models/appointment_test.dart' as appointment_test;
import 'services/finance_service_test.dart' as finance_service_test;
import 'services/billing_service_test.dart' as billing_service_test;
import 'services/business_service_test.dart' as business_service_test;
import 'screens/paywall_screen_test.dart' as paywall_screen_test;
import 'widgets/primary_button_test.dart' as primary_button_test;
import 'widgets/section_title_test.dart' as section_title_test;

void main() {
  package_test.main();
  user_test.main();
  session_test.main();
  business_test.main();
  app_module_test.main();
  appointment_test.main();
  finance_service_test.main();
  billing_service_test.main();
  business_service_test.main();
  paywall_screen_test.main();
  primary_button_test.main();
  section_title_test.main();
}
