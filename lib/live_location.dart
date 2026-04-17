import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:math' as Math;

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng? dronelocation;
  LatLng? startpoint;
  LatLng? endpoint;
  Timer? timer;
  final int totalSteps = 50;
  final Duration stepInterval = const Duration(seconds: 1);
  final double startLat = 12.9700;
  final double startLng = 77.5900;
  final double endLat = 12.9750;
  final double endLng = 77.6000;
  double lat = 12.9716;
  double lng = 77.5946;
  double getAngle(LatLng start, LatLng end) {
    double lat1 = start.latitude * Math.pi / 180;
    double lat2 = end.latitude * Math.pi / 180;
    double dLon = (end.longitude - start.longitude) * Math.pi / 180;

    double y = Math.sin(dLon) * Math.cos(lat2);
    double x =
        Math.cos(lat1) * Math.sin(lat2) -
        Math.sin(lat1) * Math.cos(lat2) * Math.cos(dLon);

    return Math.atan2(y, x);
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

                Navigator.pop(context);
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  void simulateMovement() {
    int currentStep = 0;

    timer = Timer.periodic(Duration(milliseconds: 500), (t) {
      if (currentStep > totalSteps) {
        t.cancel();
        print("Reached destination");
        return;
      }
      double progress = currentStep / totalSteps;
      double lat = startLat + (endLat - startLat) * progress;
      double lng = startLng + (endLng - startLng) * progress;
      FirebaseFirestore.instance.collection("drone_data").doc("route").update({
        'currentLat': lat,
        'currentLng': lng,
      });
      currentStep++;

      if (currentStep >= totalSteps) {
        t.cancel();
        print("Reached destination");
      }
    });
  }

  Future<void> createInitialData() async {
    final docref = FirebaseFirestore.instance
        .collection("drone_data")
        .doc("route");
    final doc = await docref.get();
    if (!doc.exists) {
      await docref.set({
        'currentLat': 12.9700,
        'currentLng': 77.5900,
        'startLat': 12.9700,
        'startLng': 77.5900,
        'endLat': 12.9750,
        'endLng': 77.6000,
      });
    }
  }

  @override
  void initState() {
    super.initState();
    createInitialData();
    simulateMovement();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Drone Tracker"),
        backgroundColor: const Color.fromARGB(255, 157, 170, 193),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("drone_data")
            .doc("route")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          LatLng dronelocation = LatLng(
            (data['currentLat'] ?? 0).toDouble(),
            (data['currentLng'] ?? 0).toDouble(),
          );
          LatLng startPoint = LatLng(
            (data['startLat'] ?? 0).toDouble(),
            (data['startLng'] ?? 0).toDouble(),
          );

          LatLng endPoint = LatLng(
            (data['endLat'] ?? 0).toDouble(),
            (data['endLng'] ?? 0).toDouble(),
          );
          double angle = getAngle(dronelocation, endPoint);

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
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: dronelocation,
                              child: Transform.rotate(
                                angle: angle,
                                child: const Icon(
                                  Icons.navigation,
                                  color: Colors.red,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: startPoint,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color:Color.fromRGBO(120, 180, 220, 0.73), 

                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  color: Color.fromRGBO(80, 155, 220, 1.0),
                                  size: 20,
                                ),
                              ),
                            ),
                            Marker(
                              point: endPoint,
                              child: const Icon(
                                Icons.flag,
                                color: Colors.blue,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: [startPoint, endPoint],
                              color: Colors.blue,
                              strokeWidth: 2,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // BUTTON
                ElevatedButton(
                  onPressed: () {
                    showLatLngDialog(context);
                  },
                  child: const Text("Enter New Coordinates"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
