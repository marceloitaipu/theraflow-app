import 'package:flutter/material.dart';

/// Widget para exibir mensagens de erro global
class ErrorHandler {
  /// Mostra um SnackBar de erro
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  /// Mostra um SnackBar de sucesso
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Mostra um SnackBar de aviso
  static void showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.black87),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.black87),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.amber[400],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Mostra um SnackBar de informação
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue[700],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Mostra um diálogo de erro com detalhes
  static void showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? details,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.error_outline, color: Colors.red, size: 48),
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (details != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Detalhes:',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 4),
              Text(
                details,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
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

  /// Converte exceções em mensagens amigáveis
  static String friendlyMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Firebase Auth errors
    if (errorString.contains('user-not-found')) {
      return 'Usuário não encontrado';
    }
    if (errorString.contains('wrong-password') || 
        errorString.contains('invalid-credential')) {
      return 'Senha incorreta';
    }
    if (errorString.contains('email-already-in-use')) {
      return 'E-mail já cadastrado';
    }
    if (errorString.contains('invalid-email')) {
      return 'E-mail inválido';
    }
    if (errorString.contains('weak-password')) {
      return 'Senha muito fraca';
    }
    if (errorString.contains('too-many-requests')) {
      return 'Muitas tentativas. Aguarde um momento';
    }
    if (errorString.contains('network')) {
      return 'Erro de conexão. Verifique sua internet';
    }

    // Firestore errors
    if (errorString.contains('permission-denied')) {
      return 'Sem permissão para esta operação';
    }
    if (errorString.contains('unavailable')) {
      return 'Serviço temporariamente indisponível';
    }

    // Erros customizados
    if (errorString.contains('exception:')) {
      return error.toString().replaceAll('Exception: ', '');
    }

    // Erro genérico
    return 'Ocorreu um erro inesperado';
  }
}

/// Widget para exibir estado de loading
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      if (message != null) ...[
                        const SizedBox(height: 16),
                        Text(message!),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
