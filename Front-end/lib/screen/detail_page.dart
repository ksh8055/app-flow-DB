import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/trip_data_provider.dart';
import 'source_detail.dart';
import 'destination_detail.dart';
import 'fuel_details.dart';
import 'service_detail_page.dart';
import 'checklist_page.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tripData = Provider.of<TripData>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Bus ${tripData.currentBus['Bus_Number']}'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDetailButton(
                  context: context,
                  title: 'Source Details',
                  needsChecklist: tripData.sourceDetails.isEmpty,
                  detailType: 'source',
                  page: SourceDetailsPage(
                    onSubmitted: (data) async {
                      await tripData.submitSourceDetails(data);
                    },
                  ),
                ),
                _buildDetailButton(
                  context: context,
                  title: 'Destination Details',
                  needsChecklist: tripData.destinationDetails.isEmpty && 
                                tripData.sourceDetails.isNotEmpty,
                  detailType: 'destination',
                  page: DestinationDetailsPage(
                    onSubmitted: (data) async {
                      await tripData.submitDestinationDetails(data);
                    },
                  ),
                ),
                _buildDetailButton(
                  context: context,
                  title: 'Fuel Details',
                  needsChecklist: false,
                  detailType: 'fuel',
                  page: FuelDetailsPage(
                    onSubmitted: (data) async {
                      await tripData.submitFuelDetails(data);
                    },
                  ),
                ),
                _buildDetailButton(
                  context: context,
                  title: 'Service Details',
                  needsChecklist: false,
                  detailType: 'service',
                  page: ServiceDetailsPage(
                    onSubmitted: (data) async {
                      await tripData.submitServiceDetails(data);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailButton({
    required BuildContext context,
    required String title,
    required bool needsChecklist,
    required String detailType,
    required Widget page,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () => _navigateToDetail(
            context,
            needsChecklist,
            detailType,
            page,
          ),
          child: Text(title),
        ),
      ),
    );
  }

  void _navigateToDetail(
    BuildContext context,
    bool needsChecklist,
    String detailType,
    Widget detailsPage,
  ) {
    if (needsChecklist) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChecklistPage(
            detailType: detailType,
            onComplete: (checklist) {
              Provider.of<TripData>(context, listen: false)
                  .setChecklistData(checklist);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => detailsPage),
              );
            },
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => detailsPage),
      );
    }
  }
}