import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:latlong2/latlong.dart';

class CustomTween extends Tween<LatLng> {
  CustomTween({ LatLng begin,  LatLng end})
      : super(begin: begin, end: end);

  @override
  LatLng lerp(double t) {
    double lat = lerpDouble(begin.latitude, end.latitude, t);
    double lng = lerpDouble(begin.longitude, end.longitude, t);
    return LatLng(lat, lng);
  }
}