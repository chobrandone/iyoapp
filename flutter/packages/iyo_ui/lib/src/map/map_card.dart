import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/iyo_theme.dart';
import '../theme/tokens.dart';
import '../widgets/buttons.dart';
import 'map_style.dart';
import 'marker_glyphs.dart';

/// Douala city centre (Akwa), the default when no location is known yet.
const LatLng doualaCenter = LatLng(4.0511, 9.7679);

/// Yaoundé city centre.
const LatLng yaoundeCenter = LatLng(3.848, 11.5021);

/// The Maps SDK key is compiled in with `--dart-define-from-file`. Without it the Google Maps
/// SDK would fail on Android, so [IyoMapCard] draws a schematic map instead.
const String _mapsKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
bool get googleMapsAvailable => _mapsKey.isNotEmpty;

class IyoMapMarker {
  const IyoMapMarker({
    required this.id,
    required this.kind,
    required this.position,
    this.heading = 0,
  });

  final String id;
  final IyoMarkerKind kind;
  final LatLng position;

  /// Compass heading in degrees (car markers rotate).
  final double heading;
}

/// Figma "Live map": rounded (16) map with an optional white recenter button, markers and the
/// route (7 px ink outline under a 4 px accent line).
class IyoMapCard extends StatefulWidget {
  const IyoMapCard({
    super.key,
    required this.center,
    this.zoom = 14.5,
    this.height = 220,
    this.markers = const [],
    this.route = const [],
    this.fitToContent = false,
    this.onRecenter,
    this.recenterLabel = 'Recenter map',
    this.showsUserLocation = false,
  });

  final LatLng center;
  final double zoom;

  /// Figma heights: 220 (home), 230–275 (trip screens).
  final double height;
  final List<IyoMapMarker> markers;
  final List<LatLng> route;

  /// Fit the camera to the markers and route.
  final bool fitToContent;

  /// Shows the white 36 px recenter button bottom-right.
  final VoidCallback? onRecenter;
  final String recenterLabel;
  final bool showsUserLocation;

  @override
  State<IyoMapCard> createState() => _IyoMapCardState();
}

