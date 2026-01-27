import 'field_config.dart';

/// Predefined formations for all field types
class FormationPresets {
  FormationPresets._();

  /// 11-a-side formations
  static final Map<String, FormationData> standard11ASide = {
    '4-2-3-1': FormationData(
      name: '4-2-3-1',
      positions: const [
        PlayerPosition(0.5, 0.94), // GK
        PlayerPosition(0.15, 0.78), // LB
        PlayerPosition(0.37, 0.80), // LCB
        PlayerPosition(0.63, 0.80), // RCB
        PlayerPosition(0.85, 0.78), // RB
        PlayerPosition(0.38, 0.62), // CDM
        PlayerPosition(0.62, 0.62), // CDM
        PlayerPosition(0.18, 0.42), // LW
        PlayerPosition(0.5, 0.44), // CAM
        PlayerPosition(0.82, 0.42), // RW
        PlayerPosition(0.5, 0.22), // ST
      ],
      description: 'Balanced setup with strong midfield control',
      tags: ['Balanced', 'Control'],
    ),
    '4-3-3': FormationData(
      name: '4-3-3',
      positions: const [
        PlayerPosition(0.5, 0.94), // GK
        PlayerPosition(0.15, 0.78), // LB
        PlayerPosition(0.37, 0.80), // LCB
        PlayerPosition(0.63, 0.80), // RCB
        PlayerPosition(0.85, 0.78), // RB
        PlayerPosition(0.25, 0.58), // LCM
        PlayerPosition(0.5, 0.62), // CM
        PlayerPosition(0.75, 0.58), // RCM
        PlayerPosition(0.18, 0.32), // LW
        PlayerPosition(0.5, 0.26), // ST
        PlayerPosition(0.82, 0.32), // RW
      ],
      description: 'Attacking formation with wide play focus',
      tags: ['Attack', 'Width'],
    ),
    '4-4-2': FormationData(
      name: '4-4-2',
      positions: const [
        PlayerPosition(0.5, 0.94), // GK
        PlayerPosition(0.15, 0.78), // LB
        PlayerPosition(0.37, 0.80), // LCB
        PlayerPosition(0.63, 0.80), // RCB
        PlayerPosition(0.85, 0.78), // RB
        PlayerPosition(0.15, 0.54), // LM
        PlayerPosition(0.40, 0.58), // LCM
        PlayerPosition(0.60, 0.58), // RCM
        PlayerPosition(0.85, 0.54), // RM
        PlayerPosition(0.38, 0.28), // ST
        PlayerPosition(0.62, 0.28), // ST
      ],
      description: 'Classic solid and reliable structure',
      tags: ['Classic', 'Solid'],
    ),
    '3-5-2': FormationData(
      name: '3-5-2',
      positions: const [
        PlayerPosition(0.5, 0.94), // GK
        PlayerPosition(0.25, 0.78), // LCB
        PlayerPosition(0.5, 0.78), // CB
        PlayerPosition(0.75, 0.78), // RCB
        PlayerPosition(0.10, 0.56), // LWB
        PlayerPosition(0.32, 0.58), // LCM
        PlayerPosition(0.5, 0.60), // CM
        PlayerPosition(0.68, 0.58), // RCM
        PlayerPosition(0.90, 0.56), // RWB
        PlayerPosition(0.38, 0.28), // ST
        PlayerPosition(0.62, 0.28), // ST
      ],
      description: 'Flexible wingback-heavy approach',
      tags: ['Flexible', 'Wingbacks'],
    ),
    '5-3-2': FormationData(
      name: '5-3-2',
      positions: const [
        PlayerPosition(0.5, 0.94), // GK
        PlayerPosition(0.10, 0.76), // LWB
        PlayerPosition(0.30, 0.80), // LCB
        PlayerPosition(0.5, 0.80), // CB
        PlayerPosition(0.70, 0.80), // RCB
        PlayerPosition(0.90, 0.76), // RWB
        PlayerPosition(0.25, 0.58), // LCM
        PlayerPosition(0.5, 0.62), // CM
        PlayerPosition(0.75, 0.58), // RCM
        PlayerPosition(0.38, 0.28), // ST
        PlayerPosition(0.62, 0.28), // ST
      ],
      description: 'Defensive counter-attacking style',
      tags: ['Defensive', 'Counter'],
    ),
    '3-4-3': FormationData(
      name: '3-4-3',
      positions: const [
        PlayerPosition(0.5, 0.94), // GK
        PlayerPosition(0.25, 0.78), // LCB
        PlayerPosition(0.5, 0.78), // CB
        PlayerPosition(0.75, 0.78), // RCB
        PlayerPosition(0.15, 0.56), // LM
        PlayerPosition(0.38, 0.58), // LCM
        PlayerPosition(0.62, 0.58), // RCM
        PlayerPosition(0.85, 0.56), // RM
        PlayerPosition(0.18, 0.32), // LW
        PlayerPosition(0.5, 0.26), // ST
        PlayerPosition(0.82, 0.32), // RW
      ],
      description: 'High-pressing attacking formation',
      tags: ['Pressing', 'Attack'],
    ),
    '4-1-4-1': FormationData(
      name: '4-1-4-1',
      positions: const [
        PlayerPosition(0.5, 0.94), // GK
        PlayerPosition(0.15, 0.78), // LB
        PlayerPosition(0.37, 0.80), // LCB
        PlayerPosition(0.63, 0.80), // RCB
        PlayerPosition(0.85, 0.78), // RB
        PlayerPosition(0.5, 0.64), // CDM
        PlayerPosition(0.18, 0.46), // LM
        PlayerPosition(0.40, 0.48), // LCM
        PlayerPosition(0.60, 0.48), // RCM
        PlayerPosition(0.82, 0.46), // RM
        PlayerPosition(0.5, 0.24), // ST
      ],
      description: 'Defensive with single pivot control',
      tags: ['Defensive', 'Pivot'],
    ),
  };

