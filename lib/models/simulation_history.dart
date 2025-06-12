import 'world_state.dart';

class TickSnapshot {
  final int tick;
  final int day;
  final WorldState worldState;
  final Map<String, dynamic> metadata;

  const TickSnapshot({
    required this.tick,
    required this.day,
    required this.worldState,
    required this.metadata,
  });

  factory TickSnapshot.fromJson(Map<String, dynamic> json) {
    return TickSnapshot(
      tick: json['tick'] ?? json['current_tick'] ?? 0,
      day: json['day'] ?? json['current_day'] ?? 0,
      worldState: WorldState.fromJson(json),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  factory TickSnapshot.empty() {
    return TickSnapshot(
      tick: 0,
      day: 0,
      worldState: WorldState.empty(),
      metadata: const {},
    );
  }
}

class PopulationDataPoint {
  final int tick;
  final int day;
  final int totalPopulation;
  final Map<String, int> populationByTier;

  const PopulationDataPoint({
    required this.tick,
    required this.day,
    required this.totalPopulation,
    required this.populationByTier,
  });

  factory PopulationDataPoint.fromJson(Map<String, dynamic> json) {
    final populationByTier = <String, int>{};
    if (json['population_by_tier'] is Map) {
      final tierData = json['population_by_tier'] as Map;
      for (final entry in tierData.entries) {
        populationByTier[entry.key.toString()] = (entry.value ?? 0) as int;
      }
    }

    return PopulationDataPoint(
      tick: json['tick'] ?? 0,
      day: json['day'] ?? 0,
      totalPopulation: json['total_population'] ?? json['population'] ?? 0,
      populationByTier: populationByTier,
    );
  }
}

class PopulationCurveData {
  final List<PopulationDataPoint> dataPoints;
  final int maxTick;
  final int maxPopulation;

  const PopulationCurveData({
    required this.dataPoints,
    required this.maxTick,
    required this.maxPopulation,
  });

  factory PopulationCurveData.fromJson(Map<String, dynamic> json) {
    final dataPoints = <PopulationDataPoint>[];
    
    if (json['data_points'] is List) {
      for (final pointJson in json['data_points']) {
        if (pointJson is Map<String, dynamic>) {
          dataPoints.add(PopulationDataPoint.fromJson(pointJson));
        }
      }
    }

    int maxTick = 0;
    int maxPopulation = 0;
    
    for (final point in dataPoints) {
      if (point.tick > maxTick) maxTick = point.tick;
      if (point.totalPopulation > maxPopulation) maxPopulation = point.totalPopulation;
    }

    return PopulationCurveData(
      dataPoints: dataPoints,
      maxTick: json['max_tick'] ?? maxTick,
      maxPopulation: json['max_population'] ?? maxPopulation,
    );
  }

  factory PopulationCurveData.empty() {
    return const PopulationCurveData(
      dataPoints: [],
      maxTick: 0,
      maxPopulation: 0,
    );
  }
}

enum ExportType {
  worldCsv,
  tickLogJson,
  summaryReport;

  String get endpoint {
    switch (this) {
      case ExportType.worldCsv:
        return 'world';
      case ExportType.tickLogJson:
        return 'ticks';
      case ExportType.summaryReport:
        return 'summary';
    }
  }

  String get fileName {
    switch (this) {
      case ExportType.worldCsv:
        return 'world_export.csv';
      case ExportType.tickLogJson:
        return 'tick_log.json';
      case ExportType.summaryReport:
        return 'simulation_summary.txt';
    }
  }

  String get displayName {
    switch (this) {
      case ExportType.worldCsv:
        return 'World Data (CSV)';
      case ExportType.tickLogJson:
        return 'Tick Log (JSON)';
      case ExportType.summaryReport:
        return 'Summary Report';
    }
  }
} 