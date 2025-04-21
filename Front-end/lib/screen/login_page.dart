import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bcrypt/bcrypt.dart';
import '../providers/trip_data_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _uniqueIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _authenticate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Query Firestore for driver
      final querySnapshot = await _firestore
          .collection('Register')
          .where('UniqueID', isEqualTo: _uniqueIdController.text.trim())
          .limit(1)
          .get(const GetOptions(source: Source.server));

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Driver not registered / ஓட்டுனர் பதிவு செய்யப்படவில்லை');
      }

      // 2. Verify password
      final driverDoc = querySnapshot.docs.first;
      final storedHash = driverDoc['Password'] as String;
      final passwordMatch = BCrypt.checkpw(
        _passwordController.text.trim(),
        storedHash,
      );

      if (!passwordMatch) {
        throw Exception('Invalid credentials / தவறான உள்நுழைவு தகவல்கள்');
      }

      // 3. Store ONLY in memory (no DB writes)
      Provider.of<TripData>(context, listen: false).initializeSession(
        uniqueId: driverDoc['UniqueID'],
        driverName: driverDoc['Name'],
      );

      // 4. Navigate to bus selection
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/selectBus',
          (route) => false,
        );
      }
    } on FirebaseException catch (e) {
      setState(() => _errorMessage = 'Database error: ${e.code}');
    } catch (e) {
      setState(() => _errorMessage = _getFriendlyError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getFriendlyError(dynamic error) {
    final message = error.toString();
    if (message.contains('not registered')) return 'Driver not found / ஓட்டுனர் கணக்கு கிடைக்கவில்லை';
    if (message.contains('Invalid credentials')) return 'Wrong ID or password / தவறான ஐடி அல்லது கடவுச்சொல்';
    return 'Login failed. Please try again. /  உள்நுழைவு தோல்வியடைந்தது. தயவுசெய்து மீண்டும் முயற்சிக்கவும்.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Driver Login / ஓட்டுனர் உள்நுழைவு ',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _uniqueIdController,
                      decoration: const InputDecoration(
                        labelText: 'Unique ID / யுனிக் ஐடி',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password / கடவுச்சொல்',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required' : null,
                    ),
                  ],
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red[700]),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _authenticate,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('LOGIN / உள்நுழைவு'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _uniqueIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}