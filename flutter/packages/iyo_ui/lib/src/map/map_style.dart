import 'dart:convert';

import 'package:flutter/painting.dart';

import '../theme/tokens.dart';

String _hex(Color c) =>
    '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

Map<String, Object> _rule(String? feature, String? element, List<Map<String, Object>> stylers) => {
  if (feature != null) 'featureType': feature,
  if (element != null) 'elementType': element,
  'stylers': stylers,
};

/// Google Maps style approximating the Figma map illustration: warm grey land, white streets,
/// muted water and parks, no POI clutter.
final String iyoMapStyleJson = jsonEncode([
  _rule(null, 'geometry', [
    {'color': _hex(IyoPalette.mapBackground)},
  ]),
  _rule(null, 'labels.text.fill', [
    {'color': _hex(IyoPalette.textSecondary)},
  ]),
  _rule(null, 'labels.text.stroke', [
    {'color': _hex(IyoPalette.white)},
    {'weight': 2},
  ]),
  _rule(null, 'labels.icon', [
    {'visibility': 'off'},
  ]),
  _rule('poi', null, [
    {'visibility': 'off'},
  ]),
  _rule('poi.park', null, [
    {'visibility': 'on'},
  ]),
  _rule('poi.park', 'geometry', [
    {'color': _hex(IyoPalette.mapPark)},
  ]),
  _rule('poi.park', 'labels', [
    {'visibility': 'off'},
  ]),
  _rule('road', 'geometry', [
    {'color': _hex(IyoPalette.white)},
  ]),
  _rule('road', 'geometry.stroke', [
    {'visibility': 'off'},
  ]),
  _rule('transit', null, [
    {'visibility': 'off'},
  ]),
  _rule('water', 'geometry', [
    {'color': _hex(IyoPalette.mapWater)},
  ]),
  _rule('administrative', 'geometry', [
    {'visibility': 'off'},
  ]),
]);
