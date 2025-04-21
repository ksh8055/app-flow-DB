import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/trip_data_provider.dart';

class SelectBusPage extends StatefulWidget {
  const SelectBusPage({super.key});

  @override
  State<SelectBusPage> createState() => _SelectBusPageState();
}

class _SelectBusPageState extends State<SelectBusPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  String? _errorMessage;
  String _sortBy = 'Bus_Number'; // Default sort field
  bool _sortAscending = true; // Default sort order

  @override
  void initState() {
    super.initState();
    _loadBuses();
  }

  Future<void> _loadBuses() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load buses: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Vehicle'),
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                if (value == _sortBy) {
                  _sortAscending = !_sortAscending;
                } else {
                  _sortBy = value;
                  _sortAscending = true;
                }
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Bus_Number',
                child: Text('Sort by Bus Number'),
              ),
              const PopupMenuItem(
                value: 'FC_Number',
                child: Text('Sort by FC Number'),
              ),
              const PopupMenuItem(
                value: 'TN_Number',
                child: Text('Sort by TN Number'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('BusDetails').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Sort the buses
                    final buses = snapshot.data!.docs
                        .map((doc) => doc.data() as Map<String, dynamic>)
                        .toList()
                      ..sort((a, b) {
                        final aValue = a[_sortBy]?.toString() ?? '';
                        final bValue = b[_sortBy]?.toString() ?? '';
                        return _sortAscending
                            ? aValue.compareTo(bValue)
                            : bValue.compareTo(aValue);
                      });

                    return ListView.builder(
                      itemCount: buses.length,
                      itemBuilder: (context, index) {
                        final bus = buses[index];
                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: ListTile(
                            leading: const Icon(Icons.directions_bus),
                            title: Text(bus['Bus_Number'] ?? 'Unknown Bus'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('FC number: ${bus['FC_Number'] ?? 'N/A'}'),
                                Text('TN number: ${bus['TN_Number'] ?? 'N/A'}'),
                                
                              ],
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _navigateToDetail(context, bus),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }

  void _navigateToDetail(BuildContext context, Map<String, dynamic> bus) {
    Provider.of<TripData>(context, listen: false).setCurrentBus(bus);
    Navigator.pushNamed(context, '/detail');
  }
}