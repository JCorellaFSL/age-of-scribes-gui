enum SettlementTier {
  hamlet,
  village, 
  town,
  smallCity,
  largeCity;

  static SettlementTier fromString(String tier) {
    switch (tier.toLowerCase()) {
      case 'hamlet':
        return SettlementTier.hamlet;
      case 'village':
        return SettlementTier.village;
      case 'town':
        return SettlementTier.town;
      case 'smallcity':
      case 'small_city':
      case 'small city':
        return SettlementTier.smallCity;
      case 'largecity':
      case 'large_city':
      case 'large city':
        return SettlementTier.largeCity;
      default:
        return SettlementTier.hamlet;
    }
  }

  String get displayName {
    switch (this) {
      case SettlementTier.hamlet:
        return 'Hamlet';
      case SettlementTier.village:
        return 'Village';
      case SettlementTier.town:
        return 'Town';
      case SettlementTier.smallCity:
        return 'Small City';
      case SettlementTier.largeCity:
        return 'Large City';
    }
  }
}

class Settlement {
  final String id;
  final String name;
  final SettlementTier tier;
  final double x;
  final double y;
  final int population;
  final double stability;

  const Settlement({
    required this.id,
    required this.name,
    required this.tier,
    required this.x,
    required this.y,
    required this.population,
    required this.stability,
  });

  factory Settlement.fromJson(Map<String, dynamic> json) {
    return Settlement(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown',
      tier: SettlementTier.fromString(json['tier']?.toString() ?? 'hamlet'),
      x: (json['x'] ?? json['position']?['x'] ?? 0).toDouble(),
      y: (json['y'] ?? json['position']?['y'] ?? 0).toDouble(),
      population: json['population'] ?? 0,
      stability: (json['stability'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tier': tier.name,
      'x': x,
      'y': y,
      'population': population,
      'stability': stability,
    };
  }
}

class WorldState {
  final List<Settlement> settlements;
  final int currentTick;
  final int currentDay;
  final Map<String, dynamic> metadata;

  const WorldState({
    required this.settlements,
    required this.currentTick,
    required this.currentDay,
    required this.metadata,
  });

  factory WorldState.fromJson(Map<String, dynamic> json) {
    final settlementsList = <Settlement>[];
    
    // Try different possible keys for settlements data
    final settlementsData = json['settlements'] ?? 
                           json['cities'] ?? 
                           json['locations'] ?? 
                           [];
    
    if (settlementsData is List) {
      for (final settlementJson in settlementsData) {
        if (settlementJson is Map<String, dynamic>) {
          settlementsList.add(Settlement.fromJson(settlementJson));
        }
      }
    }

    return WorldState(
      settlements: settlementsList,
      currentTick: json['current_tick'] ?? json['tick'] ?? 0,
      currentDay: json['current_day'] ?? json['day'] ?? 0,
      metadata: Map<String, dynamic>.from(json)
        ..remove('settlements')
        ..remove('cities')
        ..remove('locations'),
    );
  }

  factory WorldState.empty() {
    return const WorldState(
      settlements: [],
      currentTick: 0,
      currentDay: 0,
      metadata: {},
    );
  }
} 