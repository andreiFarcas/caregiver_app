import 'package:flutter/material.dart';
import '../../../../core/utils/date_formatter.dart';

class EventHistoryList extends StatelessWidget {
  final List<Map<String, dynamic>> events;

  const EventHistoryList({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            'No recent alerts or events.',
            style: TextStyle(fontSize: 16, color: Colors.blueGrey),
          ),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 300), // Ensures it doesn't grow forever
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          final type = event['type']?.toString() ?? 'info';
          final isAlert = type == 'alert' || type == 'fall' || type == 'panic';
          
          final formattedTime = DateFormatter.formatLastSeen(event['timestamp']?.toString() ?? '');

          return ListTile(
            leading: Icon(
              isAlert ? Icons.warning : Icons.info,
              color: isAlert ? Colors.red : Colors.blueGrey,
            ),
            title: Text('Event: ${type.toUpperCase()}'),
            subtitle: Text(formattedTime),
          );
        },
      ),
    );
  }
}
