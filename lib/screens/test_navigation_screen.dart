import 'dart:async';
import 'dart:math';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:test_project/services/custom_tween.dart';
import 'package:test_project/services/helper_functions.dart';
import 'package:flutter_animarker/flutter_map_marker_animation.dart';

class TestNavigationScreen extends StatefulWidget {
  const TestNavigationScreen({Key key}) : super(key: key);

  @override
  State<TestNavigationScreen> createState() => _TestNavigationScreenState();
}

class _TestNavigationScreenState extends State<TestNavigationScreen>
    with SingleTickerProviderStateMixin {
  // LatLng sourceDestination = LatLng(28.510303857716526, 77.0958547091986);
  LatLng sourceDestination = LatLng(28.486985781833592, 77.0783794319682);
  LatLng currentLocation = LatLng(
    HelperFunctions.myLatitude,
    HelperFunctions.myLongtitude,
  );

  Animation<LatLng> animation;
  AnimationController animationController;
  MapController mapController;

  StreamSubscription<geo.Position> positionStream;

  final geo.LocationSettings settings = const geo.LocationSettings(
    accuracy: geo.LocationAccuracy.bestForNavigation,
    distanceFilter: 20,
  );

  final List<Marker> markers = [];

  double zoom = 15;

  Random random = Random();
// 28.486985781833592, 77.0783794319682
  @override
  void initState() {
    super.initState();

    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));

    animation = CustomTween(begin: currentLocation, end: sourceDestination)
        .animate(animationController)
      ..addListener(() {
        setState(() {});
      });

    animationController.forward();
    // markers.add(Marker(
    //     point: currentLocation,
    //     builder: (context) =>
    //         Container(key: const Key('test'), child: const FlutterLogo())));
    // positionStream =
    //     geo.Geolocator.getPositionStream(locationSettings: settings)
    //         .listen((geo.Position p) async {
    //   setState(() {
    //     markers[0] = Marker(
    //       point: currentLocation,
    //       builder: (context) => Container(
    //         key: const Key('test'),
    //         child: const FlutterLogo(),
    //       ),
    //     );
    //   });

    //   await Future.delayed(
    //       Duration(milliseconds: min(1000, random.nextInt(5000))), () {
    //     setState(() {
    //       currentLocation = LatLng(p.latitude + 0.001, p.longitude + 0.001);
    //     });
    //   });

    //   await Future.delayed(
    //       Duration(milliseconds: min(1000, random.nextInt(1000) + 100)), () {
    //     setState(() {
    //       sourceDestination = LatLng(p.latitude - 0.01, p.longitude - 0.002);
    //     });
    //   });
    // });
    // _getCurrentLocation();
  }

  // static CameraPosition initialCameraPostion = CameraPosition(
  //   target: LatLng(
  //     HelperFunctions.myLatitude,
  //     HelperFunctions.myLongtitude,
  //   ),
  //   zoom: 15,
  // );

  @override
  void dispose() {
    positionStream.cancel();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HelperFunctions.myLatitude == 0 && HelperFunctions.myLongtitude == 0
          ? const Center(child: Text("Loading"))
          : FlutterMap(
              options: MapOptions(
                center: currentLocation,
                zoom: zoom,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                ),
                // MarkerLayer(markers: markers)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: animation.value,
                      builder: (context) => Container(
                        key: const Key('test'),
                        child: const FlutterLogo(),
                      )
                    ),
                  ],
                )
              ],
            ),
    );
  }
}
