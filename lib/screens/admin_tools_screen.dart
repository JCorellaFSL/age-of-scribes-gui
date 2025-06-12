import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';

class AdminToolsScreen extends StatefulWidget {
  const AdminToolsScreen({super.key});

  @override
  State<AdminToolsScreen> createState() => _AdminToolsScreenState();
}

class _AdminToolsScreenState extends State<AdminToolsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildTabBar(),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                ForceEventTrigger(),
                InjectRumorTool(),
                NpcTraceView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.admin_panel_settings,
          color: Theme.of(context).colorScheme.primary,
          size: 32,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admin Tools',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              'Manual control and debugging utilities',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      tabs: const [
        Tab(
          icon: Icon(Icons.flash_on),
          text: 'Force Events',
        ),
        Tab(
          icon: Icon(Icons.forum),
          text: 'Inject Rumors',
        ),
        Tab(
          icon: Icon(Icons.person_search),
          text: 'NPC Trace',
        ),
      ],
    );
  }
}

// Force Event Trigger Tool
class ForceEventTrigger extends StatefulWidget {
  const ForceEventTrigger({super.key});

  @override
  State<ForceEventTrigger> createState() => _ForceEventTriggerState();
}

class _ForceEventTriggerState extends State<ForceEventTrigger> {
  String _selectedEventType = 'Caravan Attack';
  final _targetController = TextEditingController();
  bool _isSubmitting = false;
  String? _result;
  bool _isSuccess = false;

  final List<String> _eventTypes = [
    'Caravan Attack',
    'Guild War',
    'Plague Outbreak',
    'Political Coup',
    'Natural Disaster',
    'Trade Embargo',
    'Religious Schism',
    'Bandit Uprising',
  ];

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _triggerEvent() async {
    setState(() {
      _isSubmitting = true;
      _result = null;
    });

    final eventData = {
      'type': _selectedEventType,
      if (_targetController.text.isNotEmpty) 'target_id': _targetController.text,
    };

    try {
      final success = await ApiService.triggerEvent(eventData);
      
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _isSuccess = success;
          _result = success 
              ? 'Event "$_selectedEventType" triggered successfully!'
              : 'Failed to trigger event. Check server logs.';
        });

