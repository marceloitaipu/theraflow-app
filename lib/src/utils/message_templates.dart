// ignore: depend_on_referenced_packages
import 'package:url_launcher/url_launcher.dart';


//
// Variáveis disponíveis:
//   {nome}   — nome do cliente
//   {data}   — data formatada (ex: 28/04)
//   {hora}   — horário (ex: 14:30)
//   {tipo}   — tipo de terapia/sessão

enum MessageTemplateType {
  confirmation,       // confirmação de sessão
  reminderTomorrow,   // lembrete: sessão amanhã
  friendlyCharge,     // cobrança amigável
  returnAfterAbsence, // retorno após falta/ausência
  packageRenewal,     // renovação de pacote
  rescheduling,       // reagendamento
}

class MessageTemplate {
  final MessageTemplateType type;
  final String label;
  final String icon;
  final String Function({
    required String name,
    String? date,
    String? time,
    String? therapyType,
  }) build;

  const MessageTemplate({
    required this.type,
    required this.label,
    required this.icon,
    required this.build,
  });
}

class MessageTemplates {
  MessageTemplates._();

  static final List<MessageTemplate> all = [
    MessageTemplate(
      type: MessageTemplateType.confirmation,
      label: 'Confirmação de sessão',
      icon: '✅',
      build: ({required name, date, time, therapyType}) {
        final when = _whenText(date, time);
        return 'Olá, $name! Passando para confirmar nossa sessão$when. Você consegue comparecer? 😊';
      },
    ),
    MessageTemplate(
      type: MessageTemplateType.reminderTomorrow,
      label: 'Lembrete de amanhã',
      icon: '📅',
      build: ({required name, date, time, therapyType}) {
        final timeStr = time != null ? ' às $time' : '';
        return 'Oi, $name! Lembrando que amanhã temos nossa sessão$timeStr. Até lá! 🙂';
      },
    ),
    MessageTemplate(
      type: MessageTemplateType.friendlyCharge,
      label: 'Cobrança amigável',
      icon: '💳',
      build: ({required name, date, time, therapyType}) {
        return 'Olá, $name! Tudo bem? Passando para avisar que temos um pagamento em aberto. Quando puder, vamos combinar a melhor forma? 😊';
      },
    ),
    MessageTemplate(
      type: MessageTemplateType.returnAfterAbsence,
      label: 'Retorno após ausência',
      icon: '👋',
      build: ({required name, date, time, therapyType}) {
        return 'Oi, $name! Há um tempinho que não nos falamos. Gostaria de retomar nossas sessões? Estou à disposição para combinarmos um horário! 🙂';
      },
    ),
    MessageTemplate(
      type: MessageTemplateType.packageRenewal,
      label: 'Renovação de pacote',
      icon: '🔄',
      build: ({required name, date, time, therapyType}) {
        return 'Olá, $name! Seu pacote de sessões está chegando ao fim. Gostaria de renovar para continuarmos o trabalho? Me avisa quando quiser conversar! 😊';
      },
    ),
    MessageTemplate(
      type: MessageTemplateType.rescheduling,
      label: 'Reagendamento',
      icon: '🔃',
      build: ({required name, date, time, therapyType}) {
        final when = _whenText(date, time);
        return 'Olá, $name! Preciso verificar com você sobre a sessão$when. Consegue reagendar? Quando for melhor para você? 😊';
      },
    ),
  ];

  static String _whenText(String? date, String? time) {
    if (date != null && time != null) return ' de $date às $time';
    if (date != null) return ' de $date';
    if (time != null) return ' às $time';
    return '';
  }
}

/// Sanitiza o número de telefone para uso no URL do WhatsApp.
/// Garante código de país 55 (Brasil) e remove caracteres não numéricos.
String sanitizePhoneForWhatsApp(String phone) {
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return '';
  return digits.startsWith('55') ? digits : '55$digits';
}

/// Retorna true se o número tem comprimento válido para o Brasil
/// (11 dígitos com DDD, sem código de país; ou 13 com +55).
bool isValidBrazilianPhone(String phone) {
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  final withoutCode =
      digits.startsWith('55') && digits.length > 11 ? digits.substring(2) : digits;
  return withoutCode.length >= 10 && withoutCode.length <= 11;
}

/// Abre o WhatsApp com mensagem pré-preenchida.
/// Retorna true se conseguiu abrir, false caso contrário.
Future<bool> openWhatsApp({required String phone, required String message}) async {
  final number = sanitizePhoneForWhatsApp(phone);
  if (number.isEmpty) return false;
  final encoded = Uri.encodeComponent(message);
  final uri = Uri.parse('https://wa.me/$number?text=$encoded');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
    return true;
  }
  return false;
}
