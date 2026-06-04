import 'package:flutter/material.dart';
import '../../../../core/services/app_config_service.dart';
import '../../../../services/api_service.dart';

class PairingScreen extends StatefulWidget {
  const PairingScreen({super.key});

  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientNameController = TextEditingController();
  final _braceletIdController = TextEditingController();
  final _securityCodeController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _patientNameController.dispose();
    _braceletIdController.dispose();
    _securityCodeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      // Get the unique App ID
      final appId = await AppConfigService.getAppId();

      // Retrieve form values
      final patientName = _patientNameController.text;
      final braceletId = _braceletIdController.text;
      final securityCode = _securityCodeController.text;

      // Make actual API call to pair the bracelet
      final success = await ApiService.pairBracelet(
        appId: appId,
        patientName: patientName,
        braceletId: braceletId,
        securityCode: securityCode,
      );

      setState(() {
        _isSubmitting = false;
      });

      if (!mounted) return;
      
      if (success) {
        // On success, go back to dashboard and notify user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pairing successful!')),
        );
        Navigator.pop(context);
      } else {
        // On failure, show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pairing failed. Please check your credentials and try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pair New Bracelet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Enter the details below to pair a new device.',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _patientNameController,
                decoration: const InputDecoration(
                  labelText: 'Patient Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the patient\'s name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _braceletIdController,
                decoration: const InputDecoration(
                  labelText: 'Bracelet ID',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.watch),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the Bracelet ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _securityCodeController,
                decoration: const InputDecoration(
                  labelText: 'Security Code',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.security),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the security code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              if (_isSubmitting)
                const Center(child: CircularProgressIndicator())
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Cancel', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Submit', style: TextStyle(fontSize: 18)),
                      ),
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
