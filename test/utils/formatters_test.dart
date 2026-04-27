import 'package:flutter_test/flutter_test.dart';
import 'package:theraflow/src/utils/formatters.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR', null);
  });

  group('Formatters', () {
    group('currency', () {
      test('formata valor zero', () {
        final result = Formatters.currency(0.0);
        expect(result, contains('0'));
        expect(result, contains('R\$'));
      });

      test('formata valor inteiro', () {
        final result = Formatters.currency(150.0);
        expect(result, contains('150'));
        expect(result, contains('R\$'));
      });

      test('formata valor com centavos', () {
        final result = Formatters.currency(99.99);
        expect(result, contains('99'));
        expect(result, contains('R\$'));
      });

      test('formata valor grande', () {
        final result = Formatters.currency(10000.0);
        expect(result, contains('R\$'));
      });
    });

    group('date', () {
      test('formata data em dd/MM/yyyy', () {
        final date = DateTime(2026, 4, 27);
        final result = Formatters.date(date);
        expect(result, '27/04/2026');
      });

      test('formata dia e mês com zero à esquerda', () {
        final date = DateTime(2026, 1, 5);
        final result = Formatters.date(date);
        expect(result, '05/01/2026');
      });
    });

    group('dateTime', () {
      test('formata data e hora completos', () {
        final dt = DateTime(2026, 3, 15, 14, 30);
        final result = Formatters.dateTime(dt);
        expect(result, '15/03/2026 14:30');
      });

      test('formata hora com zero à esquerda', () {
        final dt = DateTime(2026, 6, 1, 9, 5);
        final result = Formatters.dateTime(dt);
        expect(result, '01/06/2026 09:05');
      });
    });

    group('time', () {
      test('formata hora e minuto', () {
        final dt = DateTime(2026, 1, 1, 10, 45);
        expect(Formatters.time(dt), '10:45');
      });

      test('formata hora meia-noite', () {
        final dt = DateTime(2026, 1, 1, 0, 0);
        expect(Formatters.time(dt), '00:00');
      });
    });

    group('phone', () {
      test('formata celular com 11 dígitos', () {
        expect(Formatters.phone('11999998888'), '(11) 99999-8888');
      });

      test('formata telefone fixo com 10 dígitos', () {
        expect(Formatters.phone('1133334444'), '(11) 3333-4444');
      });

      test('retorna original para formato desconhecido', () {
        expect(Formatters.phone('123'), '123');
      });

      test('formata número que já contém parênteses', () {
        final result = Formatters.phone('(11) 99999-8888');
        expect(result, '(11) 99999-8888');
      });
    });

    group('duration', () {
      test('formata minutos abaixo de 1 hora', () {
        expect(Formatters.duration(30), '30 min');
        expect(Formatters.duration(45), '45 min');
        expect(Formatters.duration(59), '59 min');
      });

      test('formata exatamente 1 hora', () {
        expect(Formatters.duration(60), '1h');
      });

      test('formata 2 horas', () {
        expect(Formatters.duration(120), '2h');
      });

      test('formata 1h30min', () {
        expect(Formatters.duration(90), '1h 30min');
      });

      test('formata 2h15min', () {
        expect(Formatters.duration(135), '2h 15min');
      });
    });

    group('capitalizeName', () {
      test('capitaliza nome simples', () {
        expect(Formatters.capitalizeName('joão'), 'João');
      });

      test('capitaliza nome composto', () {
        expect(Formatters.capitalizeName('maria silva'), 'Maria Silva');
      });

      test('mantém preposições em minúsculo', () {
        final result = Formatters.capitalizeName('pedro de souza');
        expect(result, 'Pedro de Souza');
      });

      test('trata string vazia', () {
        expect(Formatters.capitalizeName(''), '');
      });

      test('capitaliza nome já em maiúsculo', () {
        final result = Formatters.capitalizeName('ANA LIMA');
        expect(result, 'Ana Lima');
      });

      test('preposições: da, do, das, dos, e', () {
        final result = Formatters.capitalizeName('ana da silva e dos santos');
        expect(result, contains('da'));
        expect(result, contains('dos'));
        expect(result, contains('e'));
        expect(result, contains('Ana'));
        expect(result, contains('Silva'));
        expect(result, contains('Santos'));
      });
    });

    group('cpf', () {
      test('formata CPF com 11 dígitos', () {
        expect(Formatters.cpf('12345678901'), '123.456.789-01');
      });

      test('retorna original para CPF incompleto', () {
        expect(Formatters.cpf('123'), '123');
      });

      test('formata CPF que já contém pontuação', () {
        final result = Formatters.cpf('123.456.789-01');
        expect(result, '123.456.789-01');
      });
    });

    group('digitsOnly', () {
      test('remove caracteres não numéricos', () {
        expect(Formatters.digitsOnly('(11) 99999-8888'), '11999998888');
      });

      test('remove pontos e traços do CPF', () {
        expect(Formatters.digitsOnly('123.456.789-01'), '12345678901');
      });

      test('mantém apenas dígitos de string mista', () {
        expect(Formatters.digitsOnly('abc123def456'), '123456');
      });

      test('string apenas de dígitos não é alterada', () {
        expect(Formatters.digitsOnly('12345'), '12345');
      });

      test('string vazia retorna vazia', () {
        expect(Formatters.digitsOnly(''), '');
      });
    });
  });
}
