import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/tokens.dart';

/// The three marker shapes from Figma, painted on a canvas so the same drawing is used for
/// Google Maps bitmaps and for the schematic fallback map.
enum IyoMarkerKind {
  /// "Car marker": 38 × 28 ink rounded rect (radius 8) with a white 22 px car.
  car(Size(38, 28)),

  /// "Pickup marker": 8 px ink dot in a 16 px white ring with a 42 px yellow halo (22%).
  pickup(Size(42, 42)),

  /// Destination: same dot and ring, no halo.
  destination(Size(16, 16));

  const IyoMarkerKind(this.size);

  final Size size;
}

void paintMarker(Canvas canvas, IyoMarkerKind kind, {double heading = 0}) {
  final size = kind.size;
  final center = size.center(Offset.zero);
  switch (kind) {
    case IyoMarkerKind.car:
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(heading * math.pi / 180);
      canvas.translate(-center.dx, -center.dy);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(IyoRadii.sm)),
        Paint()..color = IyoPalette.ink,
      );
      final glyph = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(LucideIcons.carFront.codePoint),
          style: TextStyle(
            fontFamily: LucideIcons.carFront.fontFamily,
            package: LucideIcons.carFront.fontPackage,
            fontSize: IyoSizes.icon,
            color: IyoPalette.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      glyph.paint(canvas, center - Offset(glyph.width / 2, glyph.height / 2));
      canvas.restore();
    case IyoMarkerKind.pickup:
      canvas.drawCircle(center, 21, Paint()..color = IyoPalette.primaryHalo);
      _paintDot(canvas, center);
    case IyoMarkerKind.destination:
      _paintDot(canvas, center);
  }
}

void _paintDot(Canvas canvas, Offset center) {
  canvas.drawCircle(center, 8, Paint()..color = IyoPalette.white);
  canvas.drawCircle(center, 4, Paint()..color = IyoPalette.ink);
}

/// Rasterised marker icons for Google Maps, cached per device pixel ratio.
class IyoMarkerBitmaps {
  IyoMarkerBitmaps._(this._icons);

  final Map<IyoMarkerKind, BitmapDescriptor> _icons;

  BitmapDescriptor operator [](IyoMarkerKind kind) => _icons[kind]!;

  static final Map<double, Future<IyoMarkerBitmaps>> _cache = {};

  static Future<IyoMarkerBitmaps> load(double devicePixelRatio) =>
      _cache[devicePixelRatio] ??= _render(devicePixelRatio);

  static Future<IyoMarkerBitmaps> _render(double dpr) async {
    final icons = <IyoMarkerKind, BitmapDescriptor>{};
    for (final kind in IyoMarkerKind.values) {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder)..scale(dpr);
      paintMarker(canvas, kind);
      final image = await recorder.endRecording().toImage(
        (kind.size.width * dpr).ceil(),
        (kind.size.height * dpr).ceil(),
      );
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      icons[kind] = BitmapDescriptor.bytes(bytes!.buffer.asUint8List(), imagePixelRatio: dpr);
    }
    return IyoMarkerBitmaps._(icons);
  }
}
