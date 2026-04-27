import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/session.dart';
import 'client_service.dart';
import 'session_service.dart';
import 'finance_service.dart';

/// Serviço de exportação de dados em CSV.
///
/// Suporta exportação para compartilhamento (mobile/desktop) e
/// download direto (web).
class ExportService {
  ExportService._();
  static final instance = ExportService._();

  static final _dateFmt = DateFormat('dd/MM/yyyy');
  static final _currencyFmt =
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  // ─── Exportar clientes ───────────────────────────────────────────────────

  Future<void> exportClients() async {
    final clients = await ClientService.instance.getClients();
    final rows = <String>[
      // Cabeçalho
      _csvRow([
        'Nome',
        'Telefone',
        'Status CRM',
        'Tags',
        'Objetivo',
        'Frequência ideal',
        'Próxima ação',
        'Cadastrado em',
        'Observações',
      ]),
      // Linhas
      ...clients.map((c) => _csvRow([
            c.name,
            c.phone,
            c.clientStatus,
            c.tags.join('; '),
            c.goal ?? '',
            c.idealFrequency ?? '',
            c.nextAction ?? '',
            _dateFmt.format(c.createdAt),
            c.notes,
          ])),
    ];

    await _share(
      content: rows.join('\n'),
      fileName: 'theraflow_clientes_${_fileDate()}.csv',
      subject: 'Clientes — TheraFlow',
    );
  }

  // ─── Exportar sessões ────────────────────────────────────────────────────

  /// Exporta sessões de um período. Se [start]/[end] forem nulos, exporta tudo.
  Future<void> exportSessions({DateTime? start, DateTime? end}) async {
    late List<Session> sessions;
    if (start != null && end != null) {
      sessions = await SessionService.instance
          .getSessionsByPeriod(start: start, end: end);
    } else {
      sessions = await SessionService.instance.getSessions();
    }

    // Carrega nomes de clientes para lookup
    final clients = await ClientService.instance.getClients();
    final nameById = {for (final c in clients) c.id: c.name};

    final rows = <String>[
      _csvRow([
        'Data',
        'Horário',
        'Cliente',
        'Tipo de terapia',
        'Status',
        'Pagamento',
        'Valor',
        'Observações',
      ]),
      ...sessions.where((s) => s.deletedAt == null).map((s) => _csvRow([
            _dateFmt.format(s.dateTime),
            DateFormat('HH:mm').format(s.dateTime),
            nameById[s.clientId] ?? s.clientId,
            s.therapyType,
            s.status,
            s.paymentStatus,
            _currencyFmt.format(s.value),
            s.notes,
          ])),
    ];

    final label = start != null
        ? '${_fileDate(start)}_${_fileDate(end!)}'
        : 'tudo';
    await _share(
      content: rows.join('\n'),
      fileName: 'theraflow_sessoes_$label.csv',
      subject: 'Sessões — TheraFlow',
    );
  }

  // ─── Exportar financeiro ─────────────────────────────────────────────────

  /// Exporta sessões como relatório financeiro (agrupadas por status de pagamento).
  Future<void> exportFinance({DateTime? start, DateTime? end}) async {
    late List<Session> sessions;
    if (start != null && end != null) {
      sessions = await SessionService.instance
          .getSessionsByPeriod(start: start, end: end);
    } else {
      sessions = await SessionService.instance.getSessions();
    }

    final clients = await ClientService.instance.getClients();
    final nameById = {for (final c in clients) c.id: c.name};

    final relevant = sessions.where((s) =>
        s.deletedAt == null &&
        s.status != 'cancelado' &&
        s.status != 'faltou');

    final rows = <String>[
      _csvRow([
        'Data',
        'Horário',
        'Cliente',
        'Tipo de terapia',
        'Valor',
        'Status pagamento',
      ]),
      ...relevant.map((s) => _csvRow([
            _dateFmt.format(s.dateTime),
            DateFormat('HH:mm').format(s.dateTime),
            nameById[s.clientId] ?? s.clientId,
            s.therapyType,
            _currencyFmt.format(s.value),
            s.paymentStatus,
          ])),
    ];

    final label = start != null
        ? '${_fileDate(start)}_${_fileDate(end!)}'
        : 'tudo';
    await _share(
      content: rows.join('\n'),
      fileName: 'theraflow_financeiro_$label.csv',
      subject: 'Financeiro — TheraFlow',
    );
  }

  // ─── Resumo mensal ───────────────────────────────────────────────────────

  Future<void> exportMonthlySummary({required int year, required int month}) async {
    final report = await FinanceService.instance
        .getMonthlyReport(year: year, month: month);
    final monthName = DateFormat('MMMM_yyyy', 'pt_BR')
        .format(DateTime(year, month))
        .replaceAll(' ', '_');

    final lines = [
      'Resumo mensal — ${DateFormat("MMMM 'de' yyyy", 'pt_BR').format(DateTime(year, month))}',
      '',
      'Total de sessões;${report.totalSessions}',
      'Sessões confirmadas;${report.sessionsConfirmed}',
      'Faltas;${report.sessionsMissed}',
      'Remarcadas;${report.sessionsRescheduled}',
      '',
      'Receita recebida;${_currencyFmt.format(report.totalReceived)}',
      'Receita pendente;${_currencyFmt.format(report.totalPending)}',
      'Total geral;${_currencyFmt.format(report.total)}',
    ];

    await _share(
      content: lines.join('\n'),
      fileName: 'theraflow_resumo_$monthName.csv',
      subject: 'Resumo mensal — TheraFlow',
    );
  }

  // ─── Helpers internos ────────────────────────────────────────────────────

  /// Formata uma linha CSV com escape correto.
  String _csvRow(List<String> cells) => ExportService.buildCsvRow(cells);

  String _fileDate([DateTime? dt]) => ExportService.buildFileDate(dt);

  /// Formata uma linha CSV escapando aspas e envolvendo cada célula em aspas.
  /// Exposto para testes.
  @visibleForTesting
  static String buildCsvRow(List<String> cells) {
    return cells.map((c) {
      final escaped = c.replaceAll('"', '""');
      return '"$escaped"';
    }).join(';');
  }

  /// Formata uma data como string para nome de arquivo (yyyyMMdd).
  /// Exposto para testes.
  @visibleForTesting
  static String buildFileDate([DateTime? dt]) {
    return DateFormat('yyyyMMdd').format(dt ?? DateTime.now());
  }

  /// Compartilha o conteúdo CSV como arquivo.
  Future<void> _share({
    required String content,
    required String fileName,
    required String subject,
  }) async {
    if (kIsWeb) {
      final bytes = Uint8List.fromList(content.codeUnits);
      final xFile = XFile.fromData(
        bytes,
        name: fileName,
        mimeType: 'text/csv',
      );
      await Share.shareXFiles([xFile], subject: subject);
    } else {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(content);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'text/csv')],
        subject: subject,
      );
    }
  }
}
