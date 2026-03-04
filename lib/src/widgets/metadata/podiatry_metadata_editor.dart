import 'package:flutter/material.dart';
import '../../models/appointment_metadata.dart';

/// Editor de avaliação podológica.
/// Campos: risk (diabetes, circulation), footMap, procedure, aftercare
class PodiatryMetadataEditor extends StatelessWidget {
  final PodiatryMetadata metadata;
  final ValueChanged<PodiatryMetadata> onChanged;

  const PodiatryMetadataEditor({
    super.key,
    required this.metadata,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Avaliação Podológica',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                )),
        const SizedBox(height: 12),

        // Fatores de risco
        Text('Fatores de Risco',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                )),
        SwitchListTile(
          title: const Text('Diabetes'),
          dense: true,
          value: metadata.risk.diabetes,
          onChanged: (v) => onChanged(metadata.copyWith(
            risk: PodiatryRisk(
              diabetes: v,
              circulation: metadata.risk.circulation,
            ),
          )),
        ),
        SwitchListTile(
          title: const Text('Problemas Circulatórios'),
          dense: true,
          value: metadata.risk.circulation,
          onChanged: (v) => onChanged(metadata.copyWith(
            risk: PodiatryRisk(
              diabetes: metadata.risk.diabetes,
              circulation: v,
            ),
          )),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: metadata.footMap,
          decoration: const InputDecoration(
            labelText: 'Mapa Podal',
            hintText: 'Descrição das áreas afetadas...',
          ),
          maxLines: 3,
          onChanged: (v) => onChanged(metadata.copyWith(footMap: v)),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: metadata.procedure,
          decoration: const InputDecoration(
            labelText: 'Procedimento Realizado',
            hintText: 'Ex: Desbaste, exérese de calo...',
          ),
          maxLines: 3,
          onChanged: (v) => onChanged(metadata.copyWith(procedure: v)),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: metadata.aftercare,
          decoration: const InputDecoration(
            labelText: 'Cuidados Pós-Procedimento',
            hintText: 'Orientações para o paciente...',
          ),
          maxLines: 2,
          onChanged: (v) => onChanged(metadata.copyWith(aftercare: v)),
        ),
      ],
    );
  }
}
