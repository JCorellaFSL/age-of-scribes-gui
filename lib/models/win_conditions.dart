class WinConditions {
  final int? maxYears;
  final int? popThreshold;
  final int? collapseLimit;
  final List<String> requiredFactions;

  const WinConditions({
    this.maxYears,
    this.popThreshold,
    this.collapseLimit,
    this.requiredFactions = const [],
  });

  factory WinConditions.fromJson(Map<String, dynamic> json) {
    return WinConditions(
      maxYears: json['max_years'] ?? json['maxYears'],
      popThreshold: json['pop_threshold'] ?? json['population_threshold'] ?? json['popThreshold'],
      collapseLimit: json['collapse_limit'] ?? json['collapseLimit'],
      requiredFactions: List<String>.from(
        json['required_factions'] ?? json['requiredFactions'] ?? []
      ),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    
    if (maxYears != null) {
      json['max_years'] = maxYears;
    }
    if (popThreshold != null) {
      json['pop_threshold'] = popThreshold;
    }
    if (collapseLimit != null) {
      json['collapse_limit'] = collapseLimit;
    }
    if (requiredFactions.isNotEmpty) {
      json['required_factions'] = requiredFactions;
    }
    
    return json;
  }

  bool get isEmpty => 
      maxYears == null && 
      popThreshold == null && 
      collapseLimit == null && 
      requiredFactions.isEmpty;

  WinConditions copyWith({
    int? maxYears,
    int? popThreshold,
    int? collapseLimit,
    List<String>? requiredFactions,
  }) {
    return WinConditions(
      maxYears: maxYears ?? this.maxYears,
      popThreshold: popThreshold ?? this.popThreshold,
      collapseLimit: collapseLimit ?? this.collapseLimit,
      requiredFactions: requiredFactions ?? this.requiredFactions,
    );
  }
}

class Scenario {
  final String id;
  final String name;
  final String description;
  final WinConditions winConditions;
  final Map<String, dynamic> metadata;

  const Scenario({
    required this.id,
    required this.name,
    required this.description,
    required this.winConditions,
    this.metadata = const {},
  });

  factory Scenario.fromJson(Map<String, dynamic> json) {
    return Scenario(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unnamed Scenario',
      description: json['description']?.toString() ?? '',
      winConditions: WinConditions.fromJson(
        json['win_conditions'] ?? json['winConditions'] ?? {}
      ),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'win_conditions': winConditions.toJson(),
      'metadata': metadata,
    };
  }
} 