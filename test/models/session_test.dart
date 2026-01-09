import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theraflow/src/models/session.dart';

void main() {
  group('Session Model', () {
    group('packageId', () {
      test('pode ser nulo', () {
        final session = Session(
          id: '1',
          userId: 'user1',
          clientId: 'client1',
          dateTime: DateTime.now(),
          therapyType: 'Massoterapia',
          status: 'confirmado',
          value: 150.0,
          paymentStatus: 'pendente',
          notes: '',
          packageId: null,
          createdAt: DateTime.now(),
        );

        expect(session.packageId, isNull);
      });

      test('pode ter valor', () {
        final session = Session(
          id: '1',
          userId: 'user1',
          clientId: 'client1',
          dateTime: DateTime.now(),
          therapyType: 'Massoterapia',
          status: 'confirmado',
          value: 150.0,
          paymentStatus: 'pendente',
          notes: '',
          packageId: 'package123',
          createdAt: DateTime.now(),
        );

        expect(session.packageId, 'package123');
      });
    });

    group('toMap / fromMap', () {
      test('serializa packageId quando presente', () {
        final session = Session(
          id: '1',
          userId: 'user1',
          clientId: 'client1',
          dateTime: DateTime.now(),
          therapyType: 'Massoterapia',
          status: 'confirmado',
          value: 150.0,
          paymentStatus: 'pago',
          notes: 'Notas',
          packageId: 'pkg1',
          createdAt: DateTime.now(),
        );

        final map = session.toMap();

        expect(map['packageId'], 'pkg1');
      });

      test('deserializa packageId quando presente', () {
        final map = {
          'userId': 'user1',
          'clientId': 'client1',
          'dateTime': DateTime.now().toIso8601String(),
          'therapyType': 'Massoterapia',
          'status': 'confirmado',
          'value': 150.0,
          'paymentStatus': 'pago',
          'notes': 'Notas',
          'packageId': 'pkg1',
          'createdAt': DateTime.now().toIso8601String(),
        };

        final session = Session.fromMap('1', map);

        expect(session.packageId, 'pkg1');
      });

      test('packageId é nulo quando não está no map', () {
        final map = {
          'userId': 'user1',
          'clientId': 'client1',
          'dateTime': DateTime.now().toIso8601String(),
          'therapyType': 'Massoterapia',
          'status': 'confirmado',
          'value': 150.0,
          'paymentStatus': 'pago',
          'notes': '',
          'createdAt': DateTime.now().toIso8601String(),
        };

        final session = Session.fromMap('1', map);

        expect(session.packageId, isNull);
      });
    });

    group('copyWith', () {
      test('permite alterar packageId', () {
        final original = Session(
          id: '1',
          userId: 'user1',
          clientId: 'client1',
          dateTime: DateTime.now(),
          therapyType: 'Massoterapia',
          status: 'confirmado',
          value: 150.0,
          paymentStatus: 'pendente',
          notes: '',
          packageId: null,
          createdAt: DateTime.now(),
        );

        final updated = original.copyWith(packageId: 'newPackage');

        expect(updated.packageId, 'newPackage');
        expect(updated.clientId, original.clientId);
      });

      test('mantém packageId quando não especificado', () {
        final original = Session(
          id: '1',
          userId: 'user1',
          clientId: 'client1',
          dateTime: DateTime.now(),
          therapyType: 'Massoterapia',
          status: 'confirmado',
          value: 150.0,
          paymentStatus: 'pendente',
          notes: '',
          packageId: 'existingPkg',
          createdAt: DateTime.now(),
        );

        final updated = original.copyWith(status: 'realizada');

        expect(updated.packageId, 'existingPkg');
        expect(updated.status, 'realizada');
      });
    });

    group('status values', () {
      test('aceita status confirmado', () {
        final session = Session(
          id: '1',
          userId: 'user1',
          clientId: 'client1',
          dateTime: DateTime.now(),
          therapyType: 'Massoterapia',
          status: 'confirmado',
          value: 150.0,
          paymentStatus: 'pendente',
          notes: '',
          createdAt: DateTime.now(),
        );

        expect(session.status, 'confirmado');
      });

      test('aceita status realizada', () {
        final session = Session(
          id: '1',
          userId: 'user1',
          clientId: 'client1',
          dateTime: DateTime.now(),
          therapyType: 'Massoterapia',
          status: 'realizada',
          value: 150.0,
          paymentStatus: 'pago',
          notes: '',
          createdAt: DateTime.now(),
        );

        expect(session.status, 'realizada');
      });

      test('aceita status faltou', () {
        final session = Session(
          id: '1',
          userId: 'user1',
          clientId: 'client1',
          dateTime: DateTime.now(),
          therapyType: 'Massoterapia',
          status: 'faltou',
          value: 150.0,
          paymentStatus: 'pendente',
          notes: '',
          createdAt: DateTime.now(),
        );

        expect(session.status, 'faltou');
      });

      test('aceita status remarcado', () {
        final session = Session(
          id: '1',
          userId: 'user1',
          clientId: 'client1',
          dateTime: DateTime.now(),
          therapyType: 'Massoterapia',
          status: 'remarcado',
          value: 150.0,
          paymentStatus: 'pendente',
          notes: '',
          createdAt: DateTime.now(),
        );

        expect(session.status, 'remarcado');
      });
    });

    group('paymentStatus values', () {
      test('aceita paymentStatus pago', () {
        final session = Session(
          id: '1',
          userId: 'user1',
          clientId: 'client1',
          dateTime: DateTime.now(),
          therapyType: 'Massoterapia',
          status: 'realizada',
          value: 150.0,
          paymentStatus: 'pago',
          notes: '',
          createdAt: DateTime.now(),
        );

        expect(session.paymentStatus, 'pago');
      });

      test('aceita paymentStatus pendente', () {
        final session = Session(
          id: '1',
          userId: 'user1',
          clientId: 'client1',
          dateTime: DateTime.now(),
          therapyType: 'Massoterapia',
          status: 'confirmado',
          value: 150.0,
          paymentStatus: 'pendente',
          notes: '',
          createdAt: DateTime.now(),
        );

        expect(session.paymentStatus, 'pendente');
      });
    });
  });
}
