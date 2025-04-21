import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/trip_data_provider.dart';
import 'package:intl/intl.dart';

class ServiceDetailsPage extends StatefulWidget {
  const ServiceDetailsPage({
    super.key, 
    required this.onSubmitted,
  });

  final Future<void> Function(Map<String, dynamic>) onSubmitted;

  @override
  State<ServiceDetailsPage> createState() => _ServiceDetailsPageState();
}

class _ServiceDetailsPageState extends State<ServiceDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _serviceTypeController = TextEditingController();
  final _costController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSubmitting = false;
  late String _currentDateTime;

  @override
  void initState() {
    super.initState();
    _currentDateTime = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    
    try {
      await widget.onSubmitted({
        'type': _serviceTypeController.text,
        'cost': _costController.text,
        'notes': _notesController.text,
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
        title: Text('Service Details - ${tripData.currentBus['Bus_Number']}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
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

              TextFormField(
                controller: _serviceTypeController,
                decoration: const InputDecoration(
                  labelText: 'Service Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.build),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _costController,
                decoration: const InputDecoration(
                  labelText: 'Cost',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Required';
                  if (double.tryParse(value!) == null) return 'Enter valid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                child: _isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text('SUBMIT SERVICE DETAILS'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _serviceTypeController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}