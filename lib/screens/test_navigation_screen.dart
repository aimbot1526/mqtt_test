import 'dart:async';
import 'dart:math';
import 'dart:developer' as d;
import 'dart:ui';
import 'package:flutter_map/flutter_map.dart';
// ignore: depend_on_referenced_packages
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;

class TestNavigationScreen extends StatefulWidget {
  const TestNavigationScreen({Key key}) : super(key: key);

  @override
  State<TestNavigationScreen> createState() => _TestNavigationScreenState();
}

class _TestNavigationScreenState extends State<TestNavigationScreen>
    with SingleTickerProviderStateMixin {
  LatLng currentLocation = LatLng(28.486985781833592, 77.0783794319682);

  Animation<LatLng> markerAnimation;
  AnimationController animationController;

  MapController mapController = MapController();

  StreamSubscription<geo.Position> positionStream;

  geo.LocationSettings settings = const geo.LocationSettings(
    accuracy: geo.LocationAccuracy.bestForNavigation,
    distanceFilter: 20,
  );
  double zoom = 17;

  CustomTween tween = CustomTween(
    begin: LatLng(28.486985781833592, 77.0783794319682),
    end: LatLng(28.486985781833592, 77.0783794319682),
  );

  @override
  void dispose() {
    positionStream.cancel();
    animationController.dispose();
    mapController.dispose();
    super.dispose();
  }

  void _moveCamera(LatLng markerPosition) {
    mapController.move(markerPosition, 16);
  }

  void moveCameraWithDelay(LatLng markerPosition) async {
    await Future.delayed(const Duration(milliseconds: 4000), () {
      mapController.move(markerPosition, 16);
    });
  } 

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));

    markerAnimation = tween.animate(animationController)
      ..addListener(() {
        setState(() {});
      });

    positionStream =
        geo.Geolocator.getPositionStream(locationSettings: settings)
            .listen((position) {
      LatLng newPosition = LatLng(position.latitude, position.longitude);
      if (tween.begin != newPosition) {
        tween.begin = tween.end;
        tween.end = newPosition;
        animationController.forward(from: 0.0);
        moveCameraWithDelay(markerAnimation.value);
      }
    });
    animationController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          center: currentLocation,
          zoom: zoom,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'dev.fleaflet.flutter_map.example',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: markerAnimation.value,
                builder: (context) => Container(
                  key: const Key('test'),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
                    child: Image.asset("assets/images/car.png"),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _moveCamera(markerAnimation.value);
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.location_searching),
      ),
    );
  }
}

class CustomTween extends Tween<LatLng> {
  CustomTween({
    LatLng begin,
    LatLng end,
  }) : super(begin: begin, end: end);

  @override
  LatLng lerp(double t) {
    if (begin == null || end == null) {
      throw FlutterError(
          'Both begin and end must be set before using a CustomTween.');
    }
    double lat = lerpDouble(begin.latitude, end.latitude, t);
    double lng = lerpDouble(begin.longitude, end.longitude, t);
    return LatLng(lat, lng);
  }
}
