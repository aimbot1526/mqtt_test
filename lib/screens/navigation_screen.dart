import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:test_project/services/helper_functions.dart';
import 'package:flutter_animarker/flutter_map_marker_animation.dart';

class NavigationScreen extends StatefulWidget {
  NavigationScreen({Key key}) : super(key: key);

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  LatLng sourceDestination = LatLng(28.510303857716526, 77.0958547091986);
  LatLng currentLocation =
      LatLng(HelperFunctions.myLatitude, HelperFunctions.myLongtitude);

  StreamSubscription<geo.Position> positionStream;
  final Completer<GoogleMapController> _mapController = Completer();

  final geo.LocationSettings settings = const geo.LocationSettings(
    accuracy: geo.LocationAccuracy.bestForNavigation,
    distanceFilter: 20,
  );

  final Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};

  double zoom = 15;

  Random random = Random();

  @override
  void dispose() {
    positionStream.cancel();
    _mapController.future.then((value) => {
      value.dispose()
    });
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    positionStream =
        geo.Geolocator.getPositionStream(locationSettings: settings)
            .listen((geo.Position p) async {
      setState(() {
        var markerId = const MarkerId('source');
        _markers[markerId] = Marker(
          markerId: markerId,
          icon: BitmapDescriptor.fromBytes(HelperFunctions.customMarker),
          rotation: 180,
          position: LatLng(p.latitude, p.longitude),
        );
      });

      await Future.delayed(
          Duration(milliseconds: min(1000, random.nextInt(5000))), () {
        setState(() {
          currentLocation = LatLng(p.latitude + 0.001, p.longitude + 0.001);
        });
      });

      await Future.delayed(
          Duration(milliseconds: min(1000, random.nextInt(1000) + 100)), () {
        setState(() {
          sourceDestination = LatLng(p.latitude - 0.01, p.longitude - 0.002);
        });
      });
    });
    // _getCurrentLocation();
  }

  static CameraPosition initialCameraPostion = CameraPosition(
    target: LatLng(
      HelperFunctions.myLatitude,
      HelperFunctions.myLongtitude,
    ),
    zoom: 15,
  );

  Future<void> onStopover(LatLng latLng) async {
    if (!_mapController.isCompleted) return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HelperFunctions.myLatitude == 0 && HelperFunctions.myLongtitude == 0
          ? const Center(child: Text("Loading"))
          : Animarker(
              // mapId: _mapController.future.then<int>((value) => value.mapId),
              isActiveTrip: true,
              useRotation: true,
              zoom: zoom,
              // calculate ping timeline and make dynamic
              duration: const Duration(milliseconds: 3000),
              onStopover: onStopover,
              markers: <Marker>{..._markers.values.toSet()},
              child: GoogleMap(
                zoomControlsEnabled: false,
                initialCameraPosition: initialCameraPostion,
                // onMapCreated: (controller) {
                //   _mapController.complete(controller);
                // },
                onCameraMove: (position) =>
                    setState(() => zoom = position.zoom),
              ),
            ),
    );
  }
}