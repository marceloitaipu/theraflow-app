import 'package:flutter/material.dart';
import '../../models/appointment_metadata.dart';

/// Editor de dados de procedimento estético.
/// Campos: phototype, protocol, productsUsed, consentSigned
class AestheticsMetadataEditor extends StatelessWidget {
  final AestheticsMetadata metadata;
  final ValueChanged<AestheticsMetadata> onChanged;

  const AestheticsMetadataEditor({
    super.key,
    required this.metadata,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dados do Procedimento Estético',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                )),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: metadata.phototype.isEmpty ? null : metadata.phototype,
          decoration: const InputDecoration(labelText: 'Fototipo'),
          items: const [
            DropdownMenuItem(value: 'I', child: Text('I - Muito clara')),
            DropdownMenuItem(value: 'II', child: Text('II - Clara')),
            DropdownMenuItem(value: 'III', child: Text('III - Morena clara')),
            DropdownMenuItem(value: 'IV', child: Text('IV - Morena')),
            DropdownMenuItem(value: 'V', child: Text('V - Morena escura')),
            DropdownMenuItem(value: 'VI', child: Text('VI - Negra')),
          ],
          onChanged: (v) =>
              onChanged(metadata.copyWith(phototype: v ?? '')),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: metadata.protocol,
          decoration: const InputDecoration(
            labelText: 'Protocolo',
            hintText: 'Descreva o protocolo aplicado...',
          ),
          maxLines: 3,
          onChanged: (v) => onChanged(metadata.copyWith(protocol: v)),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: metadata.productsUsed.join(', '),
          decoration: const InputDecoration(
            labelText: 'Produtos Utilizados',
            hintText: 'Separe por vírgula: Ácido hialurônico, Vitamina C...',
          ),
          onChanged: (v) => onChanged(metadata.copyWith(
            productsUsed:
                v.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
          )),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          title: const Text('Consentimento Assinado'),
          subtitle: const Text('Paciente assinou o TCLE'),
          value: metadata.consentSigned,
          onChanged: (v) =>
              onChanged(metadata.copyWith(consentSigned: v)),
        ),
      ],
    );
  }
}
