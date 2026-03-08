import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:antarkanma_courier/theme.dart';
import 'package:antarkanma_courier/app/data/models/transaction_model.dart';
import 'dart:async';

class MapViewPage extends StatefulWidget {
  final TransactionModel transaction;

  const MapViewPage({super.key, required this.transaction});

  @override
  State<MapViewPage> createState() => _MapViewPageState();
}

class _MapViewPageState extends State<MapViewPage> {
  final MapController _mapController = MapController();
  LatLng _currentLocation = const LatLng(-6.2088, 106.8456);
  LatLng? _merchantLocation;
  LatLng? _customerLocation;
  bool _isLocationLoading = true;
  StreamSubscription<Position>? _positionStream;
  bool _showTraffic = false;

  @override
  void initState() {
    super.initState();
    _initializeLocations();
    _startLocationUpdates();
  }

  void _initializeLocations() {
    try {
      final merchantLat = widget.transaction.baseMerchant?['latitude'];
      final merchantLng = widget.transaction.baseMerchant?['longitude'];
      final customerLat = widget.transaction.deliveryLocation?['latitude'];
      final customerLng = widget.transaction.deliveryLocation?['longitude'];

      if (merchantLat != null &&
          merchantLng != null &&
          customerLat != null &&
          customerLng != null) {
        setState(() {
          _merchantLocation = LatLng(merchantLat, merchantLng);
          _customerLocation = LatLng(customerLat, customerLng);
        });

        // Center map to show all markers
        _fitAllMarkers();
      }

      _getCurrentLocation();
    } catch (e) {
      debugPrint('Error initializing locations: $e');
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
      }
    });
  }

  void _fitAllMarkers() {
    if (_merchantLocation != null &&
        _customerLocation != null &&
        !_isLocationLoading) {
      final bounds = LatLngBounds.fromPoints([
        _merchantLocation!,
        _customerLocation!,
        _currentLocation,
      ]);
      _mapController.fitBounds(bounds);
    }
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String merchantName =
        widget.transaction.baseMerchant?['name'] ?? 'Merchant';
    String customerAddress =
        widget.transaction.deliveryLocation?['address'] ?? 'Customer';

    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _currentLocation,
              zoom: 12,
              minZoom: 10,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate: _showTraffic
                    ? 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
                    : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.antarkanma.courier',
                maxZoom: 19,
                retinaMode: true,
              ),
              MarkerLayer(
                markers: _buildMarkers(),
              ),
              if (_merchantLocation != null && _customerLocation != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [
                        _merchantLocation!,
                        _customerLocation!,
                      ],
                      color: logoColor.withOpacity(0.7),
                      strokeWidth: 5,
                    ),
                  ],
                ),
              if (!_isLocationLoading)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: _currentLocation,
                      radius: 10,
                      color: logoColor.withOpacity(0.3),
                      borderColor: logoColor,
                      borderStrokeWidth: 3,
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
          // App bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                right: 16,
                bottom: 8,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 28,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Peta Pengantaran',
                          style: primaryTextStyle.copyWith(
                            fontSize: 18,
                            fontWeight: bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '#ANT-${widget.transaction.id}',
                          style: primaryTextStyle.copyWith(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _showTraffic = !_showTraffic;
                      });
                    },
                    icon: Icon(
                      _showTraffic ? Icons.traffic : Icons.map,
                      color: Colors.white,
                      size: 24,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom info panel
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildLocationInfo(
                          icon: Icons.store,
                          color: Colors.orange,
                          title: 'Pick-up',
                          subtitle: merchantName,
                          isLast: false,
                        ),
                        const SizedBox(height: 16),
                        _buildLocationInfo(
                          icon: Icons.home,
                          color: Colors.green,
                          title: 'Drop-off',
                          subtitle: customerAddress,
                          isLast: true,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // Navigate to merchant
                                  if (_merchantLocation != null) {
                                    _mapController.move(
                                        _merchantLocation!, 16);
                                  }
                                },
                                icon: const Icon(Icons.store),
                                label: const Text('Lihat Merchant'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // Navigate to customer
                                  if (_customerLocation != null) {
                                    _mapController.move(
                                        _customerLocation!, 16);
                                  }
                                },
                                icon: const Icon(Icons.navigation),
                                label: const Text('Lihat Tujuan'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: logoColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Map controls
          Positioned(
            right: 16,
            bottom: 280,
            child: Column(
              children: [
                _buildMapControlButton(
                  icon: Icons.my_location,
                  onPressed: () => _mapController.move(_currentLocation, 16),
                ),
                _buildMapControlButton(
                  icon: Icons.filter_center_focus,
                  onPressed: _fitAllMarkers,
                ),
              ],
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
          width: 60,
          height: 60,
          builder: (_) {
            return Container(
              decoration: BoxDecoration(
                color: logoColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.navigation,
                color: Colors.white,
                size: 30,
              ),
            );
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
            return Container(
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.store,
                color: Colors.white,
                size: 24,
              ),
            );
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
            return Container(
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.home,
                color: Colors.white,
                size: 24,
              ),
            );
          },
        ),
      );
    }

    return markers;
  }

  Widget _buildLocationInfo({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool isLast,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: secondaryTextStyle.copyWith(
                  fontSize: 10,
                  fontWeight: bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: primaryTextStyle.copyWith(
                  fontSize: 14,
                  fontWeight: medium,
                  color: const Color(0xFF000040),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (!isLast)
          Container(
            width: 2,
            height: 40,
            margin: const EdgeInsets.only(left: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
      ],
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
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(
              icon,
              color: logoColor,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
