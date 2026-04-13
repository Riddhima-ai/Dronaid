import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  double lat = 12.9716;
  double lng = 77.5946;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Drone Tracker")),
      body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
      decoration: BoxDecoration(
      color:Colors.white,
      borderRadius:BorderRadius.circular(16),
      boxShadow: const[
      BoxShadow(
      color:Colors.black26,
      blurRadius:10,
      offset:Offset(0,4),
    ),
      ],
    ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(lat, lng),
            initialZoom: 15,
          ),
          children: [
            TileLayer(
              urlTemplate: "https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png",
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.example.dronaid',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(lat, lng),
                  child: const Icon(
                    Icons.airplanemode_active,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )
      )
    );
  }
}

//location visible