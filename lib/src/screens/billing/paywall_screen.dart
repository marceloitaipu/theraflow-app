import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Tela de Paywall - Comparação de Planos
class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escolha seu Plano'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.workspace_premium,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Desbloqueie todo o potencial',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gerencie seu consultório com mais eficiência',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Plano Free
                  _PlanCard(
                    name: 'Gratuito',
                    price: 'R\$ 0',
                    period: '/mês',
                    features: const [
                      PlanFeature('Até 5 clientes', true),
                      PlanFeature('Agenda básica', true),
                      PlanFeature('Histórico de sessões', true),
                      PlanFeature('Pacotes de sessões', false),
                      PlanFeature('Relatórios avançados', false),
                      PlanFeature('Alertas inteligentes', false),
                      PlanFeature('Exportar dados', false),
                    ],
                    isCurrentPlan: true,
                    onSelect: null,
                  ),

                  const SizedBox(height: 16),

                  // Plano Pro
                  _PlanCard(
                    name: 'Profissional',
                    price: 'R\$ 49,90',
                    period: '/mês',
                    isRecommended: true,
                    features: const [
                      PlanFeature('Até 50 clientes', true),
                      PlanFeature('Agenda completa', true),
                      PlanFeature('Histórico ilimitado', true),
                      PlanFeature('Pacotes de sessões', true),
                      PlanFeature('Relatórios financeiros', true),
                      PlanFeature('Alertas inteligentes', true),
                      PlanFeature('Exportar CSV', true),
                    ],
                    onSelect: () => _showComingSoon(context, 'Profissional'),
                  ),

                  const SizedBox(height: 16),

                  // Plano Premium
                  _PlanCard(
                    name: 'Premium',
                    price: 'R\$ 99,90',
                    period: '/mês',
                    features: const [
                      PlanFeature('Clientes ilimitados', true),
                      PlanFeature('Tudo do Profissional', true),
                      PlanFeature('Múltiplos profissionais', true),
                      PlanFeature('Relatórios PDF', true),
                      PlanFeature('Backup na nuvem', true),
                      PlanFeature('Suporte prioritário', true),
                      PlanFeature('Personalização', true),
                    ],
                    onSelect: () => _showComingSoon(context, 'Premium'),
                  ),

                  const SizedBox(height: 24),

                  // Benefícios
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.security, color: Colors.blue, size: 32),
                        const SizedBox(height: 12),
                        const Text(
                          'Garantia de 7 dias',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Não ficou satisfeito? Devolvemos seu dinheiro sem perguntas.',
                          style: TextStyle(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // FAQ rápido
                  ExpansionTile(
                    title: const Text('Por que assinar?'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Com o plano Pro você pode:\n\n'
                          '• Criar pacotes de sessões para fidelizar clientes\n'
                          '• Ver relatórios detalhados do seu faturamento\n'
                          '• Receber alertas sobre clientes inativos\n'
                          '• Exportar seus dados a qualquer momento\n'
                          '• Gerenciar até 50 clientes simultaneamente',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),

                  ExpansionTile(
                    title: const Text('Posso cancelar quando quiser?'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Sim! Você pode cancelar sua assinatura a qualquer momento. '
                          'Seu acesso continua até o fim do período pago.',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String planName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Em breve! 🚀'),
        content: Text(
          'A assinatura do plano $planName estará disponível em breve.\n\n'
          'Deixe seu e-mail para ser notificado quando lançarmos!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class PlanFeature {
  final String text;
  final bool included;

  const PlanFeature(this.text, this.included);
}

class _PlanCard extends StatelessWidget {
  final String name;
  final String price;
  final String period;
  final List<PlanFeature> features;
  final bool isRecommended;
  final bool isCurrentPlan;
  final VoidCallback? onSelect;

  const _PlanCard({
    required this.name,
    required this.price,
    required this.period,
    required this.features,
    this.isRecommended = false,
    this.isCurrentPlan = false,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRecommended
              ? Theme.of(context).primaryColor
              : Colors.grey[300]!,
          width: isRecommended ? 2 : 1,
        ),
        boxShadow: isRecommended
            ? [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          if (isRecommended)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: const Text(
                '⭐ MAIS POPULAR',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        period,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32),
                ...features.map((f) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Icon(
                            f.included ? Icons.check_circle : Icons.cancel,
                            color: f.included ? Colors.green : Colors.grey[400],
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              f.text,
                              style: TextStyle(
                                color: f.included ? Colors.black87 : Colors.grey,
                                decoration: f.included
                                    ? null
                                    : TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 16),
                if (isCurrentPlan)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Plano Atual',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  )
                else if (onSelect != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onSelect,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isRecommended
                            ? Theme.of(context).primaryColor
                            : Colors.grey[800],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Assinar $name',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
