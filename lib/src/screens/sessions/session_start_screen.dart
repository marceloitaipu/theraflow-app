import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../services/app_services.dart';
import '../../widgets/primary_button.dart';

/// Tela de iniciar/finalizar sessão - fluxo de trabalho real
class SessionStartScreen extends StatefulWidget {
  final String sessionId;

  const SessionStartScreen({super.key, required this.sessionId});

  @override
  State<SessionStartScreen> createState() => _SessionStartScreenState();
}

class _SessionStartScreenState extends State<SessionStartScreen> {
  final _notesController = TextEditingController();
  final _howArrivedController = TextEditingController();
  final _whatWasDoneController = TextEditingController();
  final _guidelinesController = TextEditingController();
  final _nextStepsController = TextEditingController();

  Session? _session;
  Client? _client;
  Session? _lastSession;
  bool _loading = true;
  String _status = 'realizada';
  String _paymentStatus = 'pendente';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _howArrivedController.dispose();
    _whatWasDoneController.dispose();
    _guidelinesController.dispose();
    _nextStepsController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      // Carregar sessão atual
      _session = await SessionService.instance.getSessionById(widget.sessionId);
      
      if (_session != null) {
        // Carregar cliente
        _client = await ClientService.instance.getClientById(_session!.clientId);
        
        // Carregar última sessão do cliente (para ver anotações anteriores)
        _lastSession = await SessionService.instance.getLastSessionByClient(
          _session!.clientId,
          excludeSessionId: widget.sessionId,
        );
        
        // Preencher valores da sessão atual
        _notesController.text = _session!.notes;
        _howArrivedController.text = _session!.howClientArrived ?? '';
        _whatWasDoneController.text = _session!.whatWasDone ?? '';
        _guidelinesController.text = _session!.guidelines ?? '';
        _nextStepsController.text = _session!.nextSteps ?? '';
        _status = _session!.status;
        _paymentStatus = _session!.paymentStatus;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar sessão: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _finishSession() async {
    if (_session == null) return;

    setState(() => _loading = true);
    try {
      // Atualizar sessão com status, pagamento, notas e campos clínicos
      await SessionService.instance.updateSession(
        _session!.id,
        status: _status,
        paymentStatus: _paymentStatus,
        notes: _notesController.text.trim(),
        howClientArrived: _howArrivedController.text.trim().isEmpty
            ? null
            : _howArrivedController.text.trim(),
        whatWasDone: _whatWasDoneController.text.trim().isEmpty
            ? null
            : _whatWasDoneController.text.trim(),
        guidelines: _guidelinesController.text.trim().isEmpty
            ? null
            : _guidelinesController.text.trim(),
        nextSteps: _nextStepsController.text.trim().isEmpty
            ? null
            : _nextStepsController.text.trim(),
        isDraft: false,
      );

      // Se houver pacote vinculado, decrementar
      if (_session!.packageId != null && _session!.packageId!.isNotEmpty) {
        final result = await PackageService.instance.decrementPackage(_session!.packageId!);
        
        if (mounted && result != null) {
          if (result.remainingSessions == 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🎉 Pacote finalizado! Considere criar um novo.'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          } else if (result.remainingSessions <= 2) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('⚠️ Atenção: Restam apenas ${result.remainingSessions} sessões no pacote.'),
                backgroundColor: Colors.amber,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Sessão finalizada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao finalizar: $e')),
        );
        setState(() => _loading = false);
      }
    }
  }

  void _copyFromLastSession() {
    if (_lastSession == null) return;
    setState(() {
      // Prioriza campos clínicos; se ausentes, copia notas genéricas como referência
      _howArrivedController.text = _lastSession!.howClientArrived ?? '';
      _whatWasDoneController.text =
          _lastSession!.whatWasDone ?? _lastSession!.notes;
      _guidelinesController.text = _lastSession!.guidelines ?? '';
      _nextStepsController.text = _lastSession!.nextSteps ?? '';
    });
  }

  Future<void> _saveDraft() async {
    if (_session == null) return;
    setState(() => _loading = true);
    try {
      await SessionService.instance.updateSession(
        _session!.id,
        notes: _notesController.text.trim(),
        howClientArrived: _howArrivedController.text.trim().isEmpty
            ? null
            : _howArrivedController.text.trim(),
        whatWasDone: _whatWasDoneController.text.trim().isEmpty
            ? null
            : _whatWasDoneController.text.trim(),
        guidelines: _guidelinesController.text.trim().isEmpty
            ? null
            : _guidelinesController.text.trim(),
        nextSteps: _nextStepsController.text.trim().isEmpty
            ? null
            : _nextStepsController.text.trim(),
        isDraft: true,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rascunho salvo.'),
            backgroundColor: Colors.blueGrey,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar rascunho: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Iniciar Sessão')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_session == null || _client == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erro')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Sessão não encontrada'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Voltar'),
              ),
            ],
          ),
        ),
      );
    }

    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sessão'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header do Cliente
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white24,
                        child: Text(
                          _client!.name.isNotEmpty ? _client!.name[0].toUpperCase() : '?',
                          style: const TextStyle(fontSize: 28, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _client!.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.phone, size: 16, color: Colors.white70),
                                const SizedBox(width: 4),
                                Text(
                                  _client!.phone.isNotEmpty ? _client!.phone : 'Sem telefone',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          '${_session!.therapyType} • ${dateFormat.format(_session!.dateTime)}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // Última anotação
            _buildLastNoteCard(),

            const SizedBox(height: 24),

            // Copiar da sessão anterior
            if (_lastSession != null)
              OutlinedButton.icon(
                onPressed: _copyFromLastSession,
                icon: const Icon(Icons.copy_all_outlined, size: 18),
                label: const Text('Copiar da sessão anterior'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                ),
              ),

            const SizedBox(height: 24),

            // ── Template clínico ──────────────────────────────────────────
            _buildClinicalField(
              label: 'Como o cliente chegou?',
              hint: 'Estado emocional, físico, o que trouxe hoje...',
              controller: _howArrivedController,
            ),
            const SizedBox(height: 16),
            _buildClinicalField(
              label: 'O que foi feito na sessão',
              hint: 'Técnicas, temas abordados, exercícios aplicados...',
              controller: _whatWasDoneController,
            ),
            const SizedBox(height: 16),
            _buildClinicalField(
              label: 'Orientações ao cliente',
              hint: 'Tarefas, recomendações, práticas entre sessões...',
              controller: _guidelinesController,
            ),
            const SizedBox(height: 16),
            _buildClinicalField(
              label: 'Próximos passos',
              hint: 'O que será trabalhado nas próximas sessões...',
              controller: _nextStepsController,
            ),

            const SizedBox(height: 24),

            // Notas livres desta sessão
            const Text(
              'Notas livres (opcional)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Registre observações sobre esta sessão...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),

            const SizedBox(height: 24),

            // Status da sessão
            const Text(
              'Status da sessão',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildStatusOption('realizada', '✅ Realizada', Colors.green),
                  Divider(height: 1, color: Colors.grey[300]),
                  _buildStatusOption('confirmado', '📅 Confirmada', Colors.blue),
                  Divider(height: 1, color: Colors.grey[300]),
                  _buildStatusOption('faltou', '❌ Faltou', Colors.red),
                  Divider(height: 1, color: Colors.grey[300]),
                  _buildStatusOption('remarcado', '🔄 Remarcado', Colors.orange),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Status do pagamento
            const Text(
              'Pagamento',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildPaymentOption('pago', '💰 Pago', Colors.green),
                  Divider(height: 1, color: Colors.grey[300]),
                  _buildPaymentOption('pendente', '⏳ Pendente', Colors.orange),
                ],
              ),
            ),

            // Valor da sessão
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Valor da sessão:', style: TextStyle(fontWeight: FontWeight.w500)),
                  Text(
                    'R\$ ${_session!.value.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Salvar rascunho
            OutlinedButton.icon(
              onPressed: _loading ? null : _saveDraft,
              icon: const Icon(Icons.save_outlined, size: 18),
              label: const Text('Salvar rascunho'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 12),

            // Botão Finalizar
            PrimaryButton(
              label: _loading ? 'Finalizando...' : 'Finalizar Sessão',
              onPressed: _loading ? null : _finishSession,
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildClinicalField({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }

  Widget _buildLastNoteCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _lastSession != null ? Colors.amber[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _lastSession != null ? Colors.amber[200]! : Colors.grey[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _lastSession != null ? Icons.history : Icons.info_outline,
                size: 20,
                color: _lastSession != null ? Colors.amber[700] : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                _lastSession != null ? 'Última anotação' : 'Primeira sessão',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _lastSession != null
                      ? Colors.amber[700]
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_lastSession != null && _lastSession!.notes.isNotEmpty) ...[
            Text(
              _lastSession!.notes,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              'Em ${DateFormat('dd/MM/yyyy').format(_lastSession!.dateTime)}',
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ] else
            Text(
              _lastSession == null
                  ? 'Esta é a primeira sessão deste cliente.'
                  : 'Nenhuma anotação na sessão anterior.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusOption(String value, String label, Color color) {
    final isSelected = _status == value;
    return InkWell(
      onTap: () => setState(() => _status = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: isSelected ? color.withValues(alpha: 0.1) : null,
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? color : Colors.grey,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? color : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String value, String label, Color color) {
    final isSelected = _paymentStatus == value;
    return InkWell(
      onTap: () => setState(() => _paymentStatus = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: isSelected ? color.withValues(alpha: 0.1) : null,
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? color : Colors.grey,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? color : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
