import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add new coordinate without affecting route
  static Future<void> addTargetPoint(double lat, double lng) async {
   await _db.collection("target_points").doc("current").set({
  'lat': lat,
  'lng': lng,
  'timestamp': FieldValue.serverTimestamp(),
});
  }
}