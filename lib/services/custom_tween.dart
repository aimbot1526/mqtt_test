import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomTween extends Tween<LatLng> {
  CustomTween({LatLng begin, LatLng end})
      : super(begin: begin, end: end);

  @override
  LatLng lerp(double t) => LatLng(
        lerpDouble(begin.latitude, end.latitude, t),
        lerpDouble(begin.longitude, end.longitude, t),
      );
}