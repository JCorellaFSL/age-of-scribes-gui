enum FactionType {
  military,
  religious,
  trade,
  political,
  cultural,
  nomadic,
  unknown;

  static FactionType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'military':
        return FactionType.military;
      case 'religious':
        return FactionType.religious;
      case 'trade':
        return FactionType.trade;
      case 'political':
        return FactionType.political;
      case 'cultural':
        return FactionType.cultural;
      case 'nomadic':
        return FactionType.nomadic;
      default:
        return FactionType.unknown;
    }
  }

  String get displayName {
    switch (this) {
      case FactionType.military:
        return 'Military';
      case FactionType.religious:
        return 'Religious';
      case FactionType.trade:
        return 'Trade';
      case FactionType.political:
        return 'Political';
      case FactionType.cultural:
        return 'Cultural';
      case FactionType.nomadic:
        return 'Nomadic';
      case FactionType.unknown:
        return 'Unknown';
    }
  }
}

class Faction {
  final String id;
  final String name;
  final FactionType type;
  final String ideology;
  final int memberCount;
  final double reputationAverage;
  final List<String> alliances;
  final List<String> recentActions;
  final Map<String, dynamic> metadata;

  const Faction({
    required this.id,
    required this.name,
    required this.type,
    required this.ideology,
    required this.memberCount,
    required this.reputationAverage,
    required this.alliances,
    required this.recentActions,
    required this.metadata,
  });

  factory Faction.fromJson(Map<String, dynamic> json) {
    return Faction(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Faction',
      type: FactionType.fromString(json['type']?.toString() ?? 'unknown'),
      ideology: json['ideology']?.toString() ?? '',
      memberCount: json['member_count'] ?? json['members'] ?? 0,
      reputationAverage: (json['reputation_average'] ?? json['reputation'] ?? 0.0).toDouble(),
      alliances: List<String>.from(json['alliances'] ?? []),
      recentActions: List<String>.from(json['recent_actions'] ?? json['actions'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}

enum GuildType {
  merchant,
  warrior,
  artisan,
  scholar,
  religious,
  thieves,
  unknown;

  static GuildType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'merchant':
        return GuildType.merchant;
      case 'warrior':
        return GuildType.warrior;
      case 'artisan':
        return GuildType.artisan;
      case 'scholar':
        return GuildType.scholar;
      case 'religious':
        return GuildType.religious;
      case 'thieves':
        return GuildType.thieves;
      default:
        return GuildType.unknown;
    }
  }

  String get displayName {
    switch (this) {
      case GuildType.merchant:
        return 'Merchant';
      case GuildType.warrior:
        return 'Warrior';
      case GuildType.artisan:
        return 'Artisan';
      case GuildType.scholar:
        return 'Scholar';
      case GuildType.religious:
        return 'Religious';
      case GuildType.thieves:
        return 'Thieves';
      case GuildType.unknown:
        return 'Unknown';
    }
  }
}

enum GuildStatus {
  peaceful,
  atWar,
  outlawed,
  rising,
  declining,
  unknown;

  static GuildStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'peaceful':
        return GuildStatus.peaceful;
      case 'at_war':
      case 'atwar':
        return GuildStatus.atWar;
      case 'outlawed':
        return GuildStatus.outlawed;
      case 'rising':
        return GuildStatus.rising;
      case 'declining':
        return GuildStatus.declining;
      default:
        return GuildStatus.unknown;
    }
  }

  String get displayName {
    switch (this) {
      case GuildStatus.peaceful:
        return 'Peaceful';
      case GuildStatus.atWar:
        return 'At War';
      case GuildStatus.outlawed:
        return 'Outlawed';
      case GuildStatus.rising:
        return 'Rising';
      case GuildStatus.declining:
        return 'Declining';
      case GuildStatus.unknown:
        return 'Unknown';
    }
  }
}

class Guild {
  final String id;
  final String name;
  final GuildType type;
  final String settlementBase;
  final double influenceScore;
  final double stability;
  final int size;
  final GuildStatus status;
  final List<String> keyEvents;
  final Map<String, dynamic> metadata;

  const Guild({
    required this.id,
    required this.name,
    required this.type,
    required this.settlementBase,
    required this.influenceScore,
    required this.stability,
    required this.size,
    required this.status,
    required this.keyEvents,
    required this.metadata,
  });

  factory Guild.fromJson(Map<String, dynamic> json) {
    return Guild(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Guild',
      type: GuildType.fromString(json['type']?.toString() ?? 'unknown'),
      settlementBase: json['settlement_base']?.toString() ?? json['base']?.toString() ?? '',
      influenceScore: (json['influence_score'] ?? json['influence'] ?? 0.0).toDouble(),
      stability: (json['stability'] ?? 0.0).toDouble(),
      size: json['size'] ?? json['member_count'] ?? 0,
      status: GuildStatus.fromString(json['status']?.toString() ?? 'unknown'),
      keyEvents: List<String>.from(json['key_events'] ?? json['events'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}

enum EventType {
  guild,
  faction,
  trade,
  political,
  combat,
  diplomatic,
  economic,
  unknown;

  static EventType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'guild':
        return EventType.guild;
      case 'faction':
        return EventType.faction;
      case 'trade':
        return EventType.trade;
      case 'political':
        return EventType.political;
      case 'combat':
        return EventType.combat;
      case 'diplomatic':
        return EventType.diplomatic;
      case 'economic':
        return EventType.economic;
      default:
        return EventType.unknown;
    }
  }

  String get displayName {
    switch (this) {
      case EventType.guild:
        return 'Guild';
      case EventType.faction:
        return 'Faction';
      case EventType.trade:
        return 'Trade';
      case EventType.political:
        return 'Political';
      case EventType.combat:
        return 'Combat';
      case EventType.diplomatic:
        return 'Diplomatic';
      case EventType.economic:
        return 'Economic';
      case EventType.unknown:
        return 'Unknown';
    }
  }
}

class GameEvent {
  final String id;
  final EventType type;
  final String title;
  final String summary;
  final DateTime timestamp;
  final int tick;
  final List<String> affectedEntities;
  final Map<String, dynamic> details;

  const GameEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.summary,
    required this.timestamp,
    required this.tick,
    required this.affectedEntities,
    required this.details,
  });

  factory GameEvent.fromJson(Map<String, dynamic> json) {
    return GameEvent(
      id: json['id']?.toString() ?? '',
      type: EventType.fromString(json['type']?.toString() ?? 'unknown'),
      title: json['title']?.toString() ?? json['name']?.toString() ?? 'Unknown Event',
      summary: json['summary']?.toString() ?? json['description']?.toString() ?? '',
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
      tick: json['tick'] ?? 0,
      affectedEntities: List<String>.from(json['affected_entities'] ?? json['entities'] ?? []),
      details: Map<String, dynamic>.from(json['details'] ?? json['metadata'] ?? {}),
    );
  }
}

class EventFilters {
  final Set<EventType> types;
  final int maxResults;
  final DateTime? startDate;
  final DateTime? endDate;

  const EventFilters({
    this.types = const {},
    this.maxResults = 50,
    this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    
    if (types.isNotEmpty) {
      params['types'] = types.map((t) => t.name).join(',');
    }
    
    params['limit'] = maxResults;
    
    if (startDate != null) {
      params['start_date'] = startDate!.toIso8601String();
    }
    
    if (endDate != null) {
      params['end_date'] = endDate!.toIso8601String();
    }
    
    return params;
  }

  EventFilters copyWith({
    Set<EventType>? types,
    int? maxResults,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return EventFilters(
      types: types ?? this.types,
      maxResults: maxResults ?? this.maxResults,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
} 