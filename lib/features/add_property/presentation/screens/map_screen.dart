import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart' as gl;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;

import '../../../../core/common/cubits/app_theme/theme_cubit.dart';
import '../../../../core/common/cubits/app_theme/theme_state.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  mp.MapboxMap? mapboxMapController;
  mp.PointAnnotationManager? pointAnnotationManager;
  mp.Snapshotter? snapshotter;
  StreamSubscription? userPositionStream;
  var isDarkMode = false;

  num? chosenLng;
  num? chosenLat;

  @override
  void initState() {
    _checkLocationPermission();
    super.initState();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    gl.LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await gl.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Location Services Disabled'),
            content:
                const Text('Please enable location services to use the map.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      return;
    }

    // Check location permission
    permission = await gl.Geolocator.checkPermission();
    if (permission == gl.LocationPermission.denied) {
      permission = await gl.Geolocator.requestPermission();
      if (permission == gl.LocationPermission.denied) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Location Permission Denied'),
              content: const Text(
                  'Location permissions are required to use the map.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
        return;
      }
    }

    if (permission == gl.LocationPermission.deniedForever) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Location Permission Denied'),
            content: const Text(
                'Location permissions are permanently denied. Please enable them in settings.'),
            actions: [
              TextButton(
                onPressed: () => gl.Geolocator.openAppSettings(),
                child: const Text('Open Settings'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      }
      return;
    }

    gl.LocationSettings locationSettings = const gl.LocationSettings(
      accuracy: gl.LocationAccuracy.bestForNavigation,
      distanceFilter: 10,
    );

    userPositionStream?.cancel();
    userPositionStream = gl.Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((gl.Position? position) {
      if (position != null && mapboxMapController != null) {
        mapboxMapController?.setCamera(mp.CameraOptions(
          zoom: 15,
          center: mp.Point(
            coordinates: mp.Position(position.longitude, position.latitude),
          ),
        ));
      }
    });
  }

  Future<Uint8List> _loadImageMarker() async {
    var byteData = await rootBundle.load('assets/icons/location.png');

    return byteData.buffer.asUint8List();
  }

  Future<void> _onMapCreated(mp.MapboxMap controller) async {
    setState(() {
      mapboxMapController = controller;
    });

    pointAnnotationManager =
        await controller.annotations.createPointAnnotationManager();

    mapboxMapController?.location.updateSettings(
      mp.LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
      ),
    );
  }

  Future<void> _onMapTap(mp.MapContentGestureContext context) async {
    if (pointAnnotationManager == null) {
      return;
    }

    await pointAnnotationManager?.deleteAll();

    chosenLng = context.point.coordinates.lng;
    chosenLat = context.point.coordinates.lat;

    final Uint8List icon = await _loadImageMarker();

    if (chosenLng != null && chosenLat != null) {
      mp.PointAnnotationOptions pointAnnotationOptions =
          mp.PointAnnotationOptions(
        image: icon,
        iconSize: 2,
        geometry: mp.Point(
          coordinates: mp.Position(
            chosenLng!,
            chosenLat!,
          ),
        ),
      );
      setState(() {
        pointAnnotationManager?.create(pointAnnotationOptions);
      });
    }
  }

  @override
  void dispose() {
    userPositionStream?.cancel();
    snapshotter?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose property location'),
        actions: <Widget>[
          IconButton(
            onPressed: chosenLng == null || chosenLat == null
                ? null
                : () async {
                    final screenData = MediaQuery.of(context);

                    snapshotter = await mp.Snapshotter.create(
                      options: mp.MapSnapshotOptions(
                        size: mp.Size(
                          width: screenData.size.width,
                          height: 200,
                        ),
                        pixelRatio: screenData.devicePixelRatio,
                        showsLogo: true,
                        showsAttribution: true,
                      ),
                    );

                    snapshotter?.style.setStyleURI(isDarkMode
                        ? mp.MapboxStyles.DARK
                        : mp.MapboxStyles.LIGHT);

                    if (chosenLat != null && chosenLng != null) {
                      snapshotter?.setCamera(mp.CameraOptions(
                        center: mp.Point(
                          coordinates: mp.Position(
                            chosenLng!,
                            chosenLat!,
                          ),
                        ),
                        zoom: 15,
                      ));
                    }

                    final snapshot = await snapshotter?.start();

                    Navigator.pop(
                      context,
                      snapshot,
                    );
                  },
            icon: const Icon(Icons.check),
          )
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, state) {
            isDarkMode = state.isDarkMode;

            return mp.MapWidget(
              styleUri: state.isDarkMode
                  ? mp.MapboxStyles.DARK
                  : mp.MapboxStyles.LIGHT,
              onMapCreated: _onMapCreated,
              onTapListener: _onMapTap,
            );
          },
        ),
      ),
    );
  }
}
