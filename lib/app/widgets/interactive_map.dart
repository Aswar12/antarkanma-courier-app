import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:antarkanma_courier/theme.dart';
import 'dart:async';

import 'package:antarkanma_courier/app/data/models/transaction_model.dart';

class InteractiveMap extends StatefulWidget {
  final TransactionModel? transaction;
  final bool showRoute;
  final Function(LatLng)? onLocationUpdate;

  const InteractiveMap({
    super.key,
    this.transaction,
    this.showRoute = true,
    this.onLocationUpdate,
  });

  @override
  State<InteractiveMap> createState() => _InteractiveMapState();
}

class _InteractiveMapState extends State<InteractiveMap> {
  final MapController _mapController = MapController();
  LatLng _currentLocation = const LatLng(-6.2088, 106.8456); // Default: Jakarta
  bool _isLocationLoading = true;
  StreamSubscription<Position>? _positionStream;

  // Marker positions
  LatLng? _merchantLocation;
  LatLng? _customerLocation;

  @override
  void initState() {
    super.initState();
    _initializeMap();
    _startLocationUpdates();
  }

  Future<void> _initializeMap() async {
    try {
      // Get merchant and customer locations from transaction
      if (widget.transaction != null) {
        final merchantLat = widget.transaction?.baseMerchant?['latitude'];
        final merchantLng = widget.transaction?.baseMerchant?['longitude'];
        final customerLat = widget.transaction?.deliveryLocation?['latitude'];
        final customerLng = widget.transaction?.deliveryLocation?['longitude'];

        if (merchantLat != null &&
            merchantLng != null &&
            customerLat != null &&
            customerLng != null) {
          setState(() {
            _merchantLocation = LatLng(merchantLat, merchantLng);
            _customerLocation = LatLng(customerLat, customerLng);
          });

          // Center map between merchant and customer
          _centerMapOnRoute();
        }
      }

      // Get current location
      await _getCurrentLocation();
    } catch (e) {
      debugPrint('Error initializing map: $e');
      setState(() {
        _isLocationLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLocationLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLocationLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLocationLoading = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLocationLoading = false;
      });

      widget.onLocationUpdate?.call(_currentLocation);
    } catch (e) {
      debugPrint('Error getting current location: $e');
      setState(() {
        _isLocationLoading = false;
      });
    }
  }

  void _startLocationUpdates() {
    _positionStream = Geolocator.getPositionStream().listen((Position position) {
      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });
        widget.onLocationUpdate?.call(_currentLocation);
      }
    });
  }

  void _centerMapOnRoute() {
    if (_merchantLocation != null && _customerLocation != null) {
      // Calculate center point
      final centerLat = (_merchantLocation!.latitude + _customerLocation!.latitude) / 2;
      final centerLng = (_merchantLocation!.longitude + _customerLocation!.longitude) / 2;

      _mapController.move(LatLng(centerLat, centerLng), 13);
    } else if (_currentLocation != const LatLng(-6.2088, 106.8456)) {
      _mapController.move(_currentLocation, 15);
    }
  }

  void _zoomToLocation(LatLng location) {
    _mapController.move(location, 16);
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _currentLocation,
              zoom: 13,
              minZoom: 10,
              maxZoom: 18,
            ),
            children: [
              // Tile layer with OpenStreetMap
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.antarkanma.courier',
                maxZoom: 19,
                retinaMode: true,
              ),
              // Markers layer
              MarkerLayer(
                markers: _buildMarkers(),
              ),
              // Polyline for route (if transaction exists)
              if (widget.showRoute &&
                  _merchantLocation != null &&
                  _customerLocation != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [
                        _merchantLocation!,
                        _customerLocation!,
                      ],
                      color: logoColor.withOpacity(0.7),
                      strokeWidth: 4,
                    ),
                  ],
                ),
              // Current location circle
              if (!_isLocationLoading)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: _currentLocation,
                      radius: 8,
                      color: logoColor.withOpacity(0.3),
                      borderColor: logoColor,
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
            ],
          ),
          // Loading indicator
          if (_isLocationLoading)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          // Map controls
          Positioned(
            right: 8,
            bottom: 100,
            child: Column(
              children: [
                _buildMapControlButton(
                  icon: Icons.my_location,
                  onPressed: () => _zoomToLocation(_currentLocation),
                ),
                if (_merchantLocation != null)
                  _buildMapControlButton(
                    icon: Icons.store,
                    onPressed: () => _zoomToLocation(_merchantLocation!),
                  ),
                if (_customerLocation != null)
                  _buildMapControlButton(
                    icon: Icons.home,
                    onPressed: () => _zoomToLocation(_customerLocation!),
                  ),
              ],
            ),
          ),
          // Location info overlay
          Positioned(
            left: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.navigation,
                    color: logoColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Lokasi Anda',
                    style: primaryTextStyle.copyWith(
                      fontSize: 12,
                      fontWeight: bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    // Current location marker
    if (!_isLocationLoading) {
      markers.add(
        Marker(
          point: _currentLocation,
          width: 50,
          height: 50,
          builder: (_) {
            return _buildCurrentLocationMarker();
          },
        ),
      );
    }

    // Merchant marker
    if (_merchantLocation != null) {
      markers.add(
        Marker(
          point: _merchantLocation!,
          width: 50,
          height: 50,
          builder: (_) {
            return _buildMerchantMarker();
          },
        ),
      );
    }

    // Customer marker
    if (_customerLocation != null) {
      markers.add(
        Marker(
          point: _customerLocation!,
          width: 50,
          height: 50,
          builder: (_) {
            return _buildCustomerMarker();
          },
        ),
      );
    }

    return markers;
  }

  Widget _buildCurrentLocationMarker() {
    return Container(
      decoration: BoxDecoration(
        color: logoColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.navigation,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildMerchantMarker() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: const Icon(
        Icons.store,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildCustomerMarker() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: const Icon(
        Icons.home,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildMapControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              color: logoColor,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
