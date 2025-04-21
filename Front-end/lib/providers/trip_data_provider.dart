import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TripData extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Driver and session data
  String? _uniqueId;
  String? _driverName;
  String? _loginDate;

  // Bus and route data
  Map<String, dynamic> _currentBus = {};
  Map<String, dynamic>? _currentRoute;

  // Temporary form data storage
  Map<String, dynamic> _checklistData = {};
  Map<String, dynamic> _sourceDetails = {};
  Map<String, dynamic> _destinationDetails = {};
  Map<String, dynamic> _fuelDetails = {};
  Map<String, dynamic> _serviceDetails = {};

  // Getters
  String? get uniqueId => _uniqueId;
  String? get driverName => _driverName;
  String? get loginDate => _loginDate;
  Map<String, dynamic> get currentBus => _currentBus;
  Map<String, dynamic>? get currentRoute => _currentRoute;
  Map<String, dynamic> get checklistData => _checklistData;
  Map<String, dynamic> get sourceDetails => _sourceDetails;
  Map<String, dynamic> get destinationDetails => _destinationDetails;
  Map<String, dynamic> get fuelDetails => _fuelDetails;
  Map<String, dynamic> get serviceDetails => _serviceDetails;

  // Initialize session
  void initializeSession({
    required String uniqueId,
    required String driverName,
  }) {
    _uniqueId = uniqueId;
    _driverName = driverName;
    _loginDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    notifyListeners();
  }

  // Bus selection with route fetch - UPDATED TO FIX ROUTE FETCHING
  Future<void> setCurrentBus(Map<String, dynamic> busData) async {
    try {
      _currentBus = {
        'Bus_Number': busData['Bus_Number'],
        'FC_Number': busData['FC_Number'],
        'TN_Number': busData['TN_Number'],
      };
      
      // Fetch route directly from ROUTE collection
      final querySnapshot = await _firestore
          .collection('ROUTE')
          .where('bus', isEqualTo: _currentBus['Bus_Number'])
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        _currentRoute = querySnapshot.docs.first.data();
        debugPrint('Successfully fetched route: $_currentRoute');
      } else {
        _currentRoute = null;
        debugPrint('No route found for bus ${_currentBus['Bus_Number']}');
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting current bus: $e');
      _currentRoute = null;
      notifyListeners();
      rethrow;
    }
  }

  // Checklist handling
  void setChecklistData(Map<String, dynamic> data) {
    _checklistData = Map.from(data);
    notifyListeners();
  }

  // Source Details
  Future<void> submitSourceDetails(Map<String, dynamic> data) async {
    try {
      _sourceDetails = {
        'start_km': data['start_km'],
        'location': data['location'],
        'route': _currentRoute?['route'] ?? 'Not specified',
        'bus_number': _currentBus['Bus_Number'],
        'route_time': _currentRoute?['time'] ?? 'N/A',
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('trips').doc(_loginDate).set({
        'driver': {
          'unique_id': _uniqueId,
          'name': _driverName,
        },
        'bus': _currentBus,
        'source': _sourceDetails,
        'checklist': _checklistData,
        'status': 'in_progress',
        'created_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _checklistData = {};
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving source details: $e');
      rethrow;
    }
  }

  // Destination Details
  Future<void> submitDestinationDetails(Map<String, dynamic> data) async {
    try {
      _destinationDetails = {
        'end_km': data['end_km'],
        'location': data['location'],
        'arrival_time': data['arrival_time'],
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('trips').doc(_loginDate).set({
        'destination': _destinationDetails,
        'status': 'completed',
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      notifyListeners();
    } catch (e) {
      debugPrint('Error saving destination details: $e');
      rethrow;
    }
  }

  // Fuel Details
  Future<void> submitFuelDetails(Map<String, dynamic> data) async {
    try {
      _fuelDetails = {
        'quantity': data['quantity'],
        'amount': data['amount'],
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('trips').doc(_loginDate).set({
        'fuel': _fuelDetails,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      notifyListeners();
    } catch (e) {
      debugPrint('Error saving fuel details: $e');
      rethrow;
    }
  }

  // Service Details
  Future<void> submitServiceDetails(Map<String, dynamic> data) async {
    try {
      _serviceDetails = {
        'type': data['type'],
        'cost': data['cost'],
        'notes': data['notes'] ?? '',
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('trips').doc(_loginDate).set({
        'service': _serviceDetails,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      notifyListeners();
    } catch (e) {
      debugPrint('Error saving service details: $e');
      rethrow;
    }
  }

  // Clear session
  void clearSession() {
    _uniqueId = null;
    _driverName = null;
    _loginDate = null;
    _currentBus = {};
    _currentRoute = null;
    _checklistData = {};
    _sourceDetails = {};
    _destinationDetails = {};
    _fuelDetails = {};
    _serviceDetails = {};
    notifyListeners();
  }
}