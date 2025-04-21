import 'package:flutter/material.dart';

class ChecklistPage extends StatefulWidget {
  final String detailType;
  final Function(Map<String, dynamic>) onComplete;

  const ChecklistPage({
    super.key,
    required this.detailType,
    required this.onComplete,
  });

  @override
  State<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  final Map<String, bool> _checklistItems = {
    'Lights': false,
    'Brakes': false,
    'Steering': false,
    'Tires': false,
    'Engine Oil': false,
    'Coolant': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.detailType} Checklist')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _checklistItems.length,
              itemBuilder: (context, index) {
                final key = _checklistItems.keys.elementAt(index);
                return CheckboxListTile(
                  title: Text(key),
                  value: _checklistItems[key],
                  onChanged: (value) => setState(() => _checklistItems[key] = value!),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => widget.onComplete(_checklistItems),
              child: const Text('Proceed to Details'),
            ),
          ),
        ],
      ),
    );
  }
}