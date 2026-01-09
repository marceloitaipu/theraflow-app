import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../services/app_services.dart';
import '../../widgets/primary_button.dart';

/// Tela de criação de pacote de sessões
class PackageCreateScreen extends StatefulWidget {
  final String clientId;

  const PackageCreateScreen({super.key, required this.clientId});

  @override
  State<PackageCreateScreen> createState() => _PackageCreateScreenState();
}

class _PackageCreateScreenState extends State<PackageCreateScreen> {
  final _totalSessionsController = TextEditingController(text: '10');
  final _priceController = TextEditingController(text: '1200');
  
  Client? _client;
  bool _loading = true;
  bool _saving = false;
  bool _hasExpiration = false;
  DateTime _expirationDate = DateTime.now().add(const Duration(days: 180));

  // Opções pré-definidas de pacotes
  final List<Map<String, dynamic>> _presets = [
    {'sessions': 4, 'price': 520, 'name': '4 sessões'},
    {'sessions': 8, 'price': 960, 'name': '8 sessões'},
    {'sessions': 10, 'price': 1100, 'name': '10 sessões'},
    {'sessions': 12, 'price': 1200, 'name': '12 sessões'},
  ];

  @override
  void initState() {
    super.initState();
    _loadClient();
  }

  @override
  void dispose() {
    _totalSessionsController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _loadClient() async {
    setState(() => _loading = true);
    try {
      _client = await ClientService.instance.getClientById(widget.clientId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar cliente: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyPreset(Map<String, dynamic> preset) {
    setState(() {
      _totalSessionsController.text = preset['sessions'].toString();
      _priceController.text = preset['price'].toString();
    });
  }

  Future<void> _selectExpirationDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _expirationDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (date != null) {
      setState(() => _expirationDate = date);
    }
  }

  Future<void> _checkPlanAndCreate() async {
    // Verificar plano do usuário
    final user = await AuthService.instance.getCurrentUserData();
    if (user != null && user.plan == 'free') {
      if (mounted) {
        _showUpgradeDialog();
      }
      return;
    }

    _createPackage();
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock, color: Colors.orange),
            SizedBox(width: 8),
            Text('Recurso Pro'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pacotes de sessões são um recurso exclusivo do plano Pro.'),
            SizedBox(height: 16),
            Text('Com o plano Pro você pode:'),
            SizedBox(height: 8),
            Text('• Criar pacotes ilimitados'),
            Text('• Relatórios avançados'),
            Text('• Alertas inteligentes'),
            Text('• Exportar dados'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Depois'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/paywall');
            },
            child: const Text('Ver Planos'),
          ),
        ],
      ),
    );
  }

  Future<void> _createPackage() async {
    final sessions = int.tryParse(_totalSessionsController.text) ?? 0;
    final price = double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0;

    if (sessions <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o número de sessões')),
      );
      return;
    }

    if (price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o valor do pacote')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await PackageService.instance.createPackage(
        clientId: widget.clientId,
        totalSessions: sessions,
        price: price,
        expirationDate: _hasExpiration ? _expirationDate : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📦 Pacote criado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar pacote: $e')),
        );
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Criar Pacote')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final sessions = int.tryParse(_totalSessionsController.text) ?? 0;
    final price = double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0;
    final pricePerSession = sessions > 0 ? price / sessions : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Pacote'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info do Cliente
            if (_client != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        _client!.name.isNotEmpty ? _client!.name[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _client!.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            'Novo pacote de sessões',
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Pacotes pré-definidos
            const Text(
              'Pacotes sugeridos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presets.map((preset) {
                final isSelected = 
                    _totalSessionsController.text == preset['sessions'].toString() &&
                    _priceController.text == preset['price'].toString();
                return ChoiceChip(
                  label: Text(preset['name']),
                  selected: isSelected,
                  onSelected: (_) => _applyPreset(preset),
                  selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Número de sessões
            const Text(
              'Número de sessões',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _totalSessionsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Ex: 10',
                prefixIcon: const Icon(Icons.format_list_numbered),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 16),

            // Valor total
            const Text(
              'Valor total do pacote (R\$)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'Ex: 1200',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 16),

            // Valor por sessão (calculado)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Valor por sessão:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'R\$ ${pricePerSession.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Data de expiração (opcional)
            SwitchListTile(
              title: const Text('Definir data de validade'),
              subtitle: const Text('O pacote expira após esta data'),
              value: _hasExpiration,
              onChanged: (value) => setState(() => _hasExpiration = value),
              contentPadding: EdgeInsets.zero,
            ),

            if (_hasExpiration) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectExpirationDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('dd/MM/yyyy').format(_expirationDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Spacer(),
                      Text(
                        'Alterar',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Resumo
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📦 Resumo do Pacote',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Divider(),
                  _buildSummaryRow('Sessões:', '$sessions'),
                  _buildSummaryRow('Valor total:', 'R\$ ${price.toStringAsFixed(2)}'),
                  _buildSummaryRow('Por sessão:', 'R\$ ${pricePerSession.toStringAsFixed(2)}'),
                  if (_hasExpiration)
                    _buildSummaryRow('Validade:', DateFormat('dd/MM/yyyy').format(_expirationDate)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Botão Criar
            PrimaryButton(
              label: _saving ? 'Salvando...' : 'Criar Pacote',
              onPressed: _saving ? null : _checkPlanAndCreate,
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
