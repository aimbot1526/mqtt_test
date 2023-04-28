import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:test_project/services/helper_functions.dart';
import 'package:flutter_animarker/flutter_map_marker_animation.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  LatLng sourceLocation = LatLng(
    HelperFunctions.myLatitude,
    HelperFunctions.myLongtitude,
  );
  LatLng sourceDestination = const LatLng(28.510303857716526, 77.0958547091986);
  LatLng currentLocation =
      LatLng(HelperFunctions.myLatitude, HelperFunctions.myLongtitude);
  List<LatLng> polylineCoordinates = [];

  late StreamSubscription<geo.Position> positionStream;
  final markers = <MarkerId, Marker>{};
  final Completer<GoogleMapController> _mapController = Completer();

  final geo.LocationSettings locationSettings = const geo.LocationSettings(
    accuracy: geo.LocationAccuracy.high,
    distanceFilter: 10,
  );

  void _getCurrentLocation() async {
    positionStream = geo.Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((newLoc) {
      setState(() {
        currentLocation = LatLng(newLoc.latitude, newLoc.longitude);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  static CameraPosition initialCameraPostion = CameraPosition(
    target: LatLng(
      HelperFunctions.myLatitude,
      HelperFunctions.myLongtitude,
    ),
    zoom: 14.4746,
  );

  @override
  void dispose() {
    super.dispose();
    // positionStream.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: HelperFunctions.myLatitude == 0 &&
                HelperFunctions.myLongtitude == 0
            ? const Center(
                child: Text("Loading"),
              )
            : Animarker(
                curve: Curves.bounceInOut,
                duration: const Duration(milliseconds: 1000),
                mapId: _mapController.future.then<int>((value) => value.mapId),
                child: GoogleMap(
                  zoomControlsEnabled: false,
                  initialCameraPosition: initialCameraPostion,
                  onMapCreated: (controller) {
                    // setState(() {
                    //   _mapController = controller;
                    // });
                    _mapController.complete(controller);
                  },
                  markers: {
                    Marker(
                      markerId: const MarkerId("source"),
                      position: currentLocation,
                      icon: BitmapDescriptor.fromBytes(
                        HelperFunctions.customMarker,
                      ),
                    ),
                    Marker(
                      markerId: const MarkerId("destination"),
                      position: sourceDestination,
                    ),
                  },
                )));
  }
}
