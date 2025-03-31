import 'dart:developer';
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/common/entities/coordinate.dart';

class GoogleMapsScreen extends StatefulWidget {
  final num? lat;
  final num? lng;

  const GoogleMapsScreen({this.lat, this.lng, super.key});

  @override
  State<GoogleMapsScreen> createState() => _GoogleMapsScreenState();
}

class _GoogleMapsScreenState extends State<GoogleMapsScreen> {
  final _controller = Completer<GoogleMapController>();
  MapType _currentMapType = MapType.normal;
  bool _isLocationEnabled = false;
  final Set<Marker> _markers = {};

  num? lat;
  num? lng;

  static const _initialCameraPosition = CameraPosition(
    target: LatLng(32.22449, 76.156601),
    zoom: 18,
  );

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();

    if (widget.lat != null && widget.lng != null) {
      lat = widget.lat;
      lng = widget.lng;

      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('new-location'),
          position: LatLng(lat!.toDouble(), lng!.toDouble()),
          infoWindow: const InfoWindow(
            title: 'Your chosen location',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      );
    }
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _isLocationEnabled = false);
      if (mounted) {
        _showLocationDialog(
          'Location Services Disabled',
          'Please enable location services to use the map.',
        );
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isLocationEnabled = false);
        if (mounted) {
          _showLocationDialog(
            'Location Permission Denied',
            'Location permissions are required to use the map.',
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _isLocationEnabled = false);
      if (mounted) {
        _showLocationDialog(
          'Location Permission Denied',
          'Location permissions are permanently denied. Please enable them in settings.',
          showSettings: true,
        );
      }
      return;
    }

    setState(() => _isLocationEnabled = true);
    _getCurrentLocation();
  }

  void _showLocationDialog(String title, String content,
      {bool showSettings = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          if (showSettings)
            TextButton(
              onPressed: () => Geolocator.openAppSettings(),
              child: const Text('Open Settings'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      final Position position = await Geolocator.getCurrentPosition(
          // desiredAccuracy: LocationAccuracy.high,

          );

      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 18,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error getting location: $e');
      setState(() => _isLocationEnabled = false);
    }
  }

  void _onMapTypeButtonPressed(MapType mapType) {
    setState(() {
      _currentMapType = mapType;
    });
  }

  Future<Uint8List?> _captureMapSnapshot() async {
    try {
      final GoogleMapController controller = await _controller.future;

      if (lat != null && lng != null) {
        await controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(lat!.toDouble(), lng!.toDouble()),
              zoom: 15,
            ),
          ),
        );
      }
      await Future.delayed(const Duration(milliseconds: 300));

      return await controller.takeSnapshot();
    } catch (error) {
      log('google_maps_screen error: ', error: error);

      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            mapType: _currentMapType,
            markers: _markers,
            onMapCreated: (controller) {
              _controller.complete(controller);
            },
            myLocationButtonEnabled: _isLocationEnabled,
            myLocationEnabled: _isLocationEnabled,
            mapToolbarEnabled: true,
            onTap: (latLng) {
              setState(() {
                lat = latLng.latitude;
                lng = latLng.longitude;
              });

              _markers.clear();
              _markers.add(
                Marker(
                  markerId: const MarkerId('new-location'),
                  position: latLng,
                  infoWindow: const InfoWindow(
                    title: 'Your chosen location',
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen,
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: 200,
            right: 16,
            child: Card(
              elevation: 4,
              color: Colors.white.withValues(alpha: 0.6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                spacing: 2,
                children: <Widget>[
                  _mapStyleSelectionButton(
                    icon: Icons.map_rounded,
                    onPressed: () => _onMapTypeButtonPressed(MapType.normal),
                    isSelected: _currentMapType == MapType.normal,
                  ),
                  const Divider(height: 1, thickness: 1),
                  _mapStyleSelectionButton(
                    icon: Icons.satellite_rounded,
                    onPressed: () => _onMapTypeButtonPressed(MapType.satellite),
                    isSelected: _currentMapType == MapType.satellite,
                  ),
                  const Divider(height: 1, thickness: 1),
                  _mapStyleSelectionButton(
                    icon: Icons.terrain_rounded,
                    onPressed: () => _onMapTypeButtonPressed(MapType.terrain),
                    isSelected: _currentMapType == MapType.terrain,
                  ),
                ],
              ),
            ),
          ),
          if (lat != null && lng != null)
            Container(
              margin: const EdgeInsets.only(bottom: 15),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: () async {
                    final coordinate = Coordinate(lat: lat!, lng: lng!);
                    final distance =
                        coordinate.calculateDistanceFromUniversity();

                    if (distance <= 0.1 || distance > 30) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please select a location within 1 km and 30 km of the university.',
                          ),
                        ),
                      );
                      return;
                    }

                    final Uint8List? snapshot = await _captureMapSnapshot();

                    if (context.mounted) {
                      context.pop({
                        'lat': lat,
                        'lng': lng,
                        'snap': snapshot,
                      });
                    }
                  },
                  child: const Text('Select this location'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Widget _mapStyleSelectionButton({
  required IconData icon,
  required VoidCallback onPressed,
  required bool isSelected,
}) {
  return InkWell(
    onTap: onPressed,
    child: Container(
      padding: const EdgeInsets.all(8),
      child: Icon(
        icon,
        size: 30,
        color: isSelected ? const Color(0xFF1E824C) : Colors.black54,
      ),
    ),
  );
}
