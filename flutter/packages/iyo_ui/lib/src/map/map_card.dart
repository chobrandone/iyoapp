import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/iyo_theme.dart';
import '../theme/tokens.dart';
import '../widgets/buttons.dart';
import 'map_illustration.dart';
import 'map_style.dart';
import 'marker_glyphs.dart';

/// Douala city centre (Akwa), the default when no location is known yet.
const LatLng doualaCenter = LatLng(4.0511, 9.7679);

/// Yaoundé city centre.
const LatLng yaoundeCenter = LatLng(3.848, 11.5021);

/// The Maps SDK key is compiled in with `--dart-define-from-file`. Without it the Google Maps
/// SDK would fail on Android, so [IyoMapCard] draws the Figma map illustration instead.
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
      // UI-only builds: the Figma illustration, with each marker kind in its Figma slot.
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
