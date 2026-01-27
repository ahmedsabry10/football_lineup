/// Field configuration for different game formats
enum FieldType {
  /// Standard 11-a-side football
  standard(11, 'Standard', '11-a-side'),
  
  /// 7-a-side football
  sevenASide(7, 'Seven-a-side', '7-a-side'),
  
  /// 5-a-side football (Futsal)
  fiveASide(5, 'Five-a-side', '5-a-side');

  const FieldType(this.playerCount, this.displayName, this.description);

  final int playerCount;
  final String displayName;
  final String description;
}

/// Configuration for a specific field type
class FieldConfig {
  const FieldConfig({
    required this.fieldType,
    required this.formations,
    required this.fieldPainter,
    this.centerCircleRadius = 0.12,
    this.penaltyBoxWidth = 0.5,
    this.penaltyBoxHeight = 0.18,
    this.sixYardBoxWidth = 0.3,
    this.sixYardBoxHeight = 0.1,
    this.penaltySpotDistance = 0.65,
  });

  final FieldType fieldType;
  final Map<String, FormationData> formations;
  final FieldPainterType fieldPainter;
  final double centerCircleRadius;
  final double penaltyBoxWidth;
  final double penaltyBoxHeight;
  final double sixYardBoxWidth;
  final double sixYardBoxHeight;
  final double penaltySpotDistance;

  int get playerCount => fieldType.playerCount;
}

/// Data for a formation including positions and metadata
class FormationData {
  const FormationData({
    required this.name,
    required this.positions,
    required this.description,
    required this.tags,
  });

  final String name;
  final List<PlayerPosition> positions;
  final String description;
  final List<String> tags;
}

/// Position on the field (normalized coordinates 0.0 to 1.0)
class PlayerPosition {
  const PlayerPosition(this.dx, this.dy);

  final double dx;
  final double dy;
}

/// Types of field painters
enum FieldPainterType {
  standard,
  sevenASide,
  fiveASide,
}
