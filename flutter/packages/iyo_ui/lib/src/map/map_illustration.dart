import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'marker_glyphs.dart';

/// Point on the Figma map illustration, as a fraction of the card (x of width, y of height).
/// The illustration stretches vertically with the card, like the Figma frames (216–256 px tall).
typedef MapSlot = Offset;

/// Pin and route positions used by the Figma frames.
abstract final class IyoMapSlots {
  static const MapSlot pickup = Offset(0.316, 0.607);
  static const MapSlot car = Offset(0.600, 0.531);
  static const MapSlot destination = Offset(0.851, 0.164);

  /// Pickup → destination along the streets (the yellow route on trip screens).
  static const List<MapSlot> route = [
    pickup,
    Offset(0.316, 0.531),
    Offset(0.600, 0.531),
    Offset(0.600, 0.300),
    Offset(0.851, 0.300),
    destination,
  ];
}

class IyoMapPin {
  const IyoMapPin(this.kind, this.slot, {this.heading = 0});

  final IyoMarkerKind kind;
  final MapSlot slot;
  final double heading;
}

/// The stylised city map from the Figma file: warm-grey land, parks, a river, a white street
/// grid with one diagonal avenue, neighbourhood labels, the route and the real marker glyphs.
/// Used whenever no Google Maps key is configured (UI-only builds and the design review).
class IyoMapIllustration extends StatelessWidget {
  const IyoMapIllustration({
    super.key,
    this.pins = const [],
    this.route = const [],
    required this.accent,
    this.labels = const IyoMapLabels(),
  });

  final List<IyoMapPin> pins;
  final List<MapSlot> route;
  final Color accent;
  final IyoMapLabels labels;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _IllustrationPainter(pins: pins, route: route, accent: accent, labels: labels),
      size: Size.infinite,
    );
  }
}

/// Neighbourhood names printed on the illustration (Figma shows London placeholders).
class IyoMapLabels {
  const IyoMapLabels({
    this.park = 'Jardin de Bonanjo',
    this.district = 'Akwa',
    this.otherDistrict = 'Bonapriso',
  });

  /// Sentence-case label on the top-left park.
  final String park;

  /// Uppercase district label under the park.
  final String district;

  /// Uppercase district label on the right.
  final String otherDistrict;
}

class _IllustrationPainter extends CustomPainter {
  _IllustrationPainter({
    required this.pins,
    required this.route,
    required this.accent,
    required this.labels,
  });

  final List<IyoMapPin> pins;
  final List<MapSlot> route;
  final Color accent;
  final IyoMapLabels labels;

  static const double _street = 8;

  @override
  void paint(Canvas canvas, Size size) {
    Offset at(double x, double y) => Offset(x * size.width, y * size.height);

    canvas.drawRect(Offset.zero & size, Paint()..color = IyoPalette.mapBackground);

    // Parks.
    final park = Paint()..color = IyoPalette.mapPark;
    for (final r in const [
      Rect.fromLTRB(0.044, 0.082, 0.263, 0.254),
      Rect.fromLTRB(0.731, 0.066, 1.0, 0.254),
      Rect.fromLTRB(0.058, 0.773, 0.269, 0.970),
      Rect.fromLTRB(0.652, 0.652, 0.892, 0.840),
    ]) {
      canvas.drawRect(Rect.fromPoints(at(r.left, r.top), at(r.right, r.bottom)), park);
    }

    // River.
    final river =
        Path()
          ..moveTo(-10, 0.79 * size.height)
          ..cubicTo(
            0.30 * size.width,
            0.67 * size.height,
            0.62 * size.width,
            0.72 * size.height,
            size.width + 10,
            0.50 * size.height,
          );
    canvas.drawPath(
      river,
      Paint()
        ..color = IyoPalette.mapWater
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22,
    );

    // Streets (constant width; positions scale with the card).
    final street =
        Paint()
          ..color = IyoPalette.white
          ..strokeWidth = _street
          ..strokeCap = StrokeCap.square;
    void line(double x1, double y1, double x2, double y2) =>
        canvas.drawLine(at(x1, y1), at(x2, y2), street);
    line(0.140, 0.183, 0.857, 0.183);
    line(0.152, 0.300, 0.848, 0.300);
    line(0.146, 0.531, 0.828, 0.531);
    line(0.322, 0.871, 0.877, 0.871);
    line(0.158, 0.183, 0.158, 0.531);
    line(0.316, 0.183, 0.316, 0.871);
    line(0.602, 0.183, 0.602, 0.871);
    line(0.842, 0.183, 0.842, 0.833);
    line(0.146, 0.183, 0.863, 0.833);

    // Labels.
    void label(String text, double x, double yCenter, {bool upper = false}) {
      final tp = TextPainter(
        text: TextSpan(
          text: upper ? text.toUpperCase() : text,
          style: IyoTextVariant.micro.style.copyWith(
            fontSize: 8,
            color: IyoPalette.textSecondary,
            letterSpacing: upper ? 0.2 : 0,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      tp.paint(canvas, at(x, yCenter) - Offset(0, tp.height / 2));
    }

    label(labels.park, 0.068, 0.137);
    label(labels.district, 0.050, 0.251, upper: true);
    label(labels.otherDistrict, 0.696, 0.461, upper: true);

    // Route: 7 px ink outline under a 4 px accent line, square corners like Figma.
    if (route.length >= 2) {
      final path =
          Path()
            ..moveTo(at(route.first.dx, route.first.dy).dx, at(route.first.dx, route.first.dy).dy);
      for (final p in route.skip(1)) {
        final o = at(p.dx, p.dy);
        path.lineTo(o.dx, o.dy);
      }
      Paint stroke(Color c, double w) =>
          Paint()
            ..color = c
            ..style = PaintingStyle.stroke
            ..strokeWidth = w
            ..strokeJoin = StrokeJoin.miter;
      canvas.drawPath(path, stroke(IyoPalette.ink, 7));
      canvas.drawPath(path, stroke(accent, 4));
    }

    // Pins on top, car last.
    final ordered = [...pins]..sort(
      (a, b) => (a.kind == IyoMarkerKind.car ? 1 : 0) - (b.kind == IyoMarkerKind.car ? 1 : 0),
    );
    for (final pin in ordered) {
      final o = at(pin.slot.dx, pin.slot.dy) - pin.kind.size.center(Offset.zero);
      canvas.save();
      canvas.translate(o.dx, o.dy);
      paintMarker(canvas, pin.kind, heading: pin.heading);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_IllustrationPainter old) =>
      old.pins != pins || old.route != route || old.accent != accent || old.labels != labels;
}
