import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/trip_data_provider.dart';
import 'package:intl/intl.dart';

class FuelDetailsPage extends StatefulWidget {
  final Future<void> Function(Map<String, dynamic>) onSubmitted;

  const FuelDetailsPage({
    super.key, 
    required this.onSubmitted,
  });

  @override
  State<FuelDetailsPage> createState() => _FuelDetailsPageState();
}

class _FuelDetailsPageState extends State<FuelDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _amountController = TextEditingController();
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
        'quantity': _quantityController.text,
        'amount': _amountController.text,
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
        title: Text('Fuel Details - ${tripData.currentBus['Bus_Number']}'),
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
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Quantity (Liters)',
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_gas_station, color: theme.primaryColor),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Required field';
                  final quantity = double.tryParse(value!);
                  if (quantity == null) return 'Enter valid number';
                  if (quantity <= 0) return 'Must be greater than 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money, color: theme.primaryColor),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Required field';
                  final amount = double.tryParse(value!);
                  if (amount == null) return 'Enter valid number';
                  if (amount <= 0) return 'Must be greater than 0';
                  return null;
                },
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
                          'SUBMIT FUEL DETAILS',
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
    _quantityController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}