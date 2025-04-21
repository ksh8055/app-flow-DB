import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/trip_data_provider.dart';

class SourceDetailsPage extends StatefulWidget {
  const SourceDetailsPage({
    super.key,
    required this.onSubmitted,
  });

  final Future<void> Function(Map<String, dynamic>) onSubmitted;

  @override
  State<SourceDetailsPage> createState() => _SourceDetailsPageState();
}

class _SourceDetailsPageState extends State<SourceDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _startingKmController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isSubmitting = false;
  late String _currentDateTime;

  @override
  void initState() {
    super.initState();
    _currentDateTime = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    _logRouteData();
  }

  void _logRouteData() {
    final tripData = Provider.of<TripData>(context, listen: false);
    debugPrint('Current Bus: ${tripData.currentBus}');
    debugPrint('Current Route: ${tripData.currentRoute}');
  }

  Future<void> _submitForm(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    
    try {
      await widget.onSubmitted({
        'start_km': _startingKmController.text,
        'location': _locationController.text,
      });
      
      if (mounted) Navigator.pop(context);
    } on FirebaseException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_getFirestoreError(e))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _getFirestoreError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'Permission denied. Please check your access rights.';
      case 'unavailable':
        return 'Network unavailable. Please check your connection.';
      default:
        return 'Failed to save source details: ${e.message}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripData = Provider.of<TripData>(context);
    final theme = Theme.of(context);
    final route = tripData.currentRoute;

    return Scaffold(
      appBar: AppBar(
        title: Text('Source Details - ${tripData.currentBus['Bus_Number']}'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Date and Time Display
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, size: 20),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Date & Time',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.hintColor,
                            ),
                          ),
                          Text(
                            _currentDateTime,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Route Information Display - UPDATED TO SHOW ROUTE PROPERLY
              if (route != null)
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ASSIGNED ROUTE',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Route No: ${route['no'] ?? 'N/A'}',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          route['route'] ?? 'No route assigned',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Departure Time: ${route['time'] ?? 'N/A'}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                )
              else
                Card(
                  color: Colors.amber[100],
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'No route information available for this bus',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.orange[800],
                      ),
                    ),
                  ),
                ),

              // Starting KM Field
              TextFormField(
                controller: _startingKmController,
                decoration: const InputDecoration(
                  labelText: 'Starting Odometer (KM)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.speed),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Required field';
                  if (double.tryParse(value!) == null) return 'Enter valid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Location Field
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Required field' : null,
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isSubmitting ? null : () => _submitForm(context),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'SUBMIT SOURCE DETAILS',
                          style: TextStyle(fontSize: 16),
                        ),
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
    _startingKmController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}