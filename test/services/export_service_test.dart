import 'package:flutter_test/flutter_test.dart';
import 'package:theraflow/src/services/export_service.dart';

void main() {
  group('ExportService.buildCsvRow', () {
    // ── formatação básica ─────────────────────────────────────────────────
    group('formatação básica', () {
      test('envolve cada célula em aspas duplas', () {
        final row = ExportService.buildCsvRow(['Nome', 'Telefone', 'Status']);
        expect(row, '"Nome";"Telefone";"Status"');
      });

      test('usa ponto-e-vírgula como separador', () {
        final row = ExportService.buildCsvRow(['A', 'B', 'C']);
        final parts = row.split(';');
        expect(parts.length, 3);
      });

      test('linha com uma única célula', () {
        final row = ExportService.buildCsvRow(['Único']);
        expect(row, '"Único"');
      });

      test('linha vazia retorna string vazia', () {
        final row = ExportService.buildCsvRow([]);
        expect(row, '');
      });

      test('célula com string vazia gera aspas sem conteúdo', () {
        final row = ExportService.buildCsvRow(['']);
        expect(row, '""');
      });
    });

    // ── escape de aspas duplas ─────────────────────────────────────────────
    group('escape de aspas', () {
      test('aspas duplas dentro da célula são dobradas', () {
        final row = ExportService.buildCsvRow(['"Citação"']);
        expect(row, '"""Citação"""');
      });

      test('múltiplas aspas duplas na mesma célula', () {
        final row = ExportService.buildCsvRow(['Disse "olá" e "tchau"']);
        expect(row, '"Disse ""olá"" e ""tchau"""');
      });

      test('célula sem aspas não é alterada', () {
        final row = ExportService.buildCsvRow(['Sem aspas aqui']);
        expect(row, '"Sem aspas aqui"');
      });
    });

    // ── caracteres especiais ──────────────────────────────────────────────
    group('caracteres especiais', () {
      test('células com ponto-e-vírgula são envolvidas corretamente', () {
        // O ponto-e-vírgula dentro da célula NÃO é separador porque está entre aspas
        final row = ExportService.buildCsvRow(['João; Maria']);
        expect(row, '"João; Maria"');
        // A linha deve ter exatamente 1 campo (nenhum separador extra no nível superior)
        // O split no ; vai retornar 2 partes, mas semanticamente é 1 campo CSV
        expect(row.contains('"João; Maria"'), true);
      });

      test('células com quebra de linha são preservadas', () {
        final row = ExportService.buildCsvRow(['Linha 1\nLinha 2']);
        expect(row, '"Linha 1\nLinha 2"');
      });

      test('células com acentos são preservadas', () {
        final row =
            ExportService.buildCsvRow(['Observação', 'Próxima ação', 'Médico']);
        expect(row, '"Observação";"Próxima ação";"Médico"');
      });

      test('células com emojis são preservadas', () {
        final row = ExportService.buildCsvRow(['✅ Confirmado', '⚠️ Pendente']);
        expect(row, '"✅ Confirmado";"⚠️ Pendente"');
      });
    });

    // ── integridade do CSV ────────────────────────────────────────────────
    group('integridade do CSV', () {
      test('número correto de separadores para N campos', () {
        for (int n = 1; n <= 9; n++) {
          final fields = List.generate(n, (i) => 'campo$i');
          final row = ExportService.buildCsvRow(fields);
          // N campos → N-1 separadores de nível superior
          final topLevelSemicolons =
              row.split('"').where((p) => p == ';').length;
          expect(topLevelSemicolons, n - 1,
              reason: 'N=$n deve ter ${n - 1} separadores');
        }
      });

      test('cabeçalho padrão de clientes tem 9 colunas', () {
        final header = ExportService.buildCsvRow([
          'Nome',
          'Telefone',
          'Status CRM',
          'Tags',
          'Objetivo',
          'Frequência ideal',
          'Próxima ação',
          'Cadastrado em',
          'Observações',
        ]);
        final cols = header.split('";');
        expect(cols.length, 9);
      });

      test('cabeçalho de sessões tem 8 colunas', () {
        final header = ExportService.buildCsvRow([
          'Data',
          'Horário',
          'Cliente',
          'Tipo de terapia',
          'Status',
          'Pagamento',
          'Valor',
          'Observações',
        ]);
        final cols = header.split('";');
        expect(cols.length, 8);
      });

      test('cabeçalho de financeiro tem 6 colunas', () {
        final header = ExportService.buildCsvRow([
          'Data',
          'Horário',
          'Cliente',
          'Tipo de terapia',
          'Valor',
          'Status pagamento',
        ]);
        final cols = header.split('";');
        expect(cols.length, 6);
      });
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  group('ExportService.buildFileDate', () {
    test('formata data no padrão yyyyMMdd', () {
      final date = DateTime(2026, 4, 27);
      expect(ExportService.buildFileDate(date), '20260427');
    });

    test('mês e dia com zero à esquerda', () {
      final date = DateTime(2026, 1, 5);
      expect(ExportService.buildFileDate(date), '20260105');
    });

    test('dezembro/31 formatado corretamente', () {
      final date = DateTime(2025, 12, 31);
      expect(ExportService.buildFileDate(date), '20251231');
    });

    test('resultado tem exatamente 8 caracteres', () {
      final samples = [
        DateTime(2020, 1, 1),
        DateTime(2030, 12, 31),
        DateTime(2026, 6, 15),
      ];
      for (final d in samples) {
        expect(ExportService.buildFileDate(d).length, 8,
            reason: 'Falhou para $d');
      }
    });

    test('sem argumento usa data atual (resultado não lança exceção)', () {
      expect(() => ExportService.buildFileDate(), returnsNormally);
      final result = ExportService.buildFileDate();
      expect(result.length, 8);
      expect(int.tryParse(result), isNotNull);
    });

    test('resultado é parseável como número inteiro', () {
      final date = DateTime(2026, 4, 27);
      final result = ExportService.buildFileDate(date);
      expect(int.tryParse(result), 20260427);
    });
  });
}
