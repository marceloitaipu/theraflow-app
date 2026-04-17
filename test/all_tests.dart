// Arquivo principal para executar todos os testes do TheraFlow
// Execute com: flutter test

import 'models/package_test.dart' as package_test;
import 'models/user_test.dart' as user_test;
import 'models/session_test.dart' as session_test;
import 'models/app_module_test.dart' as app_module_test;
import 'services/finance_service_test.dart' as finance_service_test;
import 'widgets/primary_button_test.dart' as primary_button_test;
import 'widgets/section_title_test.dart' as section_title_test;

void main() {
  package_test.main();
  user_test.main();
  session_test.main();
  app_module_test.main();
  finance_service_test.main();
  primary_button_test.main();
  section_title_test.main();
}
