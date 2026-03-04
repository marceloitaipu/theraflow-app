import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/app_module.dart';
import '../services/business_service.dart';

/// Widget que controla acesso a módulos.
///
/// Se o módulo estiver habilitado no business, exibe [child].
/// Caso contrário, exibe tela de módulo bloqueado com opção
/// de navegar para a PaywallScreen.
class ModuleGate extends StatelessWidget {
  final AppModule module;
  final Widget child;
  final Widget? lockedWidget;

  const ModuleGate({
    super.key,
    required this.module,
    required this.child,
    this.lockedWidget,
  });

  @override
  Widget build(BuildContext context) {
    final business = BusinessService.instance.currentBusiness;
    final isEnabled = business?.isModuleEnabled(module) ?? false;

    if (isEnabled) {
      return child;
    }

    return lockedWidget ?? _DefaultLockedScreen(module: module);
  }
}

/// Tela padrão quando módulo está bloqueado.
class _DefaultLockedScreen extends StatelessWidget {
  final AppModule module;

  const _DefaultLockedScreen({required this.module});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_outline, size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              'Módulo Bloqueado',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '${module.icon} ${module.displayName}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              module.description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => context.push('/paywall'),
              icon: const Icon(Icons.star_outline),
              label: const Text('Ver Planos'),
            ),
            const SizedBox(height: 8),
            Text(
              'Faça upgrade para desbloquear este módulo',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Inline gate — esconde conteúdo e mostra um chip de "upgrade" quando bloqueado.
/// Útil para itens dentro de listas.
class ModuleGateInline extends StatelessWidget {
  final AppModule module;
  final Widget child;

  const ModuleGateInline({
    super.key,
    required this.module,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final business = BusinessService.instance.currentBusiness;
    final isEnabled = business?.isModuleEnabled(module) ?? false;

    if (isEnabled) return child;

    return Opacity(
      opacity: 0.5,
      child: GestureDetector(
        onTap: () => context.push('/paywall'),
        child: Stack(
          children: [
            child,
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock,
                        size: 12,
                        color: Theme.of(context).colorScheme.onPrimaryContainer),
                    const SizedBox(width: 4),
                    Text('PRO',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
