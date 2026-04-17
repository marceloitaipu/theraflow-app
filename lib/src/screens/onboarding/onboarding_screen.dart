import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/app_module.dart';
import '../../services/profile_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/primary_button.dart';

/// Onboarding em 4 passos. Salva preferências do usuário no Firestore
/// e opcionalmente cria o primeiro cliente. Arquitetura single-tenant:
/// as preferências ficam em `users/{uid}` — não há entidade Business separada.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _totalSteps = 4;

  int _step = 0;
  bool _loading = true;

  // Step 1 — Dados pessoais
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _city = TextEditingController();

  // Step 2 — Nicho/Módulo principal
  AppModule? _selectedModule;

  // Step 3 — Preferências
  final _defaultDuration = TextEditingController(text: '60');
  final _defaultPrice = TextEditingController(text: '150');
  final _businessName = TextEditingController();

  // Step 4 — Primeiro cliente
  final _firstClientName = TextEditingController();
  final _firstClientPhone = TextEditingController();

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _loading = true);
    try {
      final userData = await AuthService.instance.getCurrentUserData();
      if (userData != null && mounted) {
        _name.text = userData.name;
      }
    } catch (_) {
      // Continuar com campos vazios
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _city.dispose();
    _defaultDuration.dispose();
    _defaultPrice.dispose();
    _businessName.dispose();
    _firstClientName.dispose();
    _firstClientPhone.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    try {
      final module = (_selectedModule ?? AppModule.therapy).name;
      final bName = _businessName.text.trim().isNotEmpty
          ? _businessName.text.trim()
          : '${_name.text.trim()} - Consultório';

      await ProfileService.instance.saveProfile(
        name: _name.text.trim(),
        phone: _phone.text.trim(),
        city: _city.text.trim(),
        defaultDurationMinutes:
            int.tryParse(_defaultDuration.text.trim()) ?? 60,
        defaultPrice: double.tryParse(
              _defaultPrice.text.trim().replaceAll(',', '.'),
            ) ??
            150,
        module: module,
        businessName: bName,
        firstClientName: _firstClientName.text.trim().isNotEmpty
            ? _firstClientName.text.trim()
            : null,
        firstClientPhone: _firstClientPhone.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bem-vindo ao TheraFlow!')),
        );
        context.go('/home');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao salvar: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _nextStep() {
    if (_step == 0 && _name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe seu nome')),
      );
      return;
    }
    if (_step == 1 && _selectedModule == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione sua área de atuação')),
      );
      return;
    }

    if (_step < _totalSteps - 1) {
      setState(() => _step++);
    } else {
      _finish();
    }
  }

  void _previousStep() {
    if (_step > 0) setState(() => _step--);
  }

  Widget _stepView() {
    switch (_step) {
      case 0:
        return _buildStep1PersonalData();
      case 1:
        return _buildStep2NicheSelection();
      case 2:
        return _buildStep3Preferences();
      default:
        return _buildStep4FirstClient();
    }
  }

  Widget _buildStep1PersonalData() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.person, size: 64, color: Colors.blue),
        const SizedBox(height: 24),
        const Text(
          'Bem-vindo ao TheraFlow!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Vamos configurar sua conta em $_totalSteps passos simples.',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 32),
        Text(
          'Passo 1/$_totalSteps — Seus dados',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _name,
          decoration: const InputDecoration(
            labelText: 'Nome completo *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _phone,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Telefone/WhatsApp',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone),
            hintText: '(00) 00000-0000',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _city,
          decoration: const InputDecoration(
            labelText: 'Cidade',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.location_city),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2NicheSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.category, size: 64, color: Colors.blue),
        const SizedBox(height: 24),
        Text(
          'Passo 2/$_totalSteps — Área de atuação',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        const Text(
          'Escolha sua especialidade principal.',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 24),
        ...AppModule.values.map(
          (module) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _NicheCard(
              module: module,
              selected: _selectedModule == module,
              onTap: () => setState(() => _selectedModule = module),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep3Preferences() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.settings, size: 64, color: Colors.blue),
        const SizedBox(height: 24),
        Text(
          'Passo 3/$_totalSteps — Preferências',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        const Text(
          'Configure valores padrão para seus atendimentos.',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _businessName,
          decoration: InputDecoration(
            labelText: 'Nome do consultório / clínica',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.business),
            hintText: '${_name.text.trim()} - Consultório',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _defaultDuration,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Duração padrão (minutos)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.timer),
            hintText: '60',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _defaultPrice,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Valor padrão (R\$)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.attach_money),
            hintText: '150',
          ),
        ),
      ],
    );
  }

  Widget _buildStep4FirstClient() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.person_add, size: 64, color: Colors.blue),
        const SizedBox(height: 24),
        Text(
          'Passo 4/$_totalSteps — Primeiro cliente',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        const Text(
          'Adicione seu primeiro cliente (opcional).',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _firstClientName,
          decoration: const InputDecoration(
            labelText: 'Nome do cliente',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _firstClientPhone,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Telefone',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone),
            hintText: '(00) 00000-0000',
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuração Inicial'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: List.generate(
                  _totalSteps,
                  (index) => Expanded(
                    child: Container(
                      margin: EdgeInsets.only(
                        right: index < _totalSteps - 1 ? 8 : 0,
                      ),
                      height: 4,
                      decoration: BoxDecoration(
                        color: index <= _step ? Colors.blue : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(child: _stepView()),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (_step > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _saving ? null : _previousStep,
                        child: const Text('Voltar'),
                      ),
                    ),
                  if (_step > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(
                      onPressed: _saving ? null : _nextStep,
                      label: _saving
                          ? 'Salvando...'
                          : (_step < _totalSteps - 1
                              ? 'Próximo'
                              : 'Finalizar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NicheCard extends StatelessWidget {
  final AppModule module;
  final bool selected;
  final VoidCallback onTap;

  const _NicheCard({
    required this.module,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? Theme.of(context).primaryColor : Colors.grey[300]!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: selected ? 2 : 1),
          color: selected ? color.withValues(alpha: 0.08) : Colors.white,
        ),
        child: Row(
          children: [
            Icon(module.icon, size: 36, color: selected ? color : Colors.grey),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    module.displayName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: selected ? color : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    module.description,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (selected) Icon(Icons.check_circle, color: color, size: 28),
          ],
        ),
      ),
    );
  }
}
