import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../services/session_service.dart';
import '../../services/client_service.dart';
import '../../services/package_service.dart';
import '../../services/auth_service.dart';
import '../../models/client.dart';
import '../../models/session.dart';
import '../../models/package.dart';
import '../../widgets/primary_button.dart';

class SessionEditScreen extends StatefulWidget {
  final String? sessionId;
  const SessionEditScreen({super.key, this.sessionId});

  @override
  State<SessionEditScreen> createState() => _SessionEditScreenState();
}

class _SessionEditScreenState extends State<SessionEditScreen> {
  final _type = TextEditingController(text: 'Massoterapia');
  final _value = TextEditingController(text: '150');
  final _notes = TextEditingController();
  String _status = 'confirmado';
  String _payment = 'pendente';
  DateTime _selectedDateTime = DateTime.now();
  String? _selectedClientId;
  List<Client> _clients = [];
  bool _loading = false;
  Session? _existingSession;
  
  // Pacotes
  bool _usePackage = false;
  Package? _activePackage;
  bool _canUsePackages = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      _clients = await ClientService.instance.getClients();
      
      // Verificar se pode usar pacotes
      final user = await AuthService.instance.getCurrentUserData();
      _canUsePackages = user?.canUsePackages() ?? false;
      
      if (widget.sessionId != null) {
        _existingSession = await SessionService.instance.getSessionById(widget.sessionId!);
        if (_existingSession != null) {
          _type.text = _existingSession!.therapyType;
          _value.text = _existingSession!.value.toString();
          _notes.text = _existingSession!.notes;
          _status = _existingSession!.status;
          _payment = _existingSession!.paymentStatus;
          _selectedDateTime = _existingSession!.dateTime;
          _selectedClientId = _existingSession!.clientId;
          _usePackage = _existingSession!.packageId != null;
          
          // Carregar pacote ativo do cliente
          if (_canUsePackages && _selectedClientId != null) {
            _activePackage = await PackageService.instance.getActivePackage(_selectedClientId!);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _type.dispose();
    _value.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _loadPackageForClient(String clientId) async {
    if (!_canUsePackages) return;
    
    setState(() => _activePackage = null);
    final pkg = await PackageService.instance.getActivePackage(clientId);
    if (mounted) {
      setState(() {
        _activePackage = pkg;
        _usePackage = pkg != null;
      });
    }
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _save() async {
    if (_selectedClientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um cliente')),
      );
      return;
    }

    if (_type.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o tipo de terapia')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final value = double.tryParse(_value.text.replaceAll(',', '.')) ?? 0;
      final packageId = _usePackage && _activePackage != null ? _activePackage!.id : null;

      if (widget.sessionId != null) {
        await SessionService.instance.updateSession(
          widget.sessionId!,
          dateTime: _selectedDateTime,
          therapyType: _type.text.trim(),
          status: _status,
          value: value,
          notes: _notes.text.trim(),
          paymentStatus: _payment,
          packageId: packageId,
        );
      } else {
        await SessionService.instance.createSession(
          clientId: _selectedClientId!,
          dateTime: _selectedDateTime,
          therapyType: _type.text.trim(),
          value: value,
          notes: _notes.text.trim(),
          status: _status,
          paymentStatus: _payment,
          packageId: packageId,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sessão salva!')),
        );
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Sessão'),
        content: const Text('Deseja realmente excluir esta sessão?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && widget.sessionId != null) {
      try {
        await SessionService.instance.deleteSession(widget.sessionId!);
        if (mounted) {
          context.go('/home');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.sessionId == null ? 'Nova sessão' : 'Editar sessão';
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    if (_loading && _clients.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: widget.sessionId != null
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _delete,
                ),
              ]
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedClientId,
              decoration: const InputDecoration(
                labelText: 'Cliente',
                border: OutlineInputBorder(),
              ),
              items: _clients
                  .map((c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name),
                      ))
                  .toList(),
              onChanged: (v) {
                setState(() => _selectedClientId = v);
                if (v != null) _loadPackageForClient(v);
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Data e Hora'),
              subtitle: Text(dateFormat.format(_selectedDateTime)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDateTime,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _type,
              decoration: const InputDecoration(
                labelText: 'Tipo de terapia',
                hintText: 'Ex: Massoterapia, Reiki, Acupuntura',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _value,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Valor (R\$)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'confirmado', child: Text('Confirmado')),
                DropdownMenuItem(value: 'faltou', child: Text('Faltou')),
                DropdownMenuItem(value: 'remarcado', child: Text('Remarcado')),
              ],
              onChanged: (v) => setState(() => _status = v ?? 'confirmado'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _payment,
              decoration: const InputDecoration(
                labelText: 'Pagamento',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'pendente', child: Text('Pendente')),
                DropdownMenuItem(value: 'pago', child: Text('Pago')),
              ],
              onChanged: (v) => setState(() => _payment = v ?? 'pendente'),
            ),
            
            // Card de Pacote Ativo
            if (_canUsePackages && _activePackage != null) ...[
              const SizedBox(height: 16),
              Card(
                color: _usePackage ? Colors.green[50] : Colors.grey[100],
                child: SwitchListTile(
                  title: Row(
                    children: [
                      const Icon(Icons.inventory_2, size: 20),
                      const SizedBox(width: 8),
                      const Text('Usar pacote ativo'),
                    ],
                  ),
                  subtitle: Text(
                    '${_activePackage!.remainingSessions}/${_activePackage!.totalSessions} sessões restantes',
                    style: TextStyle(
                      color: _activePackage!.isLow ? Colors.orange : Colors.green,
                    ),
                  ),
                  value: _usePackage,
                  onChanged: (v) => setState(() => _usePackage = v),
                  activeColor: Colors.green,
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            TextField(
              controller: _notes,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Anotações',
                hintText: 'Observações sobre a sessão',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              onPressed: _loading ? null : _save,
              label: _loading ? 'Salvando...' : 'Salvar',
            ),
          ],
        ),
      ),
    );
  }
}
