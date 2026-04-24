import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math' as Math;
import 'firebase_service.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  
   final MapController _mapController = MapController();
  final dbref = FirebaseDatabase.instance.ref("telemetry");

  List<LatLng> pathPoints = [];

  
  List<LatLng> genertedots(LatLng start, LatLng end, int segments) {
    List<LatLng> points = [];
    for (int i = 0; i <= segments; i++) {
      double t = i / segments;
      double lat = start.latitude + (end.latitude - start.latitude) * t;
      double lng = start.longitude + (end.longitude - start.longitude) * t;
      points.add(LatLng(lat, lng));
    }
    return points;
  }

  void showLatLngDialog(BuildContext context) {
    TextEditingController latController = TextEditingController();
    TextEditingController lngController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter Coordinates"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: latController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Latitude"),
              ),
              TextField(
                controller: lngController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Longitude"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                double lat = double.parse(latController.text);
                double lng = double.parse(lngController.text);
                await FirebaseService.addTargetPoint(lat, lng);
                Navigator.pop(context);
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Drone Tracker",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 18, 37, 83),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: dbref.onValue,
        builder: (context, snapshot) {
          print(snapshot.data?.snapshot.value);
          final raw = snapshot.data?.snapshot.value;
final data = raw is Map ? Map<String, dynamic>.from(raw) : null;
double altitude = double.tryParse(
  data?['alt_ft']?.toString() ?? "0"
) ?? 0;
double latitude = (data?['lat'] ?? 0).toDouble();
double longitude = (data?['lng'] ?? 0).toDouble();
          LatLng droneLocation = LatLng(
            (data?['lat'] ?? 0).toDouble(),
            (data?['lng'] ?? 0).toDouble(),
          );
          double heading = double.tryParse(
  data?['heading']?.toString() ?? "0"
) ?? 0;
double headingRad = heading * (Math.pi / 180);
          WidgetsBinding.instance.addPostFrameCallback((_) {
  _mapController.move(droneLocation, 15);
});

          if (latitude != 0 && longitude != 0) {

  if (pathPoints.isEmpty) {
    // first valid point → start here
    pathPoints.add(droneLocation);

  } else if (
    pathPoints.last.latitude != droneLocation.latitude ||
    pathPoints.last.longitude != droneLocation.longitude
  ) {
    pathPoints.add(droneLocation);
  }
}
          LatLng startPoint =
              pathPoints.isNotEmpty ? pathPoints.first : droneLocation;

          return Padding(
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
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: startPoint,
                        initialZoom: 15,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              "https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png",
                          subdomains: const ['a', 'b', 'c', 'd'],
                        ),
                        if (pathPoints.length > 1)
  PolylineLayer(
    polylines: [
      Polyline(
        points: pathPoints,
        strokeWidth: 4,
        color: Colors.blue,
      ),
    ],
  ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: droneLocation,
                              
                              child: Transform.rotate(
                                angle: headingRad,
                                child: const Icon(
                                  Icons.navigation,
                                  
                                  color: Colors.red,
                                  size: 30,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        
                      ],
                    ),
                  ),
                ),SizedBox(height: 12),

Container(
  padding: EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 6,
        offset: Offset(0, 3),
      ),
    ],
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        "Latitude",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      Text(
        latitude.toStringAsFixed(7),
        style: TextStyle(fontSize: 16),
      ),
    ],
  ),
),

SizedBox(height: 12),

Container(
  padding: EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 6,
        offset: Offset(0, 3),
      ),
    ],
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        "Longitude",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      Text(
        longitude.toStringAsFixed(7),
        style: TextStyle(fontSize: 16),
      ),
    ],
  ),
),
                SizedBox(height: 16),

Container(
  padding: EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 6,
        offset: Offset(0, 3),
      ),
    ],
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        "Altitude",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      Text(
        "${altitude.toStringAsFixed(2)} ft",
        style: TextStyle(fontSize: 16),
      ),
    ],
  ),
),
              ],
            ),
          );
        },
      ),
    );
  }
}