class _IyoMapCardState extends State<IyoMapCard> {
  final _controller = Completer<GoogleMapController>();
  IyoMarkerBitmaps? _bitmaps;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (googleMapsAvailable && _bitmaps == null) {
      IyoMarkerBitmaps.load(MediaQuery.devicePixelRatioOf(context)).then((b) {
        if (mounted) setState(() => _bitmaps = b);
      });
    }
  }

  List<LatLng> get _points => [for (final m in widget.markers) m.position, ...widget.route];

  Future<void> _fit(GoogleMapController c) async {
    final points = _points;
    if (!widget.fitToContent || points.length < 2) return;
    await c.animateCamera(CameraUpdate.newLatLngBounds(_bounds(points), 40));
  }

  Future<void> _recenter() async {
    if (_controller.isCompleted) {
      final c = await _controller.future;
      await c.animateCamera(CameraUpdate.newLatLngZoom(widget.center, widget.zoom));
    }
    widget.onRecenter?.call();
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.iyo.accent;
    final Widget map;
    if (googleMapsAvailable) {
      final bitmaps = _bitmaps;
      map = GoogleMap(
        initialCameraPosition: CameraPosition(target: widget.center, zoom: widget.zoom),
        style: iyoMapStyleJson,
        myLocationEnabled: widget.showsUserLocation,
        myLocationButtonEnabled: false,
        compassEnabled: false,
        mapToolbarEnabled: false,
        zoomControlsEnabled: false,
        rotateGesturesEnabled: false,
        tiltGesturesEnabled: false,
        markers: {
          if (bitmaps != null)
            for (final m in widget.markers)
              Marker(
                markerId: MarkerId(m.id),
                position: m.position,
                icon: bitmaps[m.kind],
                anchor: const Offset(0.5, 0.5),
                rotation: m.heading,
                flat: m.kind == IyoMarkerKind.car,
              ),
        },
        polylines: {
          if (widget.route.length >= 2) ...{
            Polyline(
              polylineId: const PolylineId('route-outline'),
              points: widget.route,
              color: IyoPalette.ink,
              width: 7,
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
              jointType: JointType.round,
              zIndex: 1,
            ),
            Polyline(
              polylineId: const PolylineId('route'),
              points: widget.route,
              color: accent,
              width: 4,
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
              jointType: JointType.round,
              zIndex: 2,
            ),
          },
        },
        onMapCreated: (c) {
          _controller.complete(c);
          unawaited(_fit(c));
        },
      );
    } else {
      map = CustomPaint(
        painter: _SchematicMapPainter(
          center: widget.center,
          markers: widget.markers,
          route: widget.route,
          accent: accent,
        ),
        size: Size.infinite,
      );
    }

    return Semantics(
      label: 'Map',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(IyoRadii.lg),
        child: SizedBox(
          height: widget.height,
          width: double.infinity,
          child: ColoredBox(
            color: IyoPalette.mapBackground,
            child: Stack(
              children: [
                Positioned.fill(child: map),
                if (widget.onRecenter != null)
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: IyoIconButton(
                      icon: LucideIcons.locateFixed,
                      tone: IyoIconButtonTone.white,
                      size: IyoSizes.mapRecenter,
                      iconSize: IyoSizes.iconSmall,
                      semanticLabel: widget.recenterLabel,
                      onPressed: _recenter,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

LatLngBounds _bounds(List<LatLng> points) {
  var south = points.first.latitude, north = south;
  var west = points.first.longitude, east = west;
  for (final p in points) {
    south = math.min(south, p.latitude);
    north = math.max(north, p.latitude);
    west = math.min(west, p.longitude);
    east = math.max(east, p.longitude);
  }
  return LatLngBounds(southwest: LatLng(south, west), northeast: LatLng(north, east));
}

/// Stand-in used when no Maps key is configured: warm-grey land, a faint street grid, the route
/// and the real marker glyphs, all projected into the card.
class _SchematicMapPainter extends CustomPainter {
  _SchematicMapPainter({
    required this.center,
    required this.markers,
    required this.route,
    required this.accent,
  });

  final LatLng center;
  final List<IyoMapMarker> markers;
  final List<LatLng> route;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = IyoPalette.mapBackground);

    // Faint street grid with a park and a river, echoing the Figma illustration.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.08, size.height * 0.12, size.width * 0.22, size.height * 0.24),
        const Radius.circular(10),
      ),
      Paint()..color = IyoPalette.mapPark,
    );
    final river =
        Path()
          ..moveTo(size.width * 0.72, -10)
          ..quadraticBezierTo(
            size.width * 0.6,
            size.height * 0.5,
            size.width * 0.9,
            size.height + 10,
          );
    canvas.drawPath(
      river,
      Paint()
        ..color = IyoPalette.mapWater
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18,
    );
    final street =
        Paint()
          ..color = IyoPalette.white
          ..strokeWidth = 6;
    for (var x = size.width * 0.18; x < size.width; x += size.width * 0.27) {
      canvas.drawLine(Offset(x, 0), Offset(x - 30, size.height), street);
    }
    for (var y = size.height * 0.28; y < size.height; y += size.height * 0.36) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 18), street);
    }

    final points = [center, for (final m in markers) m.position, ...route];
    final bounds = _bounds(points);
    // Pad so markers never touch the edges; keep a minimum span (~1 km) around a lone point.
    final latSpan = math.max(bounds.northeast.latitude - bounds.southwest.latitude, 0.01);
    final lngSpan = math.max(bounds.northeast.longitude - bounds.southwest.longitude, 0.01);
    final midLat = (bounds.northeast.latitude + bounds.southwest.latitude) / 2;
    final midLng = (bounds.northeast.longitude + bounds.southwest.longitude) / 2;
    const pad = 36.0;
    final scale = math.min((size.width - 2 * pad) / lngSpan, (size.height - 2 * pad) / latSpan);
    Offset project(LatLng p) => Offset(
      size.width / 2 + (p.longitude - midLng) * scale,
      size.height / 2 - (p.latitude - midLat) * scale,
    );

    if (route.length >= 2) {
      final path = Path()..moveTo(project(route.first).dx, project(route.first).dy);
      for (final p in route.skip(1)) {
        final o = project(p);
        path.lineTo(o.dx, o.dy);
      }
      Paint line(Color c, double w) =>
          Paint()
            ..color = c
            ..style = PaintingStyle.stroke
            ..strokeWidth = w
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, line(IyoPalette.ink, 7));
      canvas.drawPath(path, line(accent, 4));
    }

    for (final m in markers) {
      final o = project(m.position) - m.kind.size.center(Offset.zero);
      canvas.save();
      canvas.translate(o.dx, o.dy);
      paintMarker(canvas, m.kind, heading: m.heading);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_SchematicMapPainter old) =>
      old.center != center || old.markers != markers || old.route != route || old.accent != accent;
}
