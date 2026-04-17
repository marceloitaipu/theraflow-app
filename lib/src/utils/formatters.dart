// Formatadores de texto
import 'package:intl/intl.dart';

class Formatters {
  /// Formata valor monetário em reais
  static String currency(double value) {
    return NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    ).format(value);
  }

  /// Formata data em formato brasileiro
  static String date(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'pt_BR').format(date);
  }

  /// Formata data e hora em formato brasileiro
  static String dateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm', 'pt_BR').format(date);
  }

  /// Formata apenas hora
  static String time(DateTime date) {
    return DateFormat('HH:mm', 'pt_BR').format(date);
  }

  /// Formata dia da semana
  static String weekday(DateTime date) {
    return DateFormat('EEEE', 'pt_BR').format(date);
  }

  /// Formata dia da semana curto
  static String weekdayShort(DateTime date) {
    return DateFormat('EEE', 'pt_BR').format(date);
  }

  /// Formata telefone brasileiro
  static String phone(String phone) {
    final digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.length == 11) {
      return '(${digitsOnly.substring(0, 2)}) ${digitsOnly.substring(2, 7)}-${digitsOnly.substring(7)}';
    } else if (digitsOnly.length == 10) {
      return '(${digitsOnly.substring(0, 2)}) ${digitsOnly.substring(2, 6)}-${digitsOnly.substring(6)}';
    }
    
    return phone;
  }

  /// Formata duração em minutos para texto legível
  static String duration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    }
    
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    
    if (mins == 0) {
      return '${hours}h';
    }
    
    return '${hours}h ${mins}min';
  }

  /// Formata nome para capitalização correta
  static String capitalizeName(String name) {
    if (name.isEmpty) return name;
    
    return name.split(' ').map((word) {
      if (word.isEmpty) return word;
      
      // Não capitalizar preposições
      final prepositions = ['de', 'da', 'do', 'das', 'dos', 'e'];
      if (prepositions.contains(word.toLowerCase())) {
        return word.toLowerCase();
      }
      
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Formata CPF
  static String cpf(String cpf) {
    final digitsOnly = cpf.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.length == 11) {
      return '${digitsOnly.substring(0, 3)}.${digitsOnly.substring(3, 6)}.${digitsOnly.substring(6, 9)}-${digitsOnly.substring(9)}';
    }
    
    return cpf;
  }

  /// Remove caracteres não numéricos
  static String digitsOnly(String value) {
    return value.replaceAll(RegExp(r'[^\d]'), '');
  }
}
