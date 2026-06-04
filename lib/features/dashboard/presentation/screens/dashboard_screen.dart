import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/models/bracelet_model.dart';
import '../widgets/patient_bracelet_card.dart';
import '../../../pairing/presentation/screens/pairing_screen.dart';
import '../../../../core/services/app_config_service.dart';
import '../../data/repositories/bracelet_repository.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final BraceletRepository _repository = BraceletRepository();
  List<BraceletModel> _bracelets = [];
  bool _isLoading = true;
  bool _hasConnectionError = false;
  String _loadingMessage = 'Fetching data from server...';
  Timer? _pollingTimer;
  Timer? _timeoutTimer;
  String? _appId;

  @override
  void initState() {
    super.initState();
    _initAndFetch();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  Future<void> _initAndFetch() async {
    setState(() {
      _isLoading = true;
      _hasConnectionError = false;
      _loadingMessage = 'Fetching data from server...';
    });

    _appId = await AppConfigService.getAppId();

    // 15-second timeout for the initial load
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(const Duration(seconds: 15), () {
      if (_isLoading && mounted) {
        setState(() {
          _isLoading = false;
          _hasConnectionError = true;
        });
      }
    });

    await _fetchBracelets();
    // Do not unconditionally cancel the timeout here, as a fast-failing network error 
    // would cancel the timer but leave the app stuck in _isLoading = true.
    
    // Start polling every 10 seconds
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!_hasConnectionError) {
        _fetchBracelets();
      }
    });
  }

  Future<void> _fetchBracelets() async {
    if (_appId == null) return;
    
    final bracelets = await _repository.getPairedBracelets(_appId!);
    
    // If the repository returns null, it means there was a network error. 
    if (bracelets == null) {
      if (mounted && _isLoading) {
        // If we are actively on the initial loading screen and the network fails (e.g. connection refused),
        // we can immediately show the error state instead of waiting for the 15-second timer to expire.
        setState(() {
          _isLoading = false;
          _hasConnectionError = true;
        });
        _timeoutTimer?.cancel();
      }
      return; // If not loading, ignore the failure so the UI doesn't drop currently displayed bracelets.
    }

    if (mounted) {
      setState(() {
        _bracelets = bracelets;
        _isLoading = false;
        _hasConnectionError = false;
      });
      _timeoutTimer?.cancel(); // Cancel timeout since we successfully fetched data
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caregiver Application - Dashboard'),
        // Align central horizontally
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Patients Overview',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.refresh, color: Theme.of(context).colorScheme.primary),
                tooltip: 'Refresh Patients',
                onPressed: () {
                  // Trigger a manual refresh that shows the loading indicator again
                  _initAndFetch();
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Display Loading, Error, Empty State, or List of Bracelets
          if (_hasConnectionError)
            Container(
              height: 260, // Fixed height to match loading box exactly
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Vertically center content
                children: [
                  const Icon(Icons.wifi_off, size: 48, color: Colors.redAccent),
                  const SizedBox(height: 12),
                  const Text(
                    'Cannot reach the server.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please check your internet connection or ensure the server is running.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.redAccent),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _initAndFetch,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            )
          else if (_isLoading)
            Container(
              height: 260, // Fixed height to match error box exactly
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Vertically center content
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 24),
                  Text(
                    _loadingMessage,
                    style: const TextStyle(fontSize: 16, color: Colors.blueGrey, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )
          else if (_bracelets.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Icon(Icons.info_outline, size: 48, color: Colors.blueGrey),
                  SizedBox(height: 12),
                  Text(
                    'No bracelets paired yet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.blueGrey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Click the button below to add your first device.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.blueGrey),
                  ),
                ],
              ),
            )
          else
            ..._bracelets.map((b) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: PatientBraceletCard(
                bracelet: b,
                onReturn: _fetchBracelets, // Instantly refresh when coming back from Details
              ),
            )),
          
          const SizedBox(height: 16),
          // Add new bracelet button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PairingScreen(),
                ),
              ).then((_) {
                // Instantly query API again when returning from Pairing Screen
                _fetchBracelets();
              });
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, size: 28),
                SizedBox(width: 8),
                Text(
                  'Add new bracelet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}