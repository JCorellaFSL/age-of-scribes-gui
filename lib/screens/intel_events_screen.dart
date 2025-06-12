import 'dart:async';
import 'package:flutter/material.dart';
import '../models/intelligence_data.dart';
import '../services/api_service.dart';

class IntelEventsScreen extends StatefulWidget {
  const IntelEventsScreen({super.key});

  @override
  State<IntelEventsScreen> createState() => _IntelEventsScreenState();
}

class _IntelEventsScreenState extends State<IntelEventsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  // Faction intelligence state
  List<Faction> _factions = [];
  String? _expandedFactionId;
  bool _isLoadingFactions = false;
  String? _factionError;

  // Guild intelligence state
  List<Guild> _guilds = [];
  String? _expandedGuildId;
  bool _isLoadingGuilds = false;
  String? _guildError;

  // Event feed state
  List<GameEvent> _events = [];
  EventFilters _eventFilters = const EventFilters();
  bool _isLoadingEvents = false;
  String? _eventError;
  Timer? _eventRefreshTimer;

  // Debug hooks (hidden for future debugging features)
  bool _debugMode = false;
  bool _showDebugControls = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAllData();
    _startEventAutoRefresh();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _eventRefreshTimer?.cancel();
    super.dispose();
  }

  void _startEventAutoRefresh() {
    _eventRefreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!_isLoadingEvents) {
        _loadEvents();
      }
    });
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadFactions(),
      _loadGuilds(),
      _loadEvents(),
    ]);
  }

  Future<void> _loadFactions() async {
    setState(() {
      _isLoadingFactions = true;
      _factionError = null;
    });

    try {
      final factions = await ApiService.fetchFactions();
      if (mounted) {
        setState(() {
          _factions = factions;
          _isLoadingFactions = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _factionError = e.toString();
          _isLoadingFactions = false;
        });
      }
    }
  }

  Future<void> _loadGuilds() async {
    setState(() {
      _isLoadingGuilds = true;
      _guildError = null;
    });

    try {
      final guilds = await ApiService.fetchGuilds();
      if (mounted) {
        setState(() {
          _guilds = guilds;
          _isLoadingGuilds = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _guildError = e.toString();
          _isLoadingGuilds = false;
        });
      }
    }
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoadingEvents = true;
      _eventError = null;
    });

    try {
      final events = await ApiService.fetchRecentEvents(_eventFilters);
      if (mounted) {
        setState(() {
          _events = events;
          _isLoadingEvents = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _eventError = e.toString();
          _isLoadingEvents = false;
        });
      }
    }
  }

  void _toggleFactionExpansion(String factionId) {
    setState(() {
      _expandedFactionId = _expandedFactionId == factionId ? null : factionId;
    });
  }

  void _toggleGuildExpansion(String guildId) {
    setState(() {
      _expandedGuildId = _expandedGuildId == guildId ? null : guildId;
    });
  }

  void _updateEventFilters(EventFilters newFilters) {
    setState(() {
      _eventFilters = newFilters;
    });
    _loadEvents();
  }

  // Debug hooks for future debugging features (hidden functionality)
  void _enableDebugMode() {
    if (!_debugMode) {
      setState(() {
        _debugMode = true;
        _showDebugControls = false; // Keep hidden for now
      });
    }
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
              children: [
                _buildFactionIntelligence(),
                _buildGuildIntelligence(),
                _buildEventFeed(),
              ],
            ),
          ),
          if (_showDebugControls) _buildDebugControls(), // Hidden for now
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Intel & Events',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              'Monitor factions, guilds, and world events',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: _loadAllData,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh All Data',
            ),
            // Hidden debug trigger - long press to enable debug mode
            GestureDetector(
              onLongPress: _enableDebugMode,
              child: const SizedBox(width: 16, height: 16),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      tabs: [
        Tab(
          icon: const Icon(Icons.groups),
          text: 'Factions (${_factions.length})',
        ),
        Tab(
          icon: const Icon(Icons.business),
          text: 'Guilds (${_guilds.length})',
        ),
        Tab(
          icon: const Icon(Icons.event_note),
          text: 'Events (${_events.length})',
        ),
      ],
    );
  }

  Widget _buildFactionIntelligence() {
    if (_isLoadingFactions && _factions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading faction intelligence...'),
          ],
        ),
      );
    }

    if (_factionError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load faction data',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(_factionError!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFactions,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_factions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 64),
            SizedBox(height: 16),
            Text('No active factions found'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _factions.length,
      itemBuilder: (context, index) => _buildFactionCard(_factions[index]),
    );
  }

  Widget _buildFactionCard(Faction faction) {
    final isExpanded = _expandedFactionId == faction.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: _getFactionTypeColor(faction.type),
              child: Icon(
                _getFactionTypeIcon(faction.type),
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Text(
              faction.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text('${faction.type.displayName} • ${faction.memberCount} members'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${(faction.reputationAverage * 100).toInt()}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
            onTap: () => _toggleFactionExpansion(faction.id),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildExpandedFactionView(faction),
            ),
        ],
      ),
    );
  }

  Widget _buildExpandedFactionView(Faction faction) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (faction.ideology.isNotEmpty) ...[
          _buildInfoRow('Ideology', faction.ideology),
          const SizedBox(height: 8),
        ],
        _buildInfoRow('Reputation', '${(faction.reputationAverage * 100).toInt()}%'),
        const SizedBox(height: 8),
        if (faction.alliances.isNotEmpty) ...[
          Text(
            'Alliances:',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4.0,
            children: faction.alliances.map((alliance) {
              return Chip(
                label: Text(alliance),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],
        if (faction.recentActions.isNotEmpty) ...[
          Text(
            'Recent Actions:',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          ...faction.recentActions.take(3).map((action) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 6,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      action,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildGuildIntelligence() {
    if (_isLoadingGuilds && _guilds.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading guild intelligence...'),
          ],
        ),
      );
    }

    if (_guildError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load guild data',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(_guildError!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadGuilds,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_guilds.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 64),
            SizedBox(height: 16),
            Text('No active guilds found'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _guilds.length,
      itemBuilder: (context, index) => _buildGuildCard(_guilds[index]),
    );
  }

  Widget _buildGuildCard(Guild guild) {
    final isExpanded = _expandedGuildId == guild.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: _getGuildTypeColor(guild.type),
              child: Icon(
                _getGuildTypeIcon(guild.type),
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Text(
              guild.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text('${guild.type.displayName} • ${guild.size} members'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getGuildStatusColor(guild.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    guild.status.displayName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
            onTap: () => _toggleGuildExpansion(guild.id),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildExpandedGuildView(guild),
            ),
        ],
      ),
    );
  }

  Widget _buildExpandedGuildView(Guild guild) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (guild.settlementBase.isNotEmpty) ...[
          _buildInfoRow('Base Settlement', guild.settlementBase),
          const SizedBox(height: 8),
        ],
        _buildInfoRow('Influence Score', guild.influenceScore.toStringAsFixed(1)),
        const SizedBox(height: 8),
        _buildInfoRow('Stability', '${(guild.stability * 100).toInt()}%'),
        const SizedBox(height: 8),
        if (guild.keyEvents.isNotEmpty) ...[
          Text(
            'Key Events:',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          ...guild.keyEvents.take(3).map((event) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 6,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      event,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildEventFeed() {
    return Column(
      children: [
        _buildEventFilters(),
        const SizedBox(height: 16),
        Expanded(
          child: _buildEventList(),
        ),
      ],
    );
  }

  Widget _buildEventFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Event Filters',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: EventType.values.where((type) => type != EventType.unknown).map((type) {
                final isSelected = _eventFilters.types.contains(type);
                
                return FilterChip(
                  label: Text(type.displayName),
                  selected: isSelected,
                  onSelected: (selected) {
                    final newTypes = Set<EventType>.from(_eventFilters.types);
                    if (selected) {
                      newTypes.add(type);
                    } else {
                      newTypes.remove(type);
                    }
                    _updateEventFilters(_eventFilters.copyWith(types: newTypes));
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventList() {
    if (_isLoadingEvents && _events.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading events...'),
          ],
        ),
      );
    }

    if (_eventError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load events',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(_eventError!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadEvents,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_events.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 64),
            SizedBox(height: 16),
            Text('No events found'),
            SizedBox(height: 8),
            Text('Try adjusting your filters'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _events.length,
      itemBuilder: (context, index) => _buildEventCard(_events[index]),
    );
  }

  Widget _buildEventCard(GameEvent event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getEventTypeColor(event.type),
          child: Icon(
            _getEventTypeIcon(event.type),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          event.title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.summary.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(event.summary),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'Tick ${event.tick}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (event.affectedEntities.isNotEmpty) ...[
                  const Text(' • '),
                  Text(
                    '${event.affectedEntities.length} entities',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getEventTypeColor(event.type),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            event.type.displayName,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // Hidden debug controls for future debugging features
  Widget _buildDebugControls() {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Debug Controls',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Future: Reveal all faction/guild states
                  },
                  child: const Text('Reveal All States'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // Future: Force specific events
                  },
                  child: const Text('Force Event'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods for colors and icons
  Color _getFactionTypeColor(FactionType type) {
    switch (type) {
      case FactionType.military:
        return Colors.red;
      case FactionType.religious:
        return Colors.purple;
      case FactionType.trade:
        return Colors.green;
      case FactionType.political:
        return Colors.blue;
      case FactionType.cultural:
        return Colors.orange;
      case FactionType.nomadic:
        return Colors.brown;
      case FactionType.unknown:
        return Colors.grey;
    }
  }

  IconData _getFactionTypeIcon(FactionType type) {
    switch (type) {
      case FactionType.military:
        return Icons.military_tech;
      case FactionType.religious:
        return Icons.temple_hindu;
      case FactionType.trade:
        return Icons.storefront;
      case FactionType.political:
        return Icons.gavel;
      case FactionType.cultural:
        return Icons.palette;
      case FactionType.nomadic:
        return Icons.directions_walk;
      case FactionType.unknown:
        return Icons.help_outline;
    }
  }

  Color _getGuildTypeColor(GuildType type) {
    switch (type) {
      case GuildType.merchant:
        return Colors.green;
      case GuildType.warrior:
        return Colors.red;
      case GuildType.artisan:
        return Colors.orange;
      case GuildType.scholar:
        return Colors.blue;
      case GuildType.religious:
        return Colors.purple;
      case GuildType.thieves:
        return Colors.grey[800]!;
      case GuildType.unknown:
        return Colors.grey;
    }
  }

  IconData _getGuildTypeIcon(GuildType type) {
    switch (type) {
      case GuildType.merchant:
        return Icons.shopping_bag;
      case GuildType.warrior:
        return Icons.shield;
      case GuildType.artisan:
        return Icons.build;
      case GuildType.scholar:
        return Icons.school;
      case GuildType.religious:
        return Icons.church;
      case GuildType.thieves:
        return Icons.masks;
      case GuildType.unknown:
        return Icons.business;
    }
  }

  Color _getGuildStatusColor(GuildStatus status) {
    switch (status) {
      case GuildStatus.peaceful:
        return Colors.green;
      case GuildStatus.atWar:
        return Colors.red;
      case GuildStatus.outlawed:
        return Colors.orange;
      case GuildStatus.rising:
        return Colors.blue;
      case GuildStatus.declining:
        return Colors.grey;
      case GuildStatus.unknown:
        return Colors.grey;
    }
  }

  Color _getEventTypeColor(EventType type) {
    switch (type) {
      case EventType.guild:
        return Colors.blue;
      case EventType.faction:
        return Colors.red;
      case EventType.trade:
        return Colors.green;
      case EventType.political:
        return Colors.purple;
      case EventType.combat:
        return Colors.orange;
      case EventType.diplomatic:
        return Colors.indigo;
      case EventType.economic:
        return Colors.teal;
      case EventType.unknown:
        return Colors.grey;
    }
  }

  IconData _getEventTypeIcon(EventType type) {
    switch (type) {
      case EventType.guild:
        return Icons.business;
      case EventType.faction:
        return Icons.groups;
      case EventType.trade:
        return Icons.trending_up;
      case EventType.political:
        return Icons.how_to_vote;
      case EventType.combat:
        return Icons.gps_fixed;
      case EventType.diplomatic:
        return Icons.handshake;
      case EventType.economic:
        return Icons.attach_money;
      case EventType.unknown:
        return Icons.event;
    }
  }
} 