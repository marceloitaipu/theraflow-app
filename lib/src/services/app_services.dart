/// Barrel file — reexporta os models e services V2 usados pelas telas.
///
/// As telas legadas ainda importam `app_services.dart`, então este arquivo
/// centraliza os exports apontando para a arquitetura atual (single-tenant,
/// offline-first, Firebase-backed).
library;

export '../models/client.dart';
export '../models/session.dart';
export '../models/package.dart';
export '../models/payment.dart';
export '../models/user.dart';

export 'auth_service.dart';
export 'client_service.dart';
export 'session_service.dart';
export 'package_service.dart';
export 'finance_service.dart';
