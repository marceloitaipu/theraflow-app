/// Metadados específicos de cada módulo para agendamentos.
///
/// Cada módulo tem campos próprios armazenados no campo `metadata`
/// do documento de appointment no Firestore.

// ========== THERAPY ==========

class TherapyMetadata {
  final String sessionNotes;
  final String goals;
  final String homework;

  TherapyMetadata({
    this.sessionNotes = '',
    this.goals = '',
    this.homework = '',
  });

  Map<String, dynamic> toMap() => {
        'sessionNotes': sessionNotes,
        'goals': goals,
        'homework': homework,
      };

  static TherapyMetadata fromMap(Map<String, dynamic> map) {
    return TherapyMetadata(
      sessionNotes: (map['sessionNotes'] ?? '') as String,
      goals: (map['goals'] ?? '') as String,
      homework: (map['homework'] ?? '') as String,
    );
  }

  TherapyMetadata copyWith({
    String? sessionNotes,
    String? goals,
    String? homework,
  }) {
    return TherapyMetadata(
      sessionNotes: sessionNotes ?? this.sessionNotes,
      goals: goals ?? this.goals,
      homework: homework ?? this.homework,
    );
  }
}

// ========== AESTHETICS ==========

class AestheticsMetadata {
  final String phototype;
  final String protocol;
  final List<String> productsUsed;
  final List<String> beforePhotos;
  final List<String> afterPhotos;
  final bool consentSigned;

  AestheticsMetadata({
    this.phototype = '',
    this.protocol = '',
    this.productsUsed = const [],
    this.beforePhotos = const [],
    this.afterPhotos = const [],
    this.consentSigned = false,
  });

  Map<String, dynamic> toMap() => {
        'phototype': phototype,
        'protocol': protocol,
        'productsUsed': productsUsed,
        'beforePhotos': beforePhotos,
        'afterPhotos': afterPhotos,
        'consentSigned': consentSigned,
      };

  static AestheticsMetadata fromMap(Map<String, dynamic> map) {
    return AestheticsMetadata(
      phototype: (map['phototype'] ?? '') as String,
      protocol: (map['protocol'] ?? '') as String,
      productsUsed: (map['productsUsed'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      beforePhotos: (map['beforePhotos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      afterPhotos: (map['afterPhotos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      consentSigned: (map['consentSigned'] ?? false) as bool,
    );
  }

  AestheticsMetadata copyWith({
    String? phototype,
    String? protocol,
    List<String>? productsUsed,
    List<String>? beforePhotos,
    List<String>? afterPhotos,
    bool? consentSigned,
  }) {
    return AestheticsMetadata(
      phototype: phototype ?? this.phototype,
      protocol: protocol ?? this.protocol,
      productsUsed: productsUsed ?? this.productsUsed,
      beforePhotos: beforePhotos ?? this.beforePhotos,
      afterPhotos: afterPhotos ?? this.afterPhotos,
      consentSigned: consentSigned ?? this.consentSigned,
    );
  }
}

// ========== PODIATRY ==========

class PodiatryRisk {
  final bool diabetes;
  final bool circulation;

  PodiatryRisk({
    this.diabetes = false,
    this.circulation = false,
  });

  Map<String, dynamic> toMap() => {
        'diabetes': diabetes,
        'circulation': circulation,
      };

  static PodiatryRisk fromMap(Map<String, dynamic> map) {
    return PodiatryRisk(
      diabetes: (map['diabetes'] ?? false) as bool,
      circulation: (map['circulation'] ?? false) as bool,
    );
  }
}

class PodiatryMetadata {
  final PodiatryRisk risk;
  final String footMap;
  final String procedure;
  final String aftercare;

  PodiatryMetadata({
    PodiatryRisk? risk,
    this.footMap = '',
    this.procedure = '',
    this.aftercare = '',
  }) : risk = risk ?? PodiatryRisk();

  Map<String, dynamic> toMap() => {
        'risk': risk.toMap(),
        'footMap': footMap,
        'procedure': procedure,
        'aftercare': aftercare,
      };

  static PodiatryMetadata fromMap(Map<String, dynamic> map) {
    return PodiatryMetadata(
      risk: map['risk'] != null
          ? PodiatryRisk.fromMap(map['risk'] as Map<String, dynamic>)
          : PodiatryRisk(),
      footMap: (map['footMap'] ?? '') as String,
      procedure: (map['procedure'] ?? '') as String,
      aftercare: (map['aftercare'] ?? '') as String,
    );
  }

  PodiatryMetadata copyWith({
    PodiatryRisk? risk,
    String? footMap,
    String? procedure,
    String? aftercare,
  }) {
    return PodiatryMetadata(
      risk: risk ?? this.risk,
      footMap: footMap ?? this.footMap,
      procedure: procedure ?? this.procedure,
      aftercare: aftercare ?? this.aftercare,
    );
  }
}

// ========== MASSAGE ==========

class MassageMetadata {
  final String technique;
  final List<String> areas;
  final String pressure; // leve, moderada, forte
  final int? painBefore; // 0-10
  final int? painAfter; // 0-10
  final String bodyMap;

  MassageMetadata({
    this.technique = '',
    this.areas = const [],
    this.pressure = 'moderada',
    this.painBefore,
    this.painAfter,
    this.bodyMap = '',
  });

  Map<String, dynamic> toMap() => {
        'technique': technique,
        'areas': areas,
        'pressure': pressure,
        'painBefore': painBefore,
        'painAfter': painAfter,
        'bodyMap': bodyMap,
      };

  static MassageMetadata fromMap(Map<String, dynamic> map) {
    return MassageMetadata(
      technique: (map['technique'] ?? '') as String,
      areas: (map['areas'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      pressure: (map['pressure'] ?? 'moderada') as String,
      painBefore: map['painBefore'] as int?,
      painAfter: map['painAfter'] as int?,
      bodyMap: (map['bodyMap'] ?? '') as String,
    );
  }

  MassageMetadata copyWith({
    String? technique,
    List<String>? areas,
    String? pressure,
    int? painBefore,
    int? painAfter,
    String? bodyMap,
  }) {
    return MassageMetadata(
      technique: technique ?? this.technique,
      areas: areas ?? this.areas,
      pressure: pressure ?? this.pressure,
      painBefore: painBefore ?? this.painBefore,
      painAfter: painAfter ?? this.painAfter,
      bodyMap: bodyMap ?? this.bodyMap,
    );
  }
}

/// Helper para converter metadata genérico
class AppointmentMetadataHelper {
  static Map<String, dynamic> metadataToMap(String module, dynamic metadata) {
    if (metadata == null) return {};
    switch (module) {
      case 'therapy':
        return (metadata as TherapyMetadata).toMap();
      case 'aesthetics':
        return (metadata as AestheticsMetadata).toMap();
      case 'podiatry':
        return (metadata as PodiatryMetadata).toMap();
      case 'massage':
        return (metadata as MassageMetadata).toMap();
      default:
        return {};
    }
  }

  static dynamic metadataFromMap(String module, Map<String, dynamic>? map) {
    if (map == null || map.isEmpty) return null;
    switch (module) {
      case 'therapy':
        return TherapyMetadata.fromMap(map);
      case 'aesthetics':
        return AestheticsMetadata.fromMap(map);
      case 'podiatry':
        return PodiatryMetadata.fromMap(map);
      case 'massage':
        return MassageMetadata.fromMap(map);
      default:
        return null;
    }
  }
}