  /// 7-a-side formations
  static final Map<String, FormationData> sevenASide = {
    '2-3-1': FormationData(
      name: '2-3-1',
      positions: const [
        PlayerPosition(0.5, 0.92), // GK
        PlayerPosition(0.30, 0.75), // LCB
        PlayerPosition(0.70, 0.75), // RCB
        PlayerPosition(0.25, 0.52), // LM
        PlayerPosition(0.5, 0.55), // CM
        PlayerPosition(0.75, 0.52), // RM
        PlayerPosition(0.5, 0.25), // ST
      ],
      description: 'Balanced setup with strong midfield control',
      tags: ['Balanced', 'Control'],
    ),
    '3-2-1': FormationData(
      name: '3-2-1',
      positions: const [
        PlayerPosition(0.5, 0.92), // GK
        PlayerPosition(0.25, 0.72), // LCB
        PlayerPosition(0.5, 0.72), // CB
        PlayerPosition(0.75, 0.72), // RCB
        PlayerPosition(0.35, 0.50), // LCM
        PlayerPosition(0.65, 0.50), // RCM
        PlayerPosition(0.5, 0.22), // ST
      ],
      description: 'Strong defensive base with three defenders',
      tags: ['Defensive', 'Solid'],
    ),
    '2-2-2': FormationData(
      name: '2-2-2',
      positions: const [
        PlayerPosition(0.5, 0.92), // GK
        PlayerPosition(0.30, 0.73), // LB
        PlayerPosition(0.70, 0.73), // RB
        PlayerPosition(0.35, 0.52), // LCM
        PlayerPosition(0.65, 0.52), // RCM
        PlayerPosition(0.35, 0.28), // LST
        PlayerPosition(0.65, 0.28), // RST
      ],
      description: 'Balanced between defense and attack',
      tags: ['Balanced', 'Attack'],
    ),
    '3-1-2': FormationData(
      name: '3-1-2',
      positions: const [
        PlayerPosition(0.5, 0.92), // GK
        PlayerPosition(0.25, 0.72), // LCB
        PlayerPosition(0.5, 0.72), // CB
        PlayerPosition(0.75, 0.72), // RCB
        PlayerPosition(0.5, 0.52), // CDM
        PlayerPosition(0.35, 0.28), // LST
        PlayerPosition(0.65, 0.28), // RST
      ],
      description: 'Defensive with counter-attack strikers',
      tags: ['Defensive', 'Counter'],
    ),
    '2-1-3': FormationData(
      name: '2-1-3',
      positions: const [
        PlayerPosition(0.5, 0.92), // GK
        PlayerPosition(0.30, 0.75), // LCB
        PlayerPosition(0.70, 0.75), // RCB
        PlayerPosition(0.5, 0.55), // CDM
        PlayerPosition(0.20, 0.30), // LW
        PlayerPosition(0.5, 0.28), // ST
        PlayerPosition(0.80, 0.30), // RW
      ],
      description: 'Attacking with three forwards',
      tags: ['Attack', 'Wings'],
    ),
    '1-3-2': FormationData(
      name: '1-3-2',
      positions: const [
        PlayerPosition(0.5, 0.92), // GK
        PlayerPosition(0.5, 0.72), // CB
        PlayerPosition(0.25, 0.52), // LM
        PlayerPosition(0.5, 0.55), // CM
        PlayerPosition(0.75, 0.52), // RM
        PlayerPosition(0.35, 0.25), // LST
        PlayerPosition(0.65, 0.25), // RST
      ],
      description: 'Risky with single defender',
      tags: ['Risky', 'Attack'],
    ),
    '1-4-1': FormationData(
      name: '1-4-1',
      positions: const [
        PlayerPosition(0.5, 0.92), // GK
        PlayerPosition(0.5, 0.72), // CB
        PlayerPosition(0.15, 0.50), // LM
        PlayerPosition(0.38, 0.52), // LCM
        PlayerPosition(0.62, 0.52), // RCM
        PlayerPosition(0.85, 0.50), // RM
        PlayerPosition(0.5, 0.22), // ST
      ],
      description: 'Full midfield control',
      tags: ['Control', 'Midfield'],
    ),
    '2-3-1 (Wide)': FormationData(
      name: '2-3-1 (Wide)',
      positions: const [
        PlayerPosition(0.5, 0.92), // GK
        PlayerPosition(0.30, 0.75), // LCB
        PlayerPosition(0.70, 0.75), // RCB
        PlayerPosition(0.15, 0.48), // LW
        PlayerPosition(0.5, 0.52), // CM
        PlayerPosition(0.85, 0.48), // RW
        PlayerPosition(0.5, 0.22), // ST
      ],
      description: 'Wide formation with wingers',
      tags: ['Wide', 'Wings'],
    ),
  };

