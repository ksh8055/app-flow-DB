import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveCompleteTrip({
    required String uniqueId,
    required String busNumber,
    required String tnNumber,
    required Map<String, bool> checklist,
    required Map<String, dynamic> source,
    required Map<String, dynamic> destination,
    required Map<String, dynamic> fuel,
    required Map<String, dynamic> service,
  }) async {
    try {
      print('📦 Attempting to save data...');
      
      final dateKey = DateFormat('dd-MM-yyyy').format(DateTime.now());
      final docRef = _firestore.collection('details').doc(dateKey);

      final tripData = {
        'unique_id': uniqueId,
        'bus_number': busNumber,
        'tn_number': tnNumber,
        'timestamp': FieldValue.serverTimestamp(),
        'checklist': checklist,
        'source': {
          'start_distance': source['start_km']?.toString() ?? '',
          'time_date': FieldValue.serverTimestamp(),
          'location': source['location']?.toString() ?? '',
          'route': source['route']?.toString() ?? '',
        },
        'destination': {
          'end_distance': destination['end_km']?.toString() ?? '',
          'time_date': FieldValue.serverTimestamp(),
          'location': destination['location']?.toString() ?? '',
          'route': destination['route']?.toString() ?? '',
        },
        'fuel': {
          'quantity': fuel['quantity']?.toString() ?? '',
          'amount': fuel['amount']?.toString() ?? '',
          'time_date': FieldValue.serverTimestamp(),
          'distance': fuel['distance']?.toString() ?? '',
        },
        'service': {
          'type': service['type']?.toString() ?? '',
          'amount': service['amount']?.toString() ?? '',
          'time_date': FieldValue.serverTimestamp(),
        },
      };

      print('💾 Saving to: details/$dateKey');
      print('📄 Data: $tripData');
      
      await docRef.set(tripData, SetOptions(merge: true));
      print('✅ Successfully saved!');
    } catch (e) {
      print('❌ Error saving to Firestore: $e');
      rethrow;
    }
  }

  String generateUniqueId() => DateTime.now().millisecondsSinceEpoch.toString();
}