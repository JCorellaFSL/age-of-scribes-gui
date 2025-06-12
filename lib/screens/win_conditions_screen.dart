import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/win_conditions.dart';
import '../services/api_service.dart';

class WinConditionsScreen extends StatefulWidget {
  const WinConditionsScreen({super.key});

  @override
  State<WinConditionsScreen> createState() => _WinConditionsScreenState();
}

class _WinConditionsScreenState extends State<WinConditionsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _maxYearsController = TextEditingController();
  final _popThresholdController = TextEditingController();
  final _collapseLimitController = TextEditingController();
  final _factionController = TextEditingController();
  
  // State
  List<String> _requiredFactions = [];
  List<Scenario> _scenarios = [];
  Scenario? _selectedScenario;
  String? _activeScenarioName;
  bool _isSubmitting = false;
  bool _isLoadingScenarios = false;
  bool _isLoadingScenario = false;
  String? _submitError;
  String? _scenarioError;

  @override
  void initState() {
    super.initState();
    _loadScenarios();
  }

  @override
  void dispose() {
    _maxYearsController.dispose();
    _popThresholdController.dispose();
    _collapseLimitController.dispose();
    _factionController.dispose();
    super.dispose();
  }

  Future<void> _loadScenarios() async {
    setState(() {
      _isLoadingScenarios = true;
      _scenarioError = null;
    });

    try {
      final scenarios = await ApiService.fetchScenarioList();
      if (mounted) {
        setState(() {
          _scenarios = scenarios;
          _isLoadingScenarios = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _scenarioError = e.toString();
          _isLoadingScenarios = false;
        });
      }
    }
  }

  Future<void> _submitWinConditions() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      final conditions = WinConditions(
        maxYears: _maxYearsController.text.isNotEmpty ? int.parse(_maxYearsController.text) : null,
        popThreshold: _popThresholdController.text.isNotEmpty ? int.parse(_popThresholdController.text) : null,
        collapseLimit: _collapseLimitController.text.isNotEmpty ? int.parse(_collapseLimitController.text) : null,
        requiredFactions: _requiredFactions,
      );

      if (conditions.isEmpty) {
        setState(() {
          _submitError = 'Please define at least one win condition';
          _isSubmitting = false;
        });
        return;
      }

      final success = await ApiService.setWinConditions(conditions);
      
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Win conditions set successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          setState(() {
            _submitError = 'Failed to set win conditions. Please try again.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _submitError = 'Error: ${e.toString()}';
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _loadScenario() async {
    if (_selectedScenario == null) return;

    setState(() {
      _isLoadingScenario = true;
      _scenarioError = null;
    });

    try {
      final success = await ApiService.loadScenarioById(_selectedScenario!.id);
      
      if (mounted) {
        setState(() {
          _isLoadingScenario = false;
        });

        if (success) {
          setState(() {
            _activeScenarioName = _selectedScenario!.name;
          });
          
          // Pre-fill form with scenario conditions
          _populateFormFromScenario(_selectedScenario!);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Scenario "${_selectedScenario!.name}" loaded successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          setState(() {
            _scenarioError = 'Failed to load scenario. Please try again.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _scenarioError = 'Error: ${e.toString()}';
          _isLoadingScenario = false;
        });
      }
    }
  }

  void _populateFormFromScenario(Scenario scenario) {
    final conditions = scenario.winConditions;
    
    _maxYearsController.text = conditions.maxYears?.toString() ?? '';
    _popThresholdController.text = conditions.popThreshold?.toString() ?? '';
    _collapseLimitController.text = conditions.collapseLimit?.toString() ?? '';
    
    setState(() {
      _requiredFactions = List.from(conditions.requiredFactions);
    });
  }

  void _addFaction() {
    final factionId = _factionController.text.trim();
    if (factionId.isNotEmpty && !_requiredFactions.contains(factionId)) {
      setState(() {
        _requiredFactions.add(factionId);
      });
      _factionController.clear();
    }
  }

  void _removeFaction(String factionId) {
    setState(() {
      _requiredFactions.remove(factionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main form section
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildWinConditionsForm(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 32),
          // Scenario management section
          Expanded(
            flex: 1,
            child: _buildScenarioSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Win Conditions',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        Text(
          'Define the conditions that determine victory or defeat',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildWinConditionsForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Define Win Conditions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Set numeric limits and requirements for simulation success/failure',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Max Years
                  TextFormField(
                    controller: _maxYearsController,
                    decoration: const InputDecoration(
                      labelText: 'Maximum Years',
                      hintText: 'e.g., 1000',
                      helperText: 'Simulation fails if this year limit is reached',
                      prefixIcon: Icon(Icons.schedule),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final years = int.tryParse(value);
                        if (years == null || years <= 0) {
                          return 'Please enter a valid positive number';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Population Threshold
                  TextFormField(
                    controller: _popThresholdController,
                    decoration: const InputDecoration(
                      labelText: 'Population Threshold',
                      hintText: 'e.g., 100000',
                      helperText: 'Win when total population reaches this number',
                      prefixIcon: Icon(Icons.people),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final pop = int.tryParse(value);
                        if (pop == null || pop <= 0) {
                          return 'Please enter a valid positive number';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Collapse Limit
                  TextFormField(
                    controller: _collapseLimitController,
                    decoration: const InputDecoration(
                      labelText: 'Collapse Limit',
                      hintText: 'e.g., 5',
                      helperText: 'Simulation fails after this many settlement collapses',
                      prefixIcon: Icon(Icons.warning),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final limit = int.tryParse(value);
                        if (limit == null || limit < 0) {
                          return 'Please enter a valid non-negative number';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Required Factions
                  Text(
                    'Required Faction Survival',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'These factions must survive for victory',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _factionController,
                          decoration: const InputDecoration(
                            labelText: 'Faction ID',
                            hintText: 'e.g., faction_001',
                          ),
                          onFieldSubmitted: (_) => _addFaction(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _addFaction,
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (_requiredFactions.isNotEmpty) ...[
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _requiredFactions.map((factionId) {
                        return Chip(
                          label: Text(factionId),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () => _removeFaction(factionId),
                        );
                      }).toList(),
                    ),
                  ] else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        'No required factions specified',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Submit Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_submitError != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _submitError!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submitWinConditions,
                      icon: _isSubmitting 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check_circle),
                      label: Text(_isSubmitting ? 'Setting Conditions...' : 'Set Win Conditions'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Scenarios',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Load predefined scenarios or view active configuration',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),

        // Active Scenario Display
        if (_activeScenarioName != null) ...[
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.play_circle,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Active Scenario',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _activeScenarioName!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Scenario Selection
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Load Scenario',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                
                if (_isLoadingScenarios)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_scenarios.isEmpty && _scenarioError == null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      'No scenarios available',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                else ...[
                  DropdownButtonFormField<Scenario>(
                    value: _selectedScenario,
                    decoration: const InputDecoration(
                      labelText: 'Select Scenario',
                      border: OutlineInputBorder(),
                    ),
                    items: _scenarios.map((scenario) {
                      return DropdownMenuItem(
                        value: scenario,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(scenario.name),
                            if (scenario.description.isNotEmpty)
                              Text(
                                scenario.description,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (scenario) {
                      setState(() {
                        _selectedScenario = scenario;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  if (_scenarioError != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        _scenarioError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: (_selectedScenario != null && !_isLoadingScenario) 
                          ? _loadScenario 
                          : null,
                      icon: _isLoadingScenario
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.download),
                      label: Text(_isLoadingScenario ? 'Loading...' : 'Load Scenario'),
                    ),
                  ),
                ],
                
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _loadScenarios,
                  child: const Text('Refresh Scenarios'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
} 