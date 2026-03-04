import 'package:flutter/material.dart';

/// Módulos suportados pela plataforma SaaS
enum AppModule {
  therapy,
  aesthetics,
  podiatry,
  massage;

  String get displayName {
    switch (this) {
      case AppModule.therapy:
        return 'Terapia';
      case AppModule.aesthetics:
        return 'Estética';
      case AppModule.podiatry:
        return 'Podologia';
      case AppModule.massage:
        return 'Massagem';
    }
  }

  IconData get icon {
    switch (this) {
      case AppModule.therapy:
        return Icons.psychology;
      case AppModule.aesthetics:
        return Icons.face_retouching_natural;
      case AppModule.podiatry:
        return Icons.accessibility_new;
      case AppModule.massage:
        return Icons.spa;
    }
  }

  /// Emoji representativo do módulo
  String get emoji {
    switch (this) {
      case AppModule.therapy:
        return '🧠';
      case AppModule.aesthetics:
        return '✨';
      case AppModule.podiatry:
        return '🦶';
      case AppModule.massage:
        return '💆';
    }
  }

  String get description {
    switch (this) {
      case AppModule.therapy:
        return 'Gestão de sessões terapêuticas, metas e evolução';
      case AppModule.aesthetics:
        return 'Protocolos estéticos, fotos antes/depois e consentimento';
      case AppModule.podiatry:
        return 'Avaliação de risco, mapa podal e procedimentos';
      case AppModule.massage:
        return 'Técnicas, mapa corporal e escala de dor';
    }
  }

  static AppModule fromString(String value) {
    switch (value) {
      case 'therapy':
        return AppModule.therapy;
      case 'aesthetics':
        return AppModule.aesthetics;
      case 'podiatry':
        return AppModule.podiatry;
      case 'massage':
        return AppModule.massage;
      default:
        return AppModule.therapy;
    }
  }
}
