class SimParameters {
  final int simYears;
  final int tickSpeed;
  final String? seed;

  const SimParameters({
    required this.simYears,
    required this.tickSpeed,
    this.seed,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'simYears': simYears,
      'tickSpeed': tickSpeed,
    };
    
    if (seed != null && seed!.isNotEmpty) {
      data['seed'] = seed;
    }
    
    return data;
  }

  factory SimParameters.fromJson(Map<String, dynamic> json) {
    return SimParameters(
      simYears: json['simYears'] ?? 0,
      tickSpeed: json['tickSpeed'] ?? 0,
      seed: json['seed'],
    );
  }

  @override
  String toString() {
    return 'SimParameters(simYears: $simYears, tickSpeed: $tickSpeed, seed: $seed)';
  }
} 