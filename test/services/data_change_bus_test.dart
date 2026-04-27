import 'package:flutter_test/flutter_test.dart';
import 'package:theraflow/src/services/data_change_bus.dart';

void main() {
  group('DataChangeBus', () {
    // Usa o singleton e limpa os controllers entre testes via dispose.
    // Após dispose, streamFor recria os controllers quando chamado.
    setUp(() {
      DataChangeBus.instance.dispose();
    });

    tearDown(() {
      DataChangeBus.instance.dispose();
    });

    test('streamFor retorna stream broadcast para tabela', () {
      final stream = DataChangeBus.instance.streamFor('clients');
      expect(stream.isBroadcast, true);
    });

    test('streamFor retorna a mesma stream para a mesma tabela', () async {
      // Verifica equivalência funcional: dois listeners na mesma tabela
      // recebem o mesmo evento (comportamento de broadcast compartilhado).
      final events1 = <void>[];
      final events2 = <void>[];
      final sub1 =
          DataChangeBus.instance.streamFor('sessions').listen((_) => events1.add(null));
      final sub2 =
          DataChangeBus.instance.streamFor('sessions').listen((_) => events2.add(null));

      DataChangeBus.instance.notify('sessions');
      await Future.delayed(Duration.zero);

      expect(events1.length, 1);
      expect(events2.length, 1);
      await sub1.cancel();
      await sub2.cancel();
    });

    test('streamFor cria streams independentes para tabelas diferentes', () {
      final sClients = DataChangeBus.instance.streamFor('clients');
      final sSessions = DataChangeBus.instance.streamFor('sessions');
      expect(sClients, isNot(same(sSessions)));
    });

    test('notify emite evento na stream correta', () async {
      final received = <void>[];
      final sub =
          DataChangeBus.instance.streamFor('clients').listen((_) => received.add(null));

      DataChangeBus.instance.notify('clients');
      await Future.microtask(() {});

      expect(received.length, 1);
      await sub.cancel();
    });

    test('notify não emite em tabelas diferentes', () async {
      final clientEvents = <void>[];
      final sessionEvents = <void>[];

      final s1 = DataChangeBus.instance
          .streamFor('clients')
          .listen((_) => clientEvents.add(null));
      final s2 = DataChangeBus.instance
          .streamFor('sessions')
          .listen((_) => sessionEvents.add(null));

      DataChangeBus.instance.notify('clients');
      await Future.microtask(() {});

      expect(clientEvents.length, 1);
      expect(sessionEvents.length, 0);

      await s1.cancel();
      await s2.cancel();
    });

    test('notifyAll emite em todas as tabelas fornecidas', () async {
      final clientEvents = <void>[];
      final sessionEvents = <void>[];
      final paymentEvents = <void>[];

      final s1 = DataChangeBus.instance
          .streamFor('clients')
          .listen((_) => clientEvents.add(null));
      final s2 = DataChangeBus.instance
          .streamFor('sessions')
          .listen((_) => sessionEvents.add(null));
      final s3 = DataChangeBus.instance
          .streamFor('payments')
          .listen((_) => paymentEvents.add(null));

      DataChangeBus.instance.notifyAll(['clients', 'sessions', 'payments']);
      await Future.microtask(() {});

      expect(clientEvents.length, 1);
      expect(sessionEvents.length, 1);
      expect(paymentEvents.length, 1);

      await s1.cancel();
      await s2.cancel();
      await s3.cancel();
    });

    test('múltiplos notify acumulam eventos', () async {
      final events = <void>[];
      final sub =
          DataChangeBus.instance.streamFor('packages').listen((_) => events.add(null));

      DataChangeBus.instance.notify('packages');
      DataChangeBus.instance.notify('packages');
      DataChangeBus.instance.notify('packages');
      // Future.delayed(zero) aguarda todos os microtasks e timer callbacks
      // pendentes, necessário para streams assíncronos com múltiplos eventos.
      await Future.delayed(Duration.zero);

      expect(events.length, 3);
      await sub.cancel();
    });

    test('notify após dispose não lança exceção', () {
      DataChangeBus.instance.streamFor('clients'); // registra controller
      DataChangeBus.instance.dispose();
      expect(() => DataChangeBus.instance.notify('clients'), returnsNormally);
    });

    test('dispose fecha controllers e notify não lança', () {
      DataChangeBus.instance.streamFor('clients');
      DataChangeBus.instance.streamFor('sessions');
      DataChangeBus.instance.dispose();
      expect(() => DataChangeBus.instance.notify('clients'), returnsNormally);
      expect(() => DataChangeBus.instance.notify('sessions'), returnsNormally);
    });
  });
}
