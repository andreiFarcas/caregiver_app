import 'package:flutter/material.dart';
import '../../../../core/models/bracelet_model.dart';
import '../../../bracelet_details/presentation/screens/bracelet_details_screen.dart';

class PatientBraceletCard extends StatelessWidget {
  final BraceletModel bracelet;
  final VoidCallback? onReturn;

  const PatientBraceletCard({
    super.key,
    required this.bracelet,
    this.onReturn,
  });

   @override
  Widget build(BuildContext context) {
    // Generate color and state based on status
    final statusLower = bracelet.status.toLowerCase();
    Color statusColor;
    bool isEmergency = false;

    if (statusLower == 'home' || statusLower == 'ok') {
      statusColor = Colors.green;
    } else if (statusLower == 'away') {
      statusColor = Colors.amber; 
    } else if (statusLower == 'fall' || statusLower == 'panic') {
      statusColor = Colors.red;
      isEmergency = true;
    } else {
      statusColor = Colors.grey;
    }

    return Card(
      // Color the whole card if it's an emergency
      color: isEmergency ? Colors.red.shade50 : null,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navigate to details screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BraceletDetailsScreen(bracelet: bracelet),
            ),
          ).then((_) {
            // When returning from the details screen (e.g. after deletion), trigger a refresh
            if (onReturn != null) {
              onReturn!();
            }
          });
        },
        borderRadius: BorderRadius.circular(12),

        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    bracelet.patientName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      bracelet.status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Bracelet ID: ${bracelet.id}',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.blueGrey, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        '${bracelet.lastLocation.latitude.toStringAsFixed(3)}, ${bracelet.lastLocation.longitude.toStringAsFixed(3)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        bracelet.batteryPercent > 20 ? Icons.battery_full : Icons.battery_alert,
                        color: bracelet.batteryPercent > 20 ? Colors.green : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${bracelet.batteryPercent}%',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
