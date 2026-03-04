/// Validadores de formulário
class Validators {
  /// Valida e-mail
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-mail é obrigatório';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value.trim())) {
      return 'E-mail inválido';
    }
    
    return null;
  }

  /// Valida senha
  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }
    
    if (value.length < minLength) {
      return 'Senha deve ter pelo menos $minLength caracteres';
    }
    
    return null;
  }

  /// Valida nome
  static String? name(String? value, {int minLength = 2}) {
    if (value == null || value.trim().isEmpty) {
      return 'Nome é obrigatório';
    }
    
    if (value.trim().length < minLength) {
      return 'Nome deve ter pelo menos $minLength caracteres';
    }
    
    return null;
  }

  /// Valida telefone brasileiro
  static String? phone(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Telefone é obrigatório' : null;
    }
    
    // Remove caracteres não numéricos
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    
    // Valida formato brasileiro (10 ou 11 dígitos)
    if (digitsOnly.length < 10 || digitsOnly.length > 11) {
      return 'Telefone inválido';
    }
    
    return null;
  }

  /// Valida valor monetário
  static String? currency(String? value, {bool required = true, double? min}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Valor é obrigatório' : null;
    }
    
    final numValue = double.tryParse(value.trim().replaceAll(',', '.'));
    
    if (numValue == null) {
      return 'Valor inválido';
    }
    
    if (min != null && numValue < min) {
      return 'Valor deve ser maior que R\$ ${min.toStringAsFixed(2)}';
    }
    
    return null;
  }

  /// Valida número inteiro
  static String? integer(String? value, {bool required = true, int? min, int? max}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Campo obrigatório' : null;
    }
    
    final numValue = int.tryParse(value.trim());
    
    if (numValue == null) {
      return 'Número inválido';
    }
    
    if (min != null && numValue < min) {
      return 'Valor deve ser maior ou igual a $min';
    }
    
    if (max != null && numValue > max) {
      return 'Valor deve ser menor ou igual a $max';
    }
    
    return null;
  }

  /// Valida campo não vazio
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null 
        ? '$fieldName é obrigatório' 
        : 'Campo obrigatório';
    }
    return null;
  }

  /// Combina múltiplos validadores
  static String? Function(String?) combine(List<String? Function(String?)> validators) {
    return (value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}
