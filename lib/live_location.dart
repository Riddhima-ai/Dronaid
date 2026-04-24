import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref("telemetry");

  LatLng droneLocation = const LatLng(12.9716, 77.5946);

  double altitude = 0.0;

  final List<LatLng> _pathHistory = [];

  void _listenToRealtimeLocation() {
    _ref.onValue.listen((DatabaseEvent event) {
      if (event.snapshot.value == null) return;

      final data = event.snapshot.value as Map<dynamic, dynamic>;

      final double lat = (data['lat'] as num).toDouble();
      final double lng = (data['lon'] as num).toDouble();

      final double alt = (data['alt'] ?? 0) is num
          ? (data['alt'] as num).toDouble()
          : 0.0;

      if (lat == 0.0 && lng == 0.0) return;

      final LatLng newPoint = LatLng(lat, lng);

      setState(() {
        droneLocation = newPoint;
        altitude = alt;

        if (_pathHistory.isEmpty ||
            _pathHistory.last.latitude != lat ||
            _pathHistory.last.longitude != lng) {
          _pathHistory.add(newPoint);
        }

        if (_pathHistory.length > 500) {
          _pathHistory.removeAt(0);
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _listenToRealtimeLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Drone Tracker",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 41, 80, 172),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.45,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: droneLocation,
                    initialZoom: 15,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png",
                      subdomains: const ['a', 'b', 'c', 'd'],
                    ),

                    if (_pathHistory.length >= 2)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: List.from(_pathHistory),
                            color: Colors.blue,
                            strokeWidth: 3.5,
                          ),
                        ],
                      ),

                    MarkerLayer(
                      markers: [
                        Marker(
                          point: droneLocation,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.6),
                                  blurRadius: 12,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.navigation,
                              color: Colors.red,
                              size: 25,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 6),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Lat: ${droneLocation.latitude.toStringAsFixed(5)}",
                    style: const TextStyle(fontSize: 13),
                  ),
                  Text(
                    "Lng: ${droneLocation.longitude.toStringAsFixed(5)}",
                    style: const TextStyle(fontSize: 13),
                  ),
                  Text(
                    "Alt: ${altitude.toStringAsFixed(2)} m",
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
