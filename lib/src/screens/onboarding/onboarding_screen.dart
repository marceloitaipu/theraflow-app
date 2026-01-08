import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/profile_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/primary_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;
  bool _loading = true;

  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _city = TextEditingController();

  final _defaultDuration = TextEditingController(text: '60');
  final _defaultPrice = TextEditingController(text: '150');

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
    } catch (e) {
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
    _firstClientName.dispose();
    _firstClientPhone.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    try {
      await ProfileService.instance.saveProfile(
        name: _name.text.trim(),
        phone: _phone.text.trim(),
        city: _city.text.trim(),
        defaultDurationMinutes: int.tryParse(_defaultDuration.text.trim()) ?? 60,
        defaultPrice: double.tryParse(_defaultPrice.text.trim().replaceAll(',', '.')) ?? 150,
        firstClientName: _firstClientName.text.trim().isNotEmpty ? _firstClientName.text.trim() : null,
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
    if (_step == 0) {
      if (_name.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Informe seu nome')),
        );
        return;
      }
    }
    
    if (_step < 2) {
      setState(() => _step++);
    } else {
      _finish();
    }
  }

  void _previousStep() {
    if (_step > 0) {
      setState(() => _step--);
    }
  }

  Widget _stepView() {
    switch (_step) {
      case 0:
        return _Step1();
      case 1:
        return _Step2();
      default:
        return _Step3();
    }
  }

  Widget _Step1() {
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
        const Text(
          'Vamos configurar sua conta em 3 passos simples.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 32),
        const Text(
          'Passo 1/3 — Seus dados',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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

  Widget _Step2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.settings, size: 64, color: Colors.blue),
        const SizedBox(height: 24),
        const Text(
          'Passo 2/3 — Preferências',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        const Text(
          'Configure valores padrão para suas sessões.',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 24),
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
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Você pode ajustar esses valores a qualquer momento.',
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _Step3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.person_add, size: 64, color: Colors.blue),
        const SizedBox(height: 24),
        const Text(
          'Passo 3/3 — Primeiro cliente',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.orange),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Você pode pular e cadastrar depois na tela Clientes.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
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
              // Progress indicator
              Row(
                children: List.generate(
                  3,
                  (index) => Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
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
              // Step content
              Expanded(
                child: SingleChildScrollView(
                  child: _stepView(),
                ),
              ),
              const SizedBox(height: 24),
              // Buttons
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
                          : (_step < 2 ? 'Próximo' : 'Finalizar'),
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
  void dispose() {
    _name.dispose(); _phone.dispose(); _city.dispose();
    _defaultDuration.dispose(); _defaultPrice.dispose();
    _firstClientName.dispose(); _firstClientPhone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _step == 2;

    return Scaffold(
      appBar: AppBar(title: const Text('Configurar TheraFlow')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _stepView(),
            const Spacer(),
            Row(
              children: [
                if (_step > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving ? null : () => setState(() => _step -= 1),
                      child: const Text('Voltar'),
                    ),
                  ),
                if (_step > 0) const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    onPressed: _saving
                        ? null
                        : () {
                            if (isLast) {
                              _finish();
                            } else {
                              setState(() => _step += 1);
                            }
                          },
                    label: _saving ? 'Salvando...' : (isLast ? 'Concluir' : 'Continuar'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
