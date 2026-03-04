import 'package:flutter/material.dart';
import '../../models/appointment_metadata.dart';

/// Editor rápido de massoterapia.
/// Campos: technique, areas, pressure, painBefore, painAfter, bodyMap
class MassageMetadataEditor extends StatelessWidget {
  final MassageMetadata metadata;
  final ValueChanged<MassageMetadata> onChanged;

  const MassageMetadataEditor({
    super.key,
    required this.metadata,
    required this.onChanged,
  });

  static const _pressureOptions = ['leve', 'moderada', 'forte'];

  static const _areaOptions = [
    'Cabeça',
    'Pescoço',
    'Ombros',
    'Costas',
    'Lombar',
    'Braços',
    'Mãos',
    'Pernas',
    'Pés',
    'Abdômen',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dados da Massagem',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                )),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: metadata.technique,
          decoration: const InputDecoration(
            labelText: 'Técnica',
            hintText: 'Ex: Relaxante, Desportiva, Shiatsu...',
          ),
          onChanged: (v) => onChanged(metadata.copyWith(technique: v)),
        ),
        const SizedBox(height: 12),

        // Pressão
        Text('Pressão',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                )),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: _pressureOptions
              .map((p) => ButtonSegment(
                    value: p,
                    label: Text(p[0].toUpperCase() + p.substring(1)),
                  ))
              .toList(),
          selected: {metadata.pressure},
          onSelectionChanged: (val) =>
              onChanged(metadata.copyWith(pressure: val.first)),
        ),
        const SizedBox(height: 16),

        // Áreas
        Text('Áreas Trabalhadas',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                )),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: _areaOptions.map((area) {
            final selected = metadata.areas.contains(area.toLowerCase());
            return FilterChip(
              label: Text(area),
              selected: selected,
              onSelected: (val) {
                final newAreas = List<String>.from(metadata.areas);
                if (val) {
                  newAreas.add(area.toLowerCase());
                } else {
                  newAreas.remove(area.toLowerCase());
                }
                onChanged(metadata.copyWith(areas: newAreas));
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Escala de dor
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Dor Antes (0-10)'),
                  Slider(
                    value: (metadata.painBefore ?? 0).toDouble(),
                    min: 0,
                    max: 10,
                    divisions: 10,
                    label: '${metadata.painBefore ?? 0}',
                    onChanged: (v) =>
                        onChanged(metadata.copyWith(painBefore: v.toInt())),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Dor Depois (0-10)'),
                  Slider(
                    value: (metadata.painAfter ?? 0).toDouble(),
                    min: 0,
                    max: 10,
                    divisions: 10,
                    label: '${metadata.painAfter ?? 0}',
                    onChanged: (v) =>
                        onChanged(metadata.copyWith(painAfter: v.toInt())),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: metadata.bodyMap,
          decoration: const InputDecoration(
            labelText: 'Mapa Corporal (observações)',
            hintText: 'Pontos de tensão, nódulos, áreas sensíveis...',
          ),
          maxLines: 3,
          onChanged: (v) => onChanged(metadata.copyWith(bodyMap: v)),
        ),
      ],
    );
  }
}
