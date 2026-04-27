// Arquivo principal para executar todos os testes do TheraFlow
// Execute com: flutter test test/all_tests.dart

// Models
import 'models/package_test.dart' as package_test;
import 'models/package_extended_test.dart' as package_extended_test;
import 'models/user_test.dart' as user_test;
import 'models/user_extended_test.dart' as user_extended_test;
import 'models/session_test.dart' as session_test;
import 'models/session_extended_test.dart' as session_extended_test;
import 'models/app_module_test.dart' as app_module_test;
import 'models/client_test.dart' as client_test;
import 'models/payment_test.dart' as payment_test;

// Services
import 'services/finance_service_test.dart' as finance_service_test;
import 'services/finance_classes_test.dart' as finance_classes_test;
import 'services/billing_service_test.dart' as billing_service_test;
import 'services/data_change_bus_test.dart' as data_change_bus_test;
import 'services/client_status_classifier_test.dart'
    as client_status_classifier_test;
import 'services/performance_service_test.dart' as performance_service_test;
import 'services/export_service_test.dart' as export_service_test;

// Utils
import 'utils/validators_test.dart' as validators_test;
import 'utils/formatters_test.dart' as formatters_test;

// Widgets
import 'widgets/primary_button_test.dart' as primary_button_test;
import 'widgets/section_title_test.dart' as section_title_test;
import 'widgets/revenue_sparkline_test.dart' as revenue_sparkline_test;

// Config
import 'config/app_config_test.dart' as app_config_test;

void main() {
  // Models
  package_test.main();
  package_extended_test.main();
  user_test.main();
  user_extended_test.main();
  session_test.main();
  session_extended_test.main();
  app_module_test.main();
  client_test.main();
  payment_test.main();

  // Services
  finance_service_test.main();
  finance_classes_test.main();
  billing_service_test.main();
  data_change_bus_test.main();
  client_status_classifier_test.main();
  performance_service_test.main();
  export_service_test.main();

  // Utils
  validators_test.main();
  formatters_test.main();

  // Widgets
  primary_button_test.main();
  section_title_test.main();
  revenue_sparkline_test.main();

  // Config
  app_config_test.main();
}
