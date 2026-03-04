import 'package:flutter_test/flutter_test.dart';
import 'package:theraflow/src/models/appointment.dart';

void main() {
  group('Appointment Model', () {
    group('constructor', () {
      test('cria appointment com campos obrigatórios', () {
        final now = DateTime.now();
        final appt = Appointment(
          id: 'a1',
          clientId: 'c1',
          staffUid: 'staff1',
          serviceId: 'svc1',
          module: 'therapy',
          startAt: now,
          endAt: now.add(const Duration(minutes: 60)),
          status: 'confirmado',
          price: 150.0,
          paymentStatus: 'pendente',
          createdAt: now,
        );

        expect(appt.id, 'a1');
        expect(appt.clientId, 'c1');
        expect(appt.module, 'therapy');
        expect(appt.price, 150.0);
        expect(appt.metadata, isEmpty);
        expect(appt.packageId, isNull);
      });
    });

    group('durationMin', () {
      test('calcula duração em minutos', () {
        final now = DateTime.now();
        final appt = Appointment(
          id: 'a1',
          clientId: 'c1',
          module: 'therapy',
          startAt: now,
          endAt: now.add(const Duration(minutes: 60)),
          status: 'confirmado',
          price: 150.0,
          paymentStatus: 'pendente',
          createdAt: now,
        );

        expect(appt.durationMin, 60);
      });
    });

    group('metadata', () {
      test('armazena e retorna metadata', () {
        final now = DateTime.now();
        final appt = Appointment(
          id: 'a1',
          clientId: 'c1',
          module: 'therapy',
          startAt: now,
          endAt: now.add(const Duration(minutes: 60)),
          status: 'confirmado',
          price: 150.0,
          paymentStatus: 'pendente',
          metadata: {
            'sessionNotes': 'Paciente relatou melhora',
            'goals': 'Continuar exercícios',
            'homework': 'Meditação diária',
          },
          createdAt: now,
        );

        expect(appt.metadata['sessionNotes'], 'Paciente relatou melhora');
      });

      test('therapyMetadata retorna dados tipados', () {
        final now = DateTime.now();
        final appt = Appointment(
          id: 'a1',
          clientId: 'c1',
          module: 'therapy',
          startAt: now,
          endAt: now.add(const Duration(minutes: 60)),
          status: 'confirmado',
          price: 150.0,
          paymentStatus: 'pendente',
          metadata: {
            'sessionNotes': 'Notas da sessão',
            'goals': 'Metas',
            'homework': 'Tarefa',
          },
          createdAt: now,
        );

        final therapy = appt.therapyMetadata;
        expect(therapy, isNotNull);
        expect(therapy!.sessionNotes, 'Notas da sessão');
        expect(therapy.goals, 'Metas');
        expect(therapy.homework, 'Tarefa');
      });

      test('therapyMetadata retorna null para outro módulo', () {
        final now = DateTime.now();
        final appt = Appointment(
          id: 'a1',
          clientId: 'c1',
          module: 'massage',
          startAt: now,
          endAt: now.add(const Duration(minutes: 60)),
          status: 'confirmado',
          price: 150.0,
          paymentStatus: 'pendente',
          metadata: {'technique': 'Shiatsu'},
          createdAt: now,
        );

        expect(appt.therapyMetadata, isNull);
        expect(appt.massageMetadata, isNotNull);
      });

      test('notes retorna sessionNotes para therapy', () {
        final now = DateTime.now();
        final appt = Appointment(
          id: 'a1',
          clientId: 'c1',
          module: 'therapy',
          startAt: now,
          endAt: now.add(const Duration(minutes: 60)),
          status: 'confirmado',
          price: 150.0,
          paymentStatus: 'pendente',
          metadata: {'sessionNotes': 'Minhas notas'},
          createdAt: now,
        );

        expect(appt.notes, 'Minhas notas');
      });
    });

    group('toMap / fromMap', () {
      test('serializa e deserializa corretamente', () {
        final now = DateTime.now();
        final original = Appointment(
          id: 'a1',
          clientId: 'c1',
          staffUid: 'staff1',
          serviceId: 'svc1',
          module: 'massage',
          startAt: now,
          endAt: now.add(const Duration(minutes: 60)),
          status: 'realizada',
          price: 200.0,
          paymentStatus: 'pago',
          packageId: 'pkg1',
          metadata: {'technique': 'Shiatsu'},
          createdAt: now,
        );

        final map = original.toMap();
        final restored = Appointment.fromMap('a1', map);

        expect(restored.id, original.id);
        expect(restored.clientId, original.clientId);
        expect(restored.module, 'massage');
        expect(restored.price, 200.0);
        expect(restored.packageId, 'pkg1');
        expect(restored.metadata['technique'], 'Shiatsu');
      });

      test('lida com backward compat: dateTime -> startAt', () {
        final now = DateTime.now();
        final map = {
          'clientId': 'c1',
          'staffUid': 'staff1',
          'serviceId': 'svc1',
          'module': 'therapy',
          'dateTime': now.toIso8601String(),
          'status': 'confirmado',
          'price': 150.0,
          'paymentStatus': 'pendente',
          'metadata': <String, dynamic>{},
          'createdAt': now.toIso8601String(),
        };

        final appt = Appointment.fromMap('a1', map);
        expect(appt.startAt.year, now.year);
        expect(appt.startAt.month, now.month);
        expect(appt.startAt.day, now.day);
      });

      test('usa valores padrão quando campos ausentes', () {
        final restored = Appointment.fromMap('a1', {
          'createdAt': DateTime.now().toIso8601String(),
        });

        expect(restored.clientId, '');
        expect(restored.module, 'therapy');
        expect(restored.price, 0.0);
        expect(restored.metadata, isEmpty);
      });
    });

    group('copyWith', () {
      test('permite alterar campos', () {
        final now = DateTime.now();
        final original = Appointment(
          id: 'a1',
          clientId: 'c1',
          staffUid: 'staff1',
          serviceId: 'svc1',
          module: 'therapy',
          startAt: now,
          endAt: now.add(const Duration(minutes: 60)),
          status: 'confirmado',
          price: 150.0,
          paymentStatus: 'pendente',
          createdAt: now,
        );

        final updated = original.copyWith(
          status: 'realizada',
          paymentStatus: 'pago',
        );

        expect(updated.status, 'realizada');
        expect(updated.paymentStatus, 'pago');
        expect(updated.clientId, original.clientId);
        expect(updated.module, original.module);
      });
    });
  });
}
