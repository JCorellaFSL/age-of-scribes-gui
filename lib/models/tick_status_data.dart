class TickStatusData {
  final int currentTick;
  final int simDay;
  final String uptime;
  final int activeSettlements;
  final int activeNPCs;
  final bool isRunning;
  final bool hasError;

  const TickStatusData({
    required this.currentTick,
    required this.simDay,
    required this.uptime,
    required this.activeSettlements,
    required this.activeNPCs,
    required this.isRunning,
    this.hasError = false,
  });

  factory TickStatusData.fromJson(Map<String, dynamic> json) {
    return TickStatusData(
      currentTick: json['current_tick'] ?? json['tick'] ?? 0,
      simDay: json['sim_day'] ?? json['day'] ?? 0,
      uptime: json['uptime'] ?? 'Unknown',
      activeSettlements: json['active_settlements'] ?? json['settlements'] ?? 0,
      activeNPCs: json['active_npcs'] ?? json['npcs'] ?? 0,
      isRunning: json['is_running'] ?? json['running'] ?? false,
      hasError: false,
    );
  }

  factory TickStatusData.error() {
    return const TickStatusData(
      currentTick: 0,
      simDay: 0,
      uptime: 'Connection Error',
      activeSettlements: 0,
      activeNPCs: 0,
      isRunning: false,
      hasError: true,
    );
  }

  factory TickStatusData.loading() {
    return const TickStatusData(
      currentTick: 0,
      simDay: 0,
      uptime: 'Loading...',
      activeSettlements: 0,
      activeNPCs: 0,
      isRunning: false,
      hasError: false,
    );
  }
} 