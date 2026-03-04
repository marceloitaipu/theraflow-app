import 'package:flutter/material.dart';
import '../../models/appointment_metadata.dart';

/// Editor de notas de sessão terapêutica.
/// Campos: sessionNotes, goals, homework
class TherapyMetadataEditor extends StatelessWidget {
  final TherapyMetadata metadata;
  final ValueChanged<TherapyMetadata> onChanged;

  const TherapyMetadataEditor({
    super.key,
    required this.metadata,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dados da Sessão Terapêutica',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                )),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: metadata.goals,
          decoration: const InputDecoration(
            labelText: 'Metas / Objetivos',
            hintText: 'Ex: Reduzir ansiedade, melhorar sono...',
          ),
          maxLines: 2,
          onChanged: (v) => onChanged(metadata.copyWith(goals: v)),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: metadata.sessionNotes,
          decoration: const InputDecoration(
            labelText: 'Notas da Sessão',
            hintText: 'Observações sobre a sessão...',
          ),
          maxLines: 4,
          onChanged: (v) => onChanged(metadata.copyWith(sessionNotes: v)),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: metadata.homework,
          decoration: const InputDecoration(
            labelText: 'Tarefa / Homework',
            hintText: 'Atividades para o paciente entre sessões...',
          ),
          maxLines: 2,
          onChanged: (v) => onChanged(metadata.copyWith(homework: v)),
        ),
      ],
    );
  }
}
