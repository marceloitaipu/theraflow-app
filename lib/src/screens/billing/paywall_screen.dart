import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/user.dart' as app_user;
import '../../services/auth_service.dart';

/// Tela de Paywall — Planos Free / Professional / Premium.
///
/// O plano é lido do documento `users/{uid}` via [AuthService.getCurrentUserData].
/// A seleção de plano mostra um diálogo "em breve" enquanto a integração real
/// de billing não está validada (ver [BillingConfig]).
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
      body: FutureBuilder<app_user.User?>(
        future: AuthService.instance.getCurrentUserData(),
        builder: (context, snapshot) {
          final currentPlan = snapshot.data?.plan ?? 'free';
          return SingleChildScrollView(
            child: Column(
              children: [
                _Header(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _PlanCard(
                        name: 'Gratuito',
                        price: 'Grátis',
                        period: '',
                        icon: Icons.rocket_launch,
                        features: const [
                          _PlanFeature('Até 5 clientes', true),
                          _PlanFeature('Agenda básica', true),
                          _PlanFeature('Histórico de sessões', true),
                          _PlanFeature('Pacotes de sessões', false),
                          _PlanFeature('Relatórios avançados', false),
                        ],
                        isCurrentPlan: currentPlan == 'free',
                        onSelect: null,
                      ),
                      const SizedBox(height: 16),
                      _PlanCard(
                        name: 'Profissional',
                        price: 'R\$ 49,90',
                        period: '/mês',
                        icon: Icons.star,
                        isRecommended: true,
                        features: const [
                          _PlanFeature('Até 50 clientes', true),
                          _PlanFeature('Agenda completa', true),
                          _PlanFeature('Pacotes de sessões', true),
                          _PlanFeature('Relatórios financeiros', true),
                          _PlanFeature('Alertas inteligentes', true),
                        ],
                        isCurrentPlan: currentPlan == 'professional',
                        onSelect: currentPlan == 'professional'
                            ? null
                            : () => _showComingSoon(context, 'Profissional'),
                      ),
                      const SizedBox(height: 16),
                      _PlanCard(
                        name: 'Premium',
                        price: 'R\$ 99,90',
                        period: '/mês',
                        icon: Icons.workspace_premium,
                        features: const [
                          _PlanFeature('Clientes ilimitados', true),
                          _PlanFeature('Todos os recursos', true),
                          _PlanFeature('Relatórios PDF', true),
                          _PlanFeature('Backup na nuvem', true),
                          _PlanFeature('Suporte prioritário', true),
                        ],
                        isCurrentPlan: currentPlan == 'premium',
                        onSelect: currentPlan == 'premium'
                            ? null
                            : () => _showComingSoon(context, 'Premium'),
                      ),
                      const SizedBox(height: 24),
                      _GuaranteeBox(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showComingSoon(BuildContext context, String planName) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Em breve!'),
        content: Text(
          'A assinatura do plano $planName estará disponível em breve.',
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

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, primary.withValues(alpha: 0.8)],
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.workspace_premium, size: 64, color: Colors.white),
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
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _GuaranteeBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Não ficou satisfeito? Devolvemos seu dinheiro sem perguntas.',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PlanFeature {
  final String text;
  final bool included;
  const _PlanFeature(this.text, this.included);
}

class _PlanCard extends StatelessWidget {
  final String name;
  final String price;
  final String period;
  final IconData? icon;
  final List<_PlanFeature> features;
  final bool isRecommended;
  final bool isCurrentPlan;
  final VoidCallback? onSelect;

  const _PlanCard({
    required this.name,
    required this.price,
    required this.period,
    required this.features,
    this.icon,
    this.isRecommended = false,
    this.isCurrentPlan = false,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRecommended ? primary : Colors.grey[300]!,
          width: isRecommended ? 2 : 1,
        ),
        boxShadow: isRecommended
            ? [
                BoxShadow(
                  color: primary.withValues(alpha: 0.2),
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
                color: primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: const Text(
                'MAIS POPULAR',
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
                        color: primary,
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
                ...features.map(
                  (f) => Padding(
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
                  ),
                ),
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
                        backgroundColor:
                            isRecommended ? primary : Colors.grey[800],
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