        if (success) {
          _targetController.clear();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _isSuccess = false;
          _result = 'Error: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                    'Force Event Trigger',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manually trigger specific events in the simulation for testing purposes.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Event Type Dropdown
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Event Type',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedEventType,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Select event type',
                        ),
                        items: _eventTypes.map((String eventType) {
                          return DropdownMenuItem<String>(
                            value: eventType,
                            child: Text(eventType),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedEventType = newValue;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Optional Target Field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Target (Optional)',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _targetController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Settlement ID, Guild ID, or Faction ID',
                          helperText: 'Leave empty for random target selection',
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _triggerEvent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Theme.of(context).colorScheme.onError,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isSubmitting
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                SizedBox(width: 8),
                                Text('Triggering Event...'),
                              ],
                            )
                          : const Text('Trigger Event'),
                    ),
                  ),
                  
                  // Result Display
                  if (_result != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isSuccess 
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _result!,
                        style: TextStyle(
                          color: _isSuccess 
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Inject Rumor Tool
class InjectRumorTool extends StatefulWidget {
  const InjectRumorTool({super.key});

  @override
  State<InjectRumorTool> createState() => _InjectRumorToolState();
}

class _InjectRumorToolState extends State<InjectRumorTool> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _rumorTextController = TextEditingController();
  final _originSettlementController = TextEditingController();
  final _credibilityController = TextEditingController(text: '0.5');
  
  bool _isSubmitting = false;
  String? _result;
  bool _isSuccess = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _rumorTextController.dispose();
    _originSettlementController.dispose();
    _credibilityController.dispose();
    super.dispose();
  }

  Future<void> _injectRumor() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _result = null;
    });

    final rumorData = {
      'subject': _subjectController.text,
      'rumor_text': _rumorTextController.text,
      'origin_settlement': _originSettlementController.text,
      'credibility': double.parse(_credibilityController.text),
    };

    try {
      final success = await ApiService.injectRumor(rumorData);
      
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _isSuccess = success;
          _result = success 
              ? 'Rumor injected successfully and propagating through the network!'
              : 'Failed to inject rumor. Check server logs.';
        });

        if (success) {
          _subjectController.clear();
          _rumorTextController.clear();
          _originSettlementController.clear();
          _credibilityController.text = '0.5';
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _isSuccess = false;
          _result = 'Error: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Inject Rumor',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create and inject custom rumors into the simulation\'s information network.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Subject Field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Subject',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _subjectController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'NPC ID, Guild ID, or other entity identifier',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Subject is required';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Rumor Text Field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rumor Text',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _rumorTextController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'The content of the rumor...',
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Rumor text is required';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Origin Settlement Field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Origin Settlement',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _originSettlementController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Settlement ID where the rumor originates',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Origin settlement is required';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Credibility Field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Credibility (0.0 - 1.0)',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _credibilityController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: '0.5',
                            helperText: '0.0 = completely false, 1.0 = completely true',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Credibility is required';
                            }
                            final credibility = double.tryParse(value);
                            if (credibility == null || credibility < 0.0 || credibility > 1.0) {
                              return 'Credibility must be between 0.0 and 1.0';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _injectRumor,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isSubmitting
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Injecting Rumor...'),
                                ],
                              )
                            : const Text('Inject Rumor'),
                      ),
                    ),
                    
                    // Result Display
                    if (_result != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _isSuccess 
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _result!,
                          style: TextStyle(
                            color: _isSuccess 
                                ? Theme.of(context).colorScheme.onPrimaryContainer
                                : Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// NPC Trace View
class NpcTraceView extends StatefulWidget {
  const NpcTraceView({super.key});

  @override
  State<NpcTraceView> createState() => _NpcTraceViewState();
}

class _NpcTraceViewState extends State<NpcTraceView> {
  final _npcIdController = TextEditingController();
  
  bool _isLoading = false;
  Map<String, dynamic>? _npcData;
  String? _error;

  @override
  void dispose() {
    _npcIdController.dispose();
    super.dispose();
  }

  Future<void> _loadNpcTrace() async {
    if (_npcIdController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _npcData = null;
    });

    try {
      final data = await ApiService.fetchNpcTrace(_npcIdController.text);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (data != null) {
            _npcData = data;
          } else {
            _error = 'NPC not found or no trace data available';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Error: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _flagForDebug() async {
    if (_npcIdController.text.isEmpty) return;

    try {
      final success = await ApiService.flagNpcForDebug(_npcIdController.text);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success 
                  ? 'NPC flagged for debug monitoring'
                  : 'Failed to flag NPC for debug',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NPC Trace View',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'View detailed information about an NPC including their history, relationships, and current status.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _npcIdController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'NPC ID or Name',
                            hintText: 'Enter NPC identifier',
                          ),
                          onFieldSubmitted: (_) => _loadNpcTrace(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _loadNpcTrace,
                        child: _isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Search'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Results
          if (_error != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_npcData != null)
            ..._buildNpcDetails(),
        ],
      ),
    );
  }

  List<Widget> _buildNpcDetails() {
    if (_npcData == null) return [];

    return [
      // Basic Info Card
      Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _npcData!['name'] ?? 'Unknown NPC',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  ElevatedButton.icon(
                    onPressed: _flagForDebug,
                    icon: const Icon(Icons.bug_report, size: 16),
                    label: const Text('Flag for Debug'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem('Faction', _npcData!['faction'] ?? 'None'),
                  ),
                  Expanded(
                    child: _buildDetailItem('Guild', _npcData!['guild'] ?? 'None'),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem('Career', _npcData!['career'] ?? 'Unknown'),
                  ),
                  Expanded(
                    child: _buildDetailItem('Location', _npcData!['location'] ?? 'Unknown'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      
      const SizedBox(height: 16),
      
      // Memory & Events Card
      if (_npcData!['memory'] != null && _npcData!['memory'].isNotEmpty)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Memory (Last 10 Events)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                
                ...(_npcData!['memory'] as List).take(10).map((memory) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(top: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            memory.toString(),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      
      const SizedBox(height: 16),
      
      // Reputation & Loyalty Card
      Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reputation & Loyalty',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildScoreItem(
                      'Loyalty',
                      _npcData!['loyalty']?.toDouble() ?? 0.0,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildScoreItem(
                      'Reputation',
                      _npcData!['reputation']?.toDouble() ?? 0.0,
                      Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      
      const SizedBox(height: 16),
      
      // Rumors Card
      if (_npcData!['rumors'] != null && _npcData!['rumors'].isNotEmpty)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Associated Rumors',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                
                ...(_npcData!['rumors'] as List).map((rumor) {
                  return Card(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rumor['text'] ?? rumor.toString(),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          if (rumor is Map && rumor['credibility'] != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Credibility: ${(rumor['credibility'] * 100).toInt()}%',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
    ];
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreItem(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: value.clamp(0.0, 1.0),
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
        const SizedBox(height: 4),
        Text(
          '${(value * 100).toInt()}%',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
} 