  /// 5-a-side formations
  static final Map<String, FormationData> fiveASide = {
    '2-2': FormationData(
      name: '2-2',
      positions: const [
        PlayerPosition(0.5, 0.92), // GK
        PlayerPosition(0.30, 0.68), // LCB
        PlayerPosition(0.70, 0.68), // RCB
        PlayerPosition(0.35, 0.35), // LST
        PlayerPosition(0.65, 0.35), // RST
      ],
      description: 'Simple balanced formation',
      tags: ['Balanced', 'Simple'],
    ),
    '1-3': FormationData(
      name: '1-3',
      positions: const [
        PlayerPosition(0.5, 0.92), // GK
        PlayerPosition(0.5, 0.70), // CB
        PlayerPosition(0.25, 0.40), // LW
        PlayerPosition(0.5, 0.38), // ST
        PlayerPosition(0.75, 0.40), // RW
      ],
      description: 'Risky attacking formation with three forwards',
      tags: ['Attack', 'Risky'],
    ),
    '1-1-2': FormationData(
      name: '1-1-2',
      positions: const [
        PlayerPosition(0.5, 0.92), // GK
        PlayerPosition(0.5, 0.70), // CB
        PlayerPosition(0.5, 0.52), // CDM
        PlayerPosition(0.35, 0.28), // LST
        PlayerPosition(0.65, 0.28), // RST
      ],
      description: 'Attacking with pivot and two strikers',
      tags: ['Attack', 'Central'],
    ),
    '2-1-1': FormationData(
      name: '2-1-1',
      positions: const [
        PlayerPosition(0.5, 0.92), // GK
        PlayerPosition(0.30, 0.72), // LCB
        PlayerPosition(0.70, 0.72), // RCB
        PlayerPosition(0.5, 0.50), // CM
        PlayerPosition(0.5, 0.25), // ST
      ],
      description: 'Safe defensive setup with strong base',
      tags: ['Defensive', 'Safe'],
    ),
    '1-2-1 (Diamond)': FormationData(
      name: '1-2-1 (Diamond)',
      positions: const [
        PlayerPosition(0.5, 0.92), // GK
        PlayerPosition(0.5, 0.72), // CB
        PlayerPosition(0.30, 0.50), // LM
        PlayerPosition(0.70, 0.50), // RM
        PlayerPosition(0.5, 0.25), // ST
      ],
      description: 'Diamond for midfield control',
      tags: ['Diamond', 'Control'],
    ),
    '3-1': FormationData(
      name: '3-1',
      positions: const [
        PlayerPosition(0.5, 0.92), // GK
        PlayerPosition(0.25, 0.65), // LB
        PlayerPosition(0.5, 0.68), // CB
        PlayerPosition(0.75, 0.65), // RB
        PlayerPosition(0.5, 0.28), // ST
      ],
      description: 'Strong defensive counter-attacking',
      tags: ['Defensive', 'Counter'],
    ),
    '1-1-2 (Wide)': FormationData(
      name: '1-1-2 (Wide)',
      positions: const [
        PlayerPosition(0.5, 0.92), // GK
        PlayerPosition(0.5, 0.70), // CB
        PlayerPosition(0.5, 0.52), // CDM
        PlayerPosition(0.20, 0.28), // LW
        PlayerPosition(0.80, 0.28), // RW
      ],
      description: 'Wide formation with wingers',
      tags: ['Wide', 'Wings'],
    ),
  };

  /// Get field configuration for a specific field type
  static FieldConfig getConfig(FieldType fieldType) {
    switch (fieldType) {
      case FieldType.standard:
        return FieldConfig(
          fieldType: fieldType,
          formations: standard11ASide,
          fieldPainter: FieldPainterType.standard,
          centerCircleRadius: 0.12,
          penaltyBoxWidth: 0.5,
          penaltyBoxHeight: 0.18,
          sixYardBoxWidth: 0.3,
          sixYardBoxHeight: 0.1,
          penaltySpotDistance: 0.65,
        );
      case FieldType.sevenASide:
        return FieldConfig(
          fieldType: fieldType,
          formations: sevenASide,
          fieldPainter: FieldPainterType.sevenASide,
          centerCircleRadius: 0.10,
          penaltyBoxWidth: 0.55,
          penaltyBoxHeight: 0.16,
          penaltySpotDistance: 0.6,
        );
      case FieldType.fiveASide:
        return FieldConfig(
          fieldType: fieldType,
          formations: fiveASide,
          fieldPainter: FieldPainterType.fiveASide,
          centerCircleRadius: 0.08,
          penaltyBoxWidth: 0.50,
          penaltyBoxHeight: 0.14,
          penaltySpotDistance: 0.55,
        );
    }
  }
}
