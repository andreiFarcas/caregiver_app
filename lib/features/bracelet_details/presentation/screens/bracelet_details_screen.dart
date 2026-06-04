import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/models/bracelet_model.dart';
import '../../data/repositories/bracelet_details_repository.dart';
import '../../../../core/services/app_config_service.dart';
import '../../../../core/utils/date_formatter.dart';
import '../widgets/map_view_widget.dart';
import '../widgets/event_history_list.dart';

class BraceletDetailsScreen extends StatefulWidget {
  final BraceletModel bracelet;

  const BraceletDetailsScreen({
    super.key,
    required this.bracelet,
  });

  @override
  State<BraceletDetailsScreen> createState() => _BraceletDetailsScreenState();
}

class _BraceletDetailsScreenState extends State<BraceletDetailsScreen> {
  final BraceletDetailsRepository _repository = BraceletDetailsRepository();
  late BraceletModel _currentBracelet;
  List<Map<String, dynamic>> _events = [];
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _currentBracelet = widget.bracelet;
    _initAndFetch();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _initAndFetch() async {
    await _fetchDetails();
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) => _fetchDetails());
  }

  Future<void> _fetchDetails() async {
    final updatedBracelet = await _repository.getDetails(_currentBracelet.id);
    final events = await _repository.getEvents(_currentBracelet.id);

    if (mounted) {
      setState(() {
        if (updatedBracelet != null) _currentBracelet = updatedBracelet;
        if (events != null) _events = events;
      });
    }
  }

  Future<void> _unpair() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unpair Bracelet'),
        content: const Text('Are you sure you want to remove this bracelet? You will stop receiving updates for it.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Unpair', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final appId = await AppConfigService.getAppId();
      final success = await _repository.unpair(_currentBracelet.id, appId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bracelet unpaired successfully')));
        Navigator.pop(context); // Go back to dashboard
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to unpair bracelet', style: TextStyle(color: Colors.red))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format the date using our custom formatter
    final formattedLastSeen = DateFormatter.formatLastSeen(_currentBracelet.lastSeen);

    return Scaffold(
      appBar: AppBar(
        title: Text('${_currentBracelet.patientName} - Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Unpair Bracelet',
            color: Colors.redAccent,
            onPressed: _unpair,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Embedded Map
            MapViewWidget(
              latitude: _currentBracelet.lastLocation.latitude,
              longitude: _currentBracelet.lastLocation.longitude,
              accuracy: _currentBracelet.lastLocation.accuracy,
              source: _currentBracelet.lastLocation.source,
            ),
            const SizedBox(height: 24),
            
            // Status Summary details
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: Icon(
                  _currentBracelet.status.toLowerCase() == 'ok' ? Icons.check_circle : Icons.error,
                  color: _currentBracelet.status.toLowerCase() == 'ok' ? Colors.green : Colors.red,
                ),
                title: Text('Status: ${_currentBracelet.status}'),
                subtitle: Text('Battery: ${_currentBracelet.batteryPercent}%  •  Last Seen: $formattedLastSeen'),
              ),
            ),
            const SizedBox(height: 24),
            
            // Event History
            const Text(
              'Alerts & Event History',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            EventHistoryList(events: _events),
          ],
        ),
      ),
    );
  }
}
