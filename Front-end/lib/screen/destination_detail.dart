import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/trip_data_provider.dart';
//import 'package:intl/intl.dart';

class DestinationDetailsPage extends StatefulWidget {
  final Future<void> Function(Map<String, dynamic>) onSubmitted;

  const DestinationDetailsPage({
    super.key, 
    required this.onSubmitted,
  });

  @override
  State<DestinationDetailsPage> createState() => _DestinationDetailsPageState();
}

class _DestinationDetailsPageState extends State<DestinationDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _arrivalController = TextEditingController();
  final _endKmController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _selectArrivalTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null && mounted) {
      setState(() {
        _arrivalController.text = pickedTime.format(context);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    
    try {
      await widget.onSubmitted({
        'end_km': _endKmController.text,
        'location': _locationController.text,
        'arrival_time': _arrivalController.text,
      });
      
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripData = Provider.of<TripData>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Destination - ${tripData.currentBus['Bus_Number']}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _arrivalController,
                readOnly: true,
                onTap: _selectArrivalTime,
                decoration: InputDecoration(
                  labelText: 'Arrival Time',
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(Icons.access_time, color: theme.primaryColor),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.schedule),
                    onPressed: _selectArrivalTime,
                  ),
                ),
                validator: (value) => 
                    value?.isEmpty ?? true ? 'Required field' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _endKmController,
                decoration: InputDecoration(
                  labelText: 'End Odometer (KM)',
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(Icons.speed, color: theme.primaryColor),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Required field';
                  final km = double.tryParse(value!);
                  if (km == null) return 'Enter valid number';
                  if (km <= 0) return 'Must be greater than 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on, color: theme.primaryColor),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
                validator: (value) => 
                    value?.isEmpty ?? true ? 'Required field' : null,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'SUBMIT DESTINATION',
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
    _arrivalController.dispose();
    _endKmController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}