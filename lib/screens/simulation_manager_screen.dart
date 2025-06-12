import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/save_slot.dart';
import '../models/scenario_version.dart';
import '../models/patch_notes.dart';

class SimulationManagerScreen extends StatefulWidget {
  const SimulationManagerScreen({super.key});

  @override
  State<SimulationManagerScreen> createState() => _SimulationManagerScreenState();
}

class _SimulationManagerScreenState extends State<SimulationManagerScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: const [
                  SaveLoadSlotsPanel(),
                  SizedBox(height: 16),
                  ScenarioVersionControlPanel(),
                  SizedBox(height: 16),
                  PatchNotesPanel(),
                ],
              ),
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
          Icons.manage_history,
          color: Theme.of(context).colorScheme.primary,
          size: 32,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Simulation Manager',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              'Save/Load, Version Control, and Patch Information',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Save/Load Slots Panel
class SaveLoadSlotsPanel extends StatefulWidget {
  const SaveLoadSlotsPanel({super.key});

  @override
  State<SaveLoadSlotsPanel> createState() => _SaveLoadSlotsPanelState();
}

class _SaveLoadSlotsPanelState extends State<SaveLoadSlotsPanel> {
  bool _isExpanded = true;
  List<SaveSlot> _saveSlots = [];
  bool _isLoading = false;
  String? _error;
  final _saveNameController = TextEditingController();
  final _saveDescriptionController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSaveSlots();
  }

  @override
  void dispose() {
    _saveNameController.dispose();
    _saveDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadSaveSlots() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final slots = await ApiService.fetchSaveSlots();
      if (mounted) {
        setState(() {
          _saveSlots = slots;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error loading save slots: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveCurrentState() async {
    if (_saveNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a save name')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final success = await ApiService.saveCurrentSimulation(
        _saveNameController.text.trim(),
        description: _saveDescriptionController.text.trim().isEmpty 
            ? null 
            : _saveDescriptionController.text.trim(),
      );

      if (mounted) {
        setState(() => _isSaving = false);
        
        if (success) {
          _saveNameController.clear();
          _saveDescriptionController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Simulation saved successfully!')),
          );
          _loadSaveSlots(); // Refresh the list
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save simulation')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _loadSaveSlot(SaveSlot slot) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Load Save Slot'),
        content: Text('Load "${slot.name}"?\nThis will replace the current simulation state.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Load'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await ApiService.loadSaveSlot(slot.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success 
                ? 'Save slot "${slot.name}" loaded successfully!' 
                : 'Failed to load save slot'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Load error: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _deleteSaveSlot(SaveSlot slot) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Save Slot'),
        content: Text('Delete "${slot.name}"?\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await ApiService.deleteSaveSlot(slot.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success 
                ? 'Save slot "${slot.name}" deleted successfully!' 
                : 'Failed to delete save slot'),
            ),
          );
          if (success) {
            _loadSaveSlots(); // Refresh the list
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Delete error: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.save),
            title: const Text('Save/Load Slots'),
            subtitle: const Text('Manage simulation save states'),
            trailing: IconButton(
              icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () => setState(() => _isExpanded = !_isExpanded),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Save Current State Section
                  Text(
                    'Save Current State',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _saveNameController,
                          decoration: const InputDecoration(
                            labelText: 'Save Name *',
                            hintText: 'Enter a name for this save',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _saveDescriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description (optional)',
                            hintText: 'Brief description',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        onPressed: _isSaving ? null : _saveCurrentState,
                        icon: _isSaving 
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.save),
                        label: Text(_isSaving ? 'Saving...' : 'Save'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Save Slots List Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Available Save Slots',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _isLoading ? null : _loadSaveSlots,
                        tooltip: 'Refresh save slots',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_error != null)
                    Card(
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          _error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    )
                  else if (_saveSlots.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No save slots found'),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _saveSlots.length,
                      itemBuilder: (context, index) {
                        final slot = _saveSlots[index];
                        return Card(
                          child: ListTile(
                            title: Text(slot.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Tick: ${slot.tick} | Population: ${slot.totalPopulation}'),
                                Text('Saved: ${slot.timestamp.toLocal().toString().substring(0, 19)}'),
                                if (slot.description != null && slot.description!.isNotEmpty)
                                  Text(slot.description!),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.play_arrow),
                                  onPressed: () => _loadSaveSlot(slot),
                                  tooltip: 'Load',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteSaveSlot(slot),
                                  tooltip: 'Delete',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Scenario Version Control Panel
class ScenarioVersionControlPanel extends StatefulWidget {
  const ScenarioVersionControlPanel({super.key});

  @override
  State<ScenarioVersionControlPanel> createState() => _ScenarioVersionControlPanelState();
}

class _ScenarioVersionControlPanelState extends State<ScenarioVersionControlPanel> {
  bool _isExpanded = false;
  List<ScenarioVersion> _versions = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVersions();
  }

  Future<void> _loadVersions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final versions = await ApiService.fetchScenarioVersions();
      if (mounted) {
        setState(() {
          _versions = versions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error loading scenario versions: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadVersion(ScenarioVersion version) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Load Scenario Version'),
        content: Text('Load "${version.title}" (v${version.versionNumber})?\nThis will replace the current scenario.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Load'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await ApiService.loadScenarioVersion(version.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success 
                ? 'Scenario "${version.title}" loaded successfully!' 
                : 'Failed to load scenario version'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Load error: ${e.toString()}')),
          );
        }
      }
    }
  }

  void _showVersionDetails(ScenarioVersion version) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${version.title} (v${version.versionNumber})'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Description:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(version.description),
              const SizedBox(height: 16),
              if (version.majorChanges.isNotEmpty) ...[
                Text(
                  'Major Changes:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                ...version.majorChanges.map((change) => Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 2.0),
                  child: Text('• $change'),
                )),
                const SizedBox(height: 16),
              ],
              Text(
                'Created: ${version.createdAt.toLocal().toString().substring(0, 19)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (version.isActive)
                Chip(
                  label: const Text('Active'),
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (!version.isActive)
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                _loadVersion(version);
              },
              child: const Text('Load Version'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Scenario Version Control'),
            subtitle: const Text('Manage scenario versions and configurations'),
            trailing: IconButton(
              icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () => setState(() => _isExpanded = !_isExpanded),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Available Versions',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _isLoading ? null : _loadVersions,
                        tooltip: 'Refresh versions',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_error != null)
                    Card(
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          _error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    )
                  else if (_versions.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No scenario versions found'),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _versions.length,
                      itemBuilder: (context, index) {
                        final version = _versions[index];
                        return Card(
                          child: ListTile(
                            title: Row(
                              children: [
                                Expanded(child: Text(version.title)),
                                if (version.isActive)
                                  Chip(
                                    label: const Text('Active'),
                                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                  ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Version ${version.versionNumber}'),
                                Text('Created: ${version.createdAt.toLocal().toString().substring(0, 19)}'),
                                if (version.description.isNotEmpty)
                                  Text(
                                    version.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.info_outline),
                                  onPressed: () => _showVersionDetails(version),
                                  tooltip: 'View Details',
                                ),
                                if (!version.isActive)
                                  IconButton(
                                    icon: const Icon(Icons.play_arrow),
                                    onPressed: () => _loadVersion(version),
                                    tooltip: 'Load Version',
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Patch Notes Panel
class PatchNotesPanel extends StatefulWidget {
  const PatchNotesPanel({super.key});

  @override
  State<PatchNotesPanel> createState() => _PatchNotesPanelState();
}

class _PatchNotesPanelState extends State<PatchNotesPanel> {
  bool _isExpanded = false;
  PatchNotes? _patchNotes;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPatchNotes();
  }

  Future<void> _loadPatchNotes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final patchNotes = await ApiService.fetchPatchNotes();
      if (mounted) {
        setState(() {
          _patchNotes = patchNotes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error loading patch notes: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildChangesList(String title, List<String> changes, Color? highlightColor) {
    if (changes.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: highlightColor,
          ),
        ),
        const SizedBox(height: 4),
        ...changes.map((change) => Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 2.0),
          child: Text('• $change'),
        )),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.article),
            title: const Text('Patch Notes'),
            subtitle: const Text('Latest version information and changes'),
            trailing: IconButton(
              icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () => setState(() => _isExpanded = !_isExpanded),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Latest Version',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _isLoading ? null : _loadPatchNotes,
                        tooltip: 'Refresh patch notes',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_error != null)
                    Card(
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          _error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    )
                  else if (_patchNotes == null)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No patch notes available'),
                      ),
                    )
                  else
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Version ${_patchNotes!.version}',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Text(
                                  'Released: ${_patchNotes!.releaseDate.toLocal().toString().substring(0, 10)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            _buildChangesList(
                              'Feature Changes', 
                              _patchNotes!.featureChanges,
                              Theme.of(context).colorScheme.primary,
                            ),
                            
                            _buildChangesList(
                              'Bug Fixes', 
                              _patchNotes!.bugFixes,
                              Theme.of(context).colorScheme.secondary,
                            ),
                            
                            _buildChangesList(
                              'Guild Logic Updates', 
                              _patchNotes!.guildLogicUpdates,
                              Colors.orange,
                            ),
                            
                            _buildChangesList(
                              'AI Updates', 
                              _patchNotes!.aiUpdates,
                              Colors.green,
                            ),
                            
                            _buildChangesList(
                              'Faction Behavior Changes', 
                              _patchNotes!.factionBehaviorChanges,
                              Colors.purple,
                            ),
                            
                            _buildChangesList(
                              'Backend Notes', 
                              _patchNotes!.backendNotes,
                              Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
} 