import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theraflow/src/models/client.dart';

void main() {
  group('Client Model', () {
    group('construtor e propriedades', () {
      test('cria client com valores corretos', () {
        final now = DateTime(2026, 1, 15);
        final client = Client(
          id: 'c1',
          userId: 'u1',
          name: 'Ana Lima',
          phone: '11999990000',
          notes: 'Notas',
          createdAt: now,
          updatedAt: now,
          status: 'active',
        );

        expect(client.id, 'c1');
        expect(client.userId, 'u1');
        expect(client.name, 'Ana Lima');
        expect(client.phone, '11999990000');
        expect(client.notes, 'Notas');
        expect(client.status, 'active');
        expect(client.deletedAt, isNull);
      });

      test('status padrão é active', () {
        final client = Client(
          id: '1',
          userId: 'u1',
          name: 'Test',
          phone: '',
          notes: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(client.status, 'active');
      });
    });

    group('isActive / isInactive', () {
      test('isActive retorna true para status active', () {
        final client = Client(
          id: '1',
          userId: 'u1',
          name: 'Test',
          phone: '',
          notes: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          status: 'active',
        );

        expect(client.isActive, true);
        expect(client.isInactive, false);
      });

      test('isInactive retorna true para status inactive', () {
        final client = Client(
          id: '1',
          userId: 'u1',
          name: 'Test',
          phone: '',
          notes: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          status: 'inactive',
        );

        expect(client.isInactive, true);
        expect(client.isActive, false);
      });
    });

    group('displayName', () {
      test('retorna nome simples para cliente ativo', () {
        final client = Client(
          id: '1',
          userId: 'u1',
          name: 'Maria',
          phone: '',
          notes: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          status: 'active',
        );

        expect(client.displayName, 'Maria');
      });

      test('acrescenta (inativo) para cliente inativo', () {
        final client = Client(
          id: '1',
          userId: 'u1',
          name: 'Maria',
          phone: '',
          notes: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          status: 'inactive',
        );

        expect(client.displayName, 'Maria (inativo)');
      });
    });

    group('toMap / fromMap', () {
      test('toMap serializa todos os campos', () {
        final now = DateTime(2026, 3, 10);
        final client = Client(
          id: '1',
          userId: 'u1',
          name: 'João',
          phone: '11988887777',
          notes: 'Alergia a látex',
          createdAt: now,
          updatedAt: now,
          status: 'active',
        );

        final map = client.toMap();

        expect(map['userId'], 'u1');
        expect(map['name'], 'João');
        expect(map['phone'], '11988887777');
        expect(map['notes'], 'Alergia a látex');
        expect(map['status'], 'active');
        expect(map['createdAt'], now.toIso8601String());
        expect(map['deletedAt'], isNull);
      });

      test('fromMap recria o client corretamente', () {
        final now = DateTime(2026, 2, 20);
        final map = {
          'userId': 'u2',
          'name': 'Paula',
          'phone': '21977776666',
          'notes': '',
          'status': 'inactive',
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
          'deletedAt': null,
        };

        final client = Client.fromMap('abc', map);

        expect(client.id, 'abc');
        expect(client.name, 'Paula');
        expect(client.status, 'inactive');
        expect(client.deletedAt, isNull);
      });

      test('fromMap aceita Timestamp do Firestore', () {
        final ts = Timestamp.fromDate(DateTime(2026, 1, 1));
        final map = {
          'userId': 'u1',
          'name': 'Carlos',
          'phone': '',
          'notes': '',
          'status': 'active',
          'createdAt': ts,
          'updatedAt': ts,
        };

        final client = Client.fromMap('id1', map);

        expect(client.createdAt, ts.toDate());
      });

      test('fromMap usa defaults quando campos ausentes', () {
        final map = {
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };

        final client = Client.fromMap('x', map);

        expect(client.userId, '');
        expect(client.name, '');
        expect(client.phone, '');
        expect(client.status, 'active');
      });
    });

    group('copyWith', () {
      test('copia e altera apenas campos fornecidos', () {
        final now = DateTime(2026, 1, 1);
        final original = Client(
          id: '1',
          userId: 'u1',
          name: 'Ana',
          phone: '11111111111',
          notes: '',
          createdAt: now,
          updatedAt: now,
          status: 'active',
        );

        final updated = original.copyWith(name: 'Ana Paula', status: 'inactive');

        expect(updated.id, original.id);
        expect(updated.userId, original.userId);
        expect(updated.name, 'Ana Paula');
        expect(updated.phone, original.phone);
        expect(updated.status, 'inactive');
      });

      test('updatedAt é atualizado quando não fornecido', () {
        final past = DateTime(2025, 1, 1);
        final client = Client(
          id: '1',
          userId: 'u1',
          name: 'Test',
          phone: '',
          notes: '',
          createdAt: past,
          updatedAt: past,
        );

        final updated = client.copyWith(name: 'Novo');

        expect(updated.updatedAt.isAfter(past), true);
      });

      test('deletedAt preservado quando não fornecido', () {
        final deleted = DateTime(2026, 4, 1);
        final client = Client(
          id: '1',
          userId: 'u1',
          name: 'Test',
          phone: '',
          notes: '',
          createdAt: DateTime(2025),
          updatedAt: DateTime(2025),
          deletedAt: deleted,
        );

        final copy = client.copyWith(name: 'Novo');

        expect(copy.deletedAt, deleted);
      });
    });
  });
}
