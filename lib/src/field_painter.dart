import 'package:flutter/material.dart';

import 'field_config.dart';

/// Base class for field painters
abstract class BaseFieldPainter extends CustomPainter {
  const BaseFieldPainter({required this.config});

  final FieldConfig config;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  /// Draw the standard field markings
  void drawFieldMarkings(Canvas canvas, Size size, Paint paint) {
    // Override in subclasses
  }
}

/// Standard 11-a-side field painter
class StandardFieldPainter extends BaseFieldPainter {
  const StandardFieldPainter({required super.config});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..color = Colors.white.withOpacity(0.25);

    // Outer boundary
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(8, 8, size.width - 16, size.height - 16),
        const Radius.circular(8),
      ),
      paint,
    );

    // Center line
    canvas.drawLine(
      Offset(8, size.height / 2),
      Offset(size.width - 8, size.height / 2),
      paint,
    );

    // Center circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * config.centerCircleRadius,
      paint,
    );

    // Center spot
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 3, paint);
    paint.style = PaintingStyle.stroke;

    // Penalty boxes
    final penaltyBoxWidth = size.width * config.penaltyBoxWidth;
    final penaltyBoxHeight = size.height * config.penaltyBoxHeight;

    // Top penalty box
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - penaltyBoxWidth) / 2,
        8,
        penaltyBoxWidth,
        penaltyBoxHeight,
      ),
      paint,
    );

    // Bottom penalty box
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - penaltyBoxWidth) / 2,
        size.height - 8 - penaltyBoxHeight,
        penaltyBoxWidth,
        penaltyBoxHeight,
      ),
      paint,
    );

    // Six-yard boxes
    final sixYardBoxWidth = size.width * config.sixYardBoxWidth;
    final sixYardBoxHeight = size.height * config.sixYardBoxHeight;

    // Top six-yard box
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - sixYardBoxWidth) / 2,
        8,
        sixYardBoxWidth,
        sixYardBoxHeight,
      ),
      paint,
    );

    // Bottom six-yard box
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - sixYardBoxWidth) / 2,
        size.height - 8 - sixYardBoxHeight,
        sixYardBoxWidth,
        sixYardBoxHeight,
      ),
      paint,
    );

    // Penalty spots
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width / 2, 8 + penaltyBoxHeight * 0.75),
      3,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width / 2, size.height - 8 - penaltyBoxHeight * 0.75),
      3,
      paint,
    );
  }
}

/// Seven-a-side field painter
class SevenASideFieldPainter extends BaseFieldPainter {
  const SevenASideFieldPainter({required super.config});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..color = Colors.white.withOpacity(0.25);

    // Outer boundary
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(8, 8, size.width - 16, size.height - 16),
        const Radius.circular(8),
      ),
      paint,
    );

    // Center line
    canvas.drawLine(
      Offset(8, size.height / 2),
      Offset(size.width - 8, size.height / 2),
      paint,
    );

    // Center circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * config.centerCircleRadius,
      paint,
    );

    // Center spot
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 3, paint);
    paint.style = PaintingStyle.stroke;

    // Penalty boxes
    final penaltyBoxWidth = size.width * config.penaltyBoxWidth;
    final penaltyBoxHeight = size.height * config.penaltyBoxHeight;

    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - penaltyBoxWidth) / 2,
        8,
        penaltyBoxWidth,
        penaltyBoxHeight,
      ),
      paint,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - penaltyBoxWidth) / 2,
        size.height - 8 - penaltyBoxHeight,
        penaltyBoxWidth,
        penaltyBoxHeight,
      ),
      paint,
    );

    // Penalty spots
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width / 2, 8 + penaltyBoxHeight * 0.72),
      3,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width / 2, size.height - 8 - penaltyBoxHeight * 0.72),
      3,
      paint,
    );
  }
}

/// Five-a-side field painter
class FiveASideFieldPainter extends BaseFieldPainter {
  const FiveASideFieldPainter({required super.config});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..color = Colors.white.withOpacity(0.25);

    // Outer boundary
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(8, 8, size.width - 16, size.height - 16),
        const Radius.circular(8),
      ),
      paint,
    );

    // Center line
    canvas.drawLine(
      Offset(8, size.height / 2),
      Offset(size.width - 8, size.height / 2),
      paint,
    );

    // Center circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * config.centerCircleRadius,
      paint,
    );

    // Center spot
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 2.5, paint);
    paint.style = PaintingStyle.stroke;

    // Penalty boxes
    final penaltyBoxWidth = size.width * config.penaltyBoxWidth;
    final penaltyBoxHeight = size.height * config.penaltyBoxHeight;

    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - penaltyBoxWidth) / 2,
        8,
        penaltyBoxWidth,
        penaltyBoxHeight,
      ),
      paint,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - penaltyBoxWidth) / 2,
        size.height - 8 - penaltyBoxHeight,
        penaltyBoxWidth,
        penaltyBoxHeight,
      ),
      paint,
    );

    // Penalty spots
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width / 2, 8 + penaltyBoxHeight * 0.68),
      2.5,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width / 2, size.height - 8 - penaltyBoxHeight * 0.68),
      2.5,
      paint,
    );
  }
}

/// Factory for creating field painters
class FieldPainterFactory {
  static BaseFieldPainter create(FieldConfig config) {
    switch (config.fieldPainter) {
      case FieldPainterType.standard:
        return StandardFieldPainter(config: config);
      case FieldPainterType.sevenASide:
        return SevenASideFieldPainter(config: config);
      case FieldPainterType.fiveASide:
        return FiveASideFieldPainter(config: config);
    }
  }
}