import 'package:flutter/material.dart';
import '../../models/app_module.dart';
import '../../models/appointment_metadata.dart';
import 'therapy_metadata_editor.dart';
import 'aesthetics_metadata_editor.dart';
import 'podiatry_metadata_editor.dart';
import 'massage_metadata_editor.dart';

/// Seleciona e exibe o editor de metadata correto baseado no módulo.
class ModuleMetadataEditor extends StatelessWidget {
  final AppModule module;
  final Map<String, dynamic> metadata;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const ModuleMetadataEditor({
    super.key,
    required this.module,
    required this.metadata,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    switch (module) {
      case AppModule.therapy:
        final typed = TherapyMetadata.fromMap(metadata);
        return TherapyMetadataEditor(
          metadata: typed,
          onChanged: (v) => onChanged(v.toMap()),
        );
      case AppModule.aesthetics:
        final typed = AestheticsMetadata.fromMap(metadata);
        return AestheticsMetadataEditor(
          metadata: typed,
          onChanged: (v) => onChanged(v.toMap()),
        );
      case AppModule.podiatry:
        final typed = PodiatryMetadata.fromMap(metadata);
        return PodiatryMetadataEditor(
          metadata: typed,
          onChanged: (v) => onChanged(v.toMap()),
        );
      case AppModule.massage:
        final typed = MassageMetadata.fromMap(metadata);
        return MassageMetadataEditor(
          metadata: typed,
          onChanged: (v) => onChanged(v.toMap()),
        );
    }
  }
}
