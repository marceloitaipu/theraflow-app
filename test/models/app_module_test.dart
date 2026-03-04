import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theraflow/src/models/app_module.dart';

void main() {
  group('AppModule Enum', () {
    test('contém 4 módulos', () {
      expect(AppModule.values.length, 4);
    });

    test('tem valores esperados', () {
      expect(AppModule.values, contains(AppModule.therapy));
      expect(AppModule.values, contains(AppModule.aesthetics));
      expect(AppModule.values, contains(AppModule.podiatry));
      expect(AppModule.values, contains(AppModule.massage));
    });

    group('displayName', () {
      test('retorna nomes em português', () {
        expect(AppModule.therapy.displayName, 'Terapia');
        expect(AppModule.aesthetics.displayName, 'Estética');
        expect(AppModule.podiatry.displayName, 'Podologia');
        expect(AppModule.massage.displayName, 'Massagem');
      });
    });

    group('icon', () {
      test('retorna ícones MaterialIcons', () {
        for (final module in AppModule.values) {
          expect(module.icon, isA<IconData>());
        }
      });
    });

    group('description', () {
      test('retorna descrições não vazias', () {
        for (final module in AppModule.values) {
          expect(module.description.isNotEmpty, true);
        }
      });
    });

    group('fromString', () {
      test('parseia valores válidos', () {
        expect(AppModule.fromString('therapy'), AppModule.therapy);
        expect(AppModule.fromString('aesthetics'), AppModule.aesthetics);
        expect(AppModule.fromString('podiatry'), AppModule.podiatry);
        expect(AppModule.fromString('massage'), AppModule.massage);
      });

      test('retorna therapy como fallback para valor desconhecido', () {
        expect(AppModule.fromString('unknown'), AppModule.therapy);
        expect(AppModule.fromString(''), AppModule.therapy);
      });
    });
  });
}
