import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/sim_parameters.dart';
import '../services/api_service.dart';

class SimConfigScreen extends StatefulWidget {
  const SimConfigScreen({super.key});

  @override
  State<SimConfigScreen> createState() => _SimConfigScreenState();
}

class _SimConfigScreenState extends State<SimConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _yearsController = TextEditingController(text: '5');
  final _tickSpeedController = TextEditingController(text: '10');
  final _seedController = TextEditingController();
  
  bool _isSubmitting = false;

  @override
  void dispose() {
    _yearsController.dispose();
    _tickSpeedController.dispose();
    _seedController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final parameters = SimParameters(
        simYears: int.parse(_yearsController.text),
        tickSpeed: int.parse(_tickSpeedController.text),
        seed: _seedController.text.isEmpty ? null : _seedController.text,
      );

      final success = await ApiService.setSimulationParameters(parameters);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success 
                ? 'Simulation parameters updated successfully!'
                : 'Failed to update simulation parameters',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Simulation Configuration',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _yearsController,
                        decoration: const InputDecoration(
                          labelText: 'Years to Simulate',
                          hintText: 'Enter number of years',
                          border: OutlineInputBorder(),
                          suffixText: 'years',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter years to simulate';
                          }
                          final years = int.tryParse(value);
                          if (years == null || years <= 0) {
                            return 'Please enter a valid positive number';
                          }
                          if (years > 1000) {
                            return 'Years cannot exceed 1000';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _tickSpeedController,
                        decoration: const InputDecoration(
                          labelText: 'Tick Speed',
                          hintText: 'Enter tick speed in milliseconds',
                          border: OutlineInputBorder(),
                          suffixText: 'ms',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter tick speed';
                          }
                          final speed = int.tryParse(value);
                          if (speed == null || speed <= 0) {
                            return 'Please enter a valid positive number';
                          }
                          if (speed < 1 || speed > 10000) {
                            return 'Tick speed must be between 1 and 10000 ms';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _seedController,
                        decoration: const InputDecoration(
                          labelText: 'Seed (Optional)',
                          hintText: 'Enter random seed for reproducible simulations',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          // Seed is optional, so no validation needed
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isSubmitting
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text('Submitting...'),
                                  ],
                                )
                              : const Text(
                                  'Update Simulation Parameters',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Configuration Help',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '• Years to Simulate: Total duration of the simulation\n'
                        '• Tick Speed: Controls simulation speed (lower = faster)\n'
                        '• Seed: Optional value for reproducible results',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 