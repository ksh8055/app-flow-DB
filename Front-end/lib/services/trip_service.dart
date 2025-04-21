import 'package:cloud_firestore/cloud_firestore.dart';

class TripService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Submit complete trip data
  static Future<void> submitCompleteTrip({
    required String uniqueId,
    required String date,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore
          .collection('driver_trips')
          .doc(uniqueId)
          .collection(date)
          .doc('trip_record')
          .set(data, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to submit trip: $e');
    }
  }

  // Fetch available buses
  static Stream<QuerySnapshot> getAvailableBuses() {
    return _firestore
        .collection('fleet_buses')
        .where('status', isEqualTo: 'active')
        .orderBy('bus_number')
        .snapshots();
  }

  // Get driver profile
  static Future<DocumentSnapshot> getDriverProfile(String uniqueId) async {
    return await _firestore
        .collection('drivers')
        .doc(uniqueId)
        .get();
  }
}