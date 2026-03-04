import 'package:flutter/material.dart';
import '../services/subscription_service.dart';

/// Tela de Paywall - apresentação de planos e assinatura
class PaywallScreen extends StatefulWidget {
  final bool showCloseButton;
  
  const PaywallScreen({
    Key? key,
    this.showCloseButton = true,
  }) : super(key: key);

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  final SubscriptionService _subscription = SubscriptionService.instance;
  String _selectedPlan = 'professional';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escolha seu Plano'),
        automaticallyImplyLeading: widget.showCloseButton,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    const Icon(
                      Icons.workspace_premium,
                      size: 80,
                      color: Color(0xFF6C63FF),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Gerencie seus clientes sem limites',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Escolha o plano ideal para o seu consultório',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Plano Professional
                    _buildPlanCard(
                      planId: 'professional',
                      title: 'Professional',
                      price: 'R\$ 29,90/mês',
                      benefits: [
                        'Até 50 clientes',
                        'Agendamento ilimitado',
                        'Relatórios básicos',
                        'Exportação de dados',
                        'Backup automático na nuvem',
                        'Suporte por e-mail',
                      ],
                      isPopular: true,
                    ),
                    const SizedBox(height: 16),

                    // Plano Premium
                    _buildPlanCard(
                      planId: 'premium',
                      title: 'Premium',
                      price: 'R\$ 49,90/mês',
                      benefits: [
                        'Clientes ilimitados',
                        'Agendamento ilimitado',
                        'Relatórios avançados',
                        'Exportação de dados',
                        'Backup automático na nuvem',
                        'Suporte prioritário',
                        'Integrações futuras',
                      ],
                      isPopular: false,
                    ),
                    const SizedBox(height: 24),

                    // Comparação com plano gratuito
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Plano Gratuito (atual)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildBenefitItem('Até 5 clientes'),
                          _buildBenefitItem('Agendamento básico'),
                          _buildBenefitItem('Dados locais apenas'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Botão de ação
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSubscribe,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              _getPlanPrice(_selectedPlan),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Cancele quando quiser. Sem compromisso.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String planId,
    required String title,
    required String price,
    required List<String> benefits,
    required bool isPopular,
  }) {
    final isSelected = _selectedPlan == planId;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = planId),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xFF6C63FF) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? const Color(0xFF6C63FF).withOpacity(0.05) : Colors.white,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Radio<String>(
                        value: planId,
                        groupValue: _selectedPlan,
                        onChanged: (value) => setState(() => _selectedPlan = value!),
                        activeColor: const Color(0xFF6C63FF),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 56),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          price,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6C63FF),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...benefits.map((benefit) => _buildBenefitItem(benefit)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isPopular)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'MAIS POPULAR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            size: 20,
            color: Color(0xFF6C63FF),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  String _getPlanPrice(String planId) {
    switch (planId) {
      case 'professional':
        return 'Assinar por R\$ 29,90/mês';
      case 'premium':
        return 'Assinar por R\$ 49,90/mês';
      default:
        return 'Assinar';
    }
  }

  Future<void> _handleSubscribe() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Implementar fluxo de compra com in_app_purchase
      // 1. Obter produtos disponíveis
      // 2. Iniciar compra com a loja
      // 3. Validar compra com validatePurchase()
      // 4. Atualizar UI e fechar tela

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Integração com In-App Purchase será implementada'),
          backgroundColor: Colors.orange,
        ),
      );

      // Por enquanto, apenas mostrar mensagem
      await Future.delayed(const Duration(seconds: 2));

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
