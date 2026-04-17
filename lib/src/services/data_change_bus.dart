import 'dart:async';

/// Barramento simples de notificação de mudanças em dados locais.
///
/// Substitui `Stream.periodic` usado para polling: serviços emitem [notify]
/// após create/update/delete, e as streams reativas (`getXxxStream`) refazem
/// a query do SQLite apenas quando há mudança real.
///
/// Também é usado pelo `IncrementalSyncService` após cada pull bem-sucedido.
class DataChangeBus {
  DataChangeBus._();
  static final instance = DataChangeBus._();

  // Os controllers persistem durante o ciclo de vida do app (singleton).
  // ignore: close_sinks
  final _controllers = <String, StreamController<void>>{};

  /// Stream broadcast de mudanças para uma [table] (ex: `clients`, `sessions`).
  Stream<void> streamFor(String table) {
    return _controllers
        .putIfAbsent(
          table,
          () => StreamController<void>.broadcast(),
        )
        .stream;
  }

  /// Notifica que a [table] teve dados alterados. Chame após commit local.
  void notify(String table) {
    final c = _controllers[table];
    if (c != null && !c.isClosed) {
      c.add(null);
    }
  }

  /// Notifica várias tabelas (usado após pull do Firestore).
  void notifyAll(Iterable<String> tables) {
    for (final t in tables) {
      notify(t);
    }
  }
}
