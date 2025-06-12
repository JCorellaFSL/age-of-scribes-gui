class SaveSlot {
  final String id;
  final String name;
  final DateTime timestamp;
  final int tick;
  final int totalPopulation;
  final String? description;

  const SaveSlot({
    required this.id,
    required this.name,
    required this.timestamp,
    required this.tick,
    required this.totalPopulation,
    this.description,
  });

  factory SaveSlot.fromJson(Map<String, dynamic> json) {
    return SaveSlot(
      id: json['id'] as String,
      name: json['name'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      tick: json['tick'] as int,
      totalPopulation: json['total_population'] as int,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'timestamp': timestamp.toIso8601String(),
      'tick': tick,
      'total_population': totalPopulation,
      'description': description,
    };
  }
} 