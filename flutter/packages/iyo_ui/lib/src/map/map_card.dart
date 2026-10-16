import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../theme/iyo_theme.dart';
import '../theme/tokens.dart';
import '../widgets/buttons.dart';
import 'map_illustration.dart';
import 'marker_glyphs.dart';

/// Douala city centre (Akwa), the default when no location is known yet.
const LatLng doualaCenter = LatLng(4.0511, 9.7679);

/// Yaoundé city centre.
const LatLng yaoundeCenter = LatLng(3.848, 11.5021);

/// Free vector map (OpenStreetMap data, no API key, no usage cap): the same light "Positron"
/// style as the operations dashboard. Rendered by MapLibre.
const String iyoMapStyleUrl = 'https://tiles.openfreemap.org/styles/positron';

/// Live maps everywhere except widget tests (no platform views there) and builds made with
/// `--dart-define=IYO_MAP=illustration`, which draw the Figma illustration instead.
bool get liveMapsAvailable =>
    !kIsWeb &&
    const String.fromEnvironment('IYO_MAP') != 'illustration' &&
    !Platform.environment.containsKey('FLUTTER_TEST');

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
    this.labels = const IyoMapLabels(),
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

  /// Neighbourhood names on the fallback illustration.
  final IyoMapLabels labels;

  @override
  State<IyoMapCard> createState() => _IyoMapCardState();
}

class _IyoMapCardState extends State<IyoMapCard> {
  MapLibreMapController? _controller;
  bool _styleReady = false;
  IyoMarkerBitmaps? _bitmaps;

  /// What is on the map now, so rebuilds only redraw when the content changes.
  String _drawn = '';

  /// Where the camera was last placed (it follows [IyoMapCard.center], e.g. a GPS fix).
  LatLng? _placedCenter;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (liveMapsAvailable && _bitmaps == null) {
      IyoMarkerBitmaps.load(MediaQuery.devicePixelRatioOf(context)).then((b) {
        if (!mounted) return;
        _bitmaps = b;
        unawaited(_draw());
      });
    }
  }

  @override
  void didUpdateWidget(IyoMapCard old) {
    super.didUpdateWidget(old);
    unawaited(_draw());
  }

  String get _signature => [
    'c:${widget.center.latitude},${widget.center.longitude}',
    for (final m in widget.markers)
      '${m.id}:${m.kind.name}:${m.position.latitude},${m.position.longitude}:${m.heading}',
    for (final p in widget.route) '${p.latitude},${p.longitude}',
  ].join('|');

  Future<void> _draw() async {
    final c = _controller;
    final bitmaps = _bitmaps;
    if (c == null || bitmaps == null || !_styleReady) return;
    final signature = _signature;
    if (signature == _drawn) return;
    final first = _drawn.isEmpty;
    _drawn = signature;
    final ink = _hex(IyoPalette.ink), accent = _hex(context.iyo.accent);
    await c.clearLines();
    await c.clearSymbols();
    if (widget.route.length >= 2) {
      await c.addLine(
        LineOptions(geometry: widget.route, lineColor: ink, lineWidth: 7, lineJoin: 'round'),
      );
      await c.addLine(
        LineOptions(geometry: widget.route, lineColor: accent, lineWidth: 4, lineJoin: 'round'),
      );
    }
    for (final m in widget.markers) {
      await c.addSymbol(
        SymbolOptions(
          geometry: m.position,
          iconImage: 'iyo-${m.kind.name}',
          // MapLibre draws added images at their pixel size, which already matches the screen.
          iconSize: 1,
          iconRotate: m.kind == IyoMarkerKind.car ? m.heading : 0,
        ),
      );
    }
    if (first || widget.fitToContent || widget.center != _placedCenter) {
      await _fit(c, animate: !first);
    }
  }

  Future<void> _fit(MapLibreMapController c, {bool animate = true}) async {
    _placedCenter = widget.center;
    final points = [for (final m in widget.markers) m.position, ...widget.route];
    final CameraUpdate update;
    if (widget.fitToContent && points.length >= 2) {
      update = CameraUpdate.newLatLngBounds(
        _bounds(points),
        left: 48,
        top: 48,
        right: 48,
        bottom: 48,
      );
    } else {
      update = CameraUpdate.newLatLngZoom(widget.center, widget.zoom);
    }
    if (animate) {
      await c.animateCamera(update);
    } else {
      await c.moveCamera(update);
    }
  }

  Future<void> _onStyleLoaded() async {
    final c = _controller;
    final bitmaps = _bitmaps ?? await IyoMarkerBitmaps.load(MediaQuery.devicePixelRatioOf(context));
    _bitmaps = bitmaps;
    if (c == null) return;
    for (final kind in IyoMarkerKind.values) {
      await c.addImage('iyo-${kind.name}', bitmaps[kind]);
    }
    _styleReady = true;
    _drawn = '';
    await _draw();
  }

  Future<void> _recenter() async {
    final c = _controller;
    if (c != null) await _fit(c);
    widget.onRecenter?.call();
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.iyo.accent;
    final Widget map;
    if (liveMapsAvailable) {
      map = MapLibreMap(
        styleString: iyoMapStyleUrl,
        initialCameraPosition: CameraPosition(target: widget.center, zoom: widget.zoom),
        myLocationEnabled: widget.showsUserLocation,
        compassEnabled: false,
        rotateGesturesEnabled: false,
        tiltGesturesEnabled: false,
        attributionButtonPosition: AttributionButtonPosition.bottomLeft,
        // The map sits inside scrolling screens: drag the map, not the page, when touching it.
        gestureRecognizers: {
          const Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
        },
        onMapCreated: (c) => _controller = c,
        onStyleLoadedCallback: () => unawaited(_onStyleLoaded()),
      );
    } else {
      // Tests and illustration builds: the Figma illustration, each marker kind in its slot.
      map = IyoMapIllustration(
        accent: accent,
        labels: widget.labels,
        route: widget.route.length >= 2 ? IyoMapSlots.route : const [],
        pins: [
          for (final m in widget.markers) IyoMapPin(m.kind, _slotFor(m.kind), heading: m.heading),
        ],
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

String _hex(Color c) => '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

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

/// Where each marker kind sits on the Figma illustration.
MapSlot _slotFor(IyoMarkerKind kind) => switch (kind) {
  IyoMarkerKind.pickup => IyoMapSlots.pickup,
  IyoMarkerKind.car => IyoMapSlots.car,
  IyoMarkerKind.destination => IyoMapSlots.destination,
};
