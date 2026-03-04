import 'package:flutter_test/flutter_test.dart';
import 'package:theraflow/src/utils/validators.dart';

void main() {
  group('Validators', () {
    group('Email', () {
      test('E-mail válido', () {
        expect(Validators.email('teste@example.com'), null);
        expect(Validators.email('user.name@example.co.uk'), null);
        expect(Validators.email('123@test.com'), null);
      });

      test('E-mail inválido', () {
        expect(Validators.email(''), 'E-mail é obrigatório');
        expect(Validators.email('   '), 'E-mail é obrigatório');
        expect(Validators.email('invalido'), 'E-mail inválido');
        expect(Validators.email('@example.com'), 'E-mail inválido');
        expect(Validators.email('teste@'), 'E-mail inválido');
        expect(Validators.email('teste@.com'), 'E-mail inválido');
      });
    });

    group('Password', () {
      test('Senha válida', () {
        expect(Validators.password('123456'), null);
        expect(Validators.password('senhaforte123'), null);
      });

      test('Senha inválida', () {
        expect(Validators.password(''), 'Senha é obrigatória');
        expect(Validators.password('12345'), 'Senha deve ter pelo menos 6 caracteres');
        expect(Validators.password('abc', minLength: 8), 'Senha deve ter pelo menos 8 caracteres');
      });
    });

    group('Name', () {
      test('Nome válido', () {
        expect(Validators.name('João'), null);
        expect(Validators.name('Maria Silva'), null);
        expect(Validators.name('Pedro de Souza'), null);
      });

      test('Nome inválido', () {
        expect(Validators.name(''), 'Nome é obrigatório');
        expect(Validators.name('   '), 'Nome é obrigatório');
        expect(Validators.name('A'), 'Nome deve ter pelo menos 2 caracteres');
      });
    });

    group('Phone', () {
      test('Telefone válido', () {
        expect(Validators.phone('11999998888'), null);
        expect(Validators.phone('(11) 99999-8888'), null);
        expect(Validators.phone('1133334444'), null);
        expect(Validators.phone('(11) 3333-4444'), null);
      });

      test('Telefone inválido', () {
        expect(Validators.phone('123'), 'Telefone inválido');
        expect(Validators.phone(''), 'Telefone é obrigatório');
        expect(Validators.phone('', required: false), null);
      });
    });

    group('Currency', () {
      test('Valor monetário válido', () {
        expect(Validators.currency('150'), null);
        expect(Validators.currency('150.50'), null);
        expect(Validators.currency('150,50'), null);
      });

      test('Valor monetário inválido', () {
        expect(Validators.currency(''), 'Valor é obrigatório');
        expect(Validators.currency('abc'), 'Valor inválido');
        expect(Validators.currency('50', min: 100), 'Valor deve ser maior que R\$ 100.00');
      });
    });

    group('Integer', () {
      test('Número inteiro válido', () {
        expect(Validators.integer('10'), null);
        expect(Validators.integer('0'), null);
        expect(Validators.integer('1000'), null);
      });

      test('Número inteiro inválido', () {
        expect(Validators.integer(''), 'Campo obrigatório');
        expect(Validators.integer('abc'), 'Número inválido');
        expect(Validators.integer('10.5'), 'Número inválido');
        expect(Validators.integer('5', min: 10), 'Valor deve ser maior ou igual a 10');
        expect(Validators.integer('100', max: 50), 'Valor deve ser menor ou igual a 50');
      });
    });

    group('Combine validators', () {
      test('Múltiplos validadores', () {
        final validator = Validators.combine([
          Validators.required,
          (value) => Validators.email(value),
        ]);

        expect(validator('teste@example.com'), null);
        expect(validator(''), 'Campo obrigatório');
        expect(validator('invalido'), 'E-mail inválido');
      });
    });
  });
}
