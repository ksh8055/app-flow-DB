import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> loginDriver(String uniqueId, String password) async {
    try {
      // First check in Firestore
      final driverDoc = await _firestore.collection('drivers').doc(uniqueId).get();
      
      if (!driverDoc.exists) {
        throw FirebaseAuthException(
          code: 'driver-not-found',
          message: 'Driver not registered',
        );
      }

      // Then authenticate with Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: driverDoc.data()!['email'],
        password: password,
      );

      return {
        'uniqueId': uniqueId,
        'name': driverDoc.data()!['name'],
        'email': userCredential.user!.email,
      };
    } on FirebaseAuthException catch (e) {
      throw _convertAuthError(e);
    } on FirebaseException catch (e) {
      throw Exception('Firestore error: ${e.message}');
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  FirebaseAuthException _convertAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return FirebaseAuthException(
          code: 'invalid-credentials',
          message: 'Invalid driver ID or password',
        );
      case 'wrong-password':
        return FirebaseAuthException(
          code: 'invalid-credentials',
          message: 'Invalid driver ID or password',
        );
      default:
        return e;
    }
  }
}