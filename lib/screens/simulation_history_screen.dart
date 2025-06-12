import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/simulation_history.dart';
import '../models/world_state.dart';
import '../services/api_service.dart';

class SimulationHistoryScreen extends StatefulWidget {
  const SimulationHistoryScreen({super.key});

  @override
  State<SimulationHistoryScreen> createState() => _SimulationHistoryScreenState();
}

class _SimulationHistoryScreenState extends State<SimulationHistoryScreen> {
  // Replay state
  int _currentTick = 0;
  int _maxTick = 1000;
  TickSnapshot _currentSnapshot = TickSnapshot.empty();
  bool _isLoadingSnapshot = false;
  String? _replayError;

  // Export state
  bool _isExporting = false;
  ExportType? _exportingType;
  String? _exportError;

  // Graph state
  PopulationCurveData _populationData = PopulationCurveData.empty();
  bool _isLoadingGraph = false;
  String? _graphError;

  // Canvas configuration for world map
  static const double canvasSize = 400.0;
  static const int gridSize = 50;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadCurrentSnapshot(),
      _loadPopulationData(),
    ]);
  }

  Future<void> _loadCurrentSnapshot() async {
    setState(() {
      _isLoadingSnapshot = true;
      _replayError = null;
    });

    try {
      final snapshot = await ApiService.fetchTickSnapshot(_currentTick);
      if (mounted) {
        setState(() {
          _currentSnapshot = snapshot;
          _isLoadingSnapshot = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _replayError = e.toString();
          _isLoadingSnapshot = false;
        });
      }
    }
  }

  Future<void> _loadPopulationData() async {
    setState(() {
      _isLoadingGraph = true;
      _graphError = null;
    });

    try {
      final data = await ApiService.fetchPopulationGraphData();
      if (mounted) {
        setState(() {
          _populationData = data;
          _maxTick = data.maxTick > 0 ? data.maxTick : 1000;
          _isLoadingGraph = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _graphError = e.toString();
          _isLoadingGraph = false;
        });
      }
    }
  }

  Future<void> _onTickChanged(double value) async {
    final newTick = value.round();
    if (newTick != _currentTick) {
      setState(() {
        _currentTick = newTick;
      });
      await _loadCurrentSnapshot();
    }
  }

  Future<void> _exportData(ExportType exportType) async {
    setState(() {
      _isExporting = true;
      _exportingType = exportType;
      _exportError = null;
    });

    try {
      final success = await ApiService.downloadExport(exportType);
      
      if (mounted) {
        setState(() {
          _isExporting = false;
          _exportingType = null;
        });

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${exportType.displayName} downloaded successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          setState(() {
            _exportError = 'Failed to download ${exportType.displayName}';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _exportError = 'Error: ${e.toString()}';
          _isExporting = false;
          _exportingType = null;
        });
      }
    }
  }

  Color _getSettlementColor(SettlementTier tier) {
    switch (tier) {
      case SettlementTier.hamlet:
        return Colors.grey;
      case SettlementTier.village:
        return Colors.green;
      case SettlementTier.town:
        return Colors.blue;
      case SettlementTier.smallCity:
        return Colors.purple;
      case SettlementTier.largeCity:
        return Colors.amber;
    }
  }

  double _getSettlementSize(SettlementTier tier) {
    switch (tier) {
      case SettlementTier.hamlet:
        return 4.0;
      case SettlementTier.village:
        return 6.0;
      case SettlementTier.town:
        return 8.0;
      case SettlementTier.smallCity:
        return 10.0;
      case SettlementTier.largeCity:
        return 12.0;
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
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column: Replay and Export tools
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _buildReplaySection(),
                      const SizedBox(height: 16),
                      _buildExportSection(),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Right column: World preview and graph
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildWorldPreview(),
                      const SizedBox(height: 16),
                      _buildPopulationGraph(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Simulation History Tools',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        Text(
          'Review simulation history, export data, and analyze trends',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildReplaySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tick Replay',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Text(
              'Current Tick: $_currentTick',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Day: ${_currentSnapshot.day}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            // Tick slider
            Column(
              children: [
                Slider(
                  value: _currentTick.toDouble(),
                  min: 0,
                  max: _maxTick.toDouble(),
                  divisions: _maxTick > 100 ? 100 : _maxTick,
                  label: _currentTick.toString(),
                  onChanged: _isLoadingSnapshot ? null : (value) => _onTickChanged(value),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '0',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '$_maxTick',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_isLoadingSnapshot) ...[
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text('Loading snapshot...'),
                  ],
                ),
              ),
            ] else if (_replayError != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  _replayError!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Snapshot Info',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text('Settlements: ${_currentSnapshot.worldState.settlements.length}'),
                    Text('Population: ${_currentSnapshot.worldState.settlements.fold<int>(0, (sum, s) => sum + s.population)}'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExportSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.download,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Export Tools',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_exportError != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  _exportError!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            ...ExportType.values.map((exportType) {
              final isExporting = _isExporting && _exportingType == exportType;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isExporting ? null : () => _exportData(exportType),
                    icon: isExporting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.file_download),
                    label: Text(
                      isExporting 
                          ? 'Exporting...' 
                          : exportType.displayName,
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildWorldPreview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'World Preview (Tick $_currentTick)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Center(
              child: Container(
                width: canvasSize,
                height: canvasSize,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CustomPaint(
                    size: const Size(canvasSize, canvasSize),
                    painter: WorldMapPainter(
                      settlements: _currentSnapshot.worldState.settlements,
                      selectedSettlement: null,
                      getSettlementColor: _getSettlementColor,
                      getSettlementSize: _getSettlementSize,
                      gridSize: gridSize,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopulationGraph() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Population Over Time',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            SizedBox(
              height: 300,
              child: _isLoadingGraph
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 8),
                          Text('Loading graph data...'),
                        ],
                      ),
                    )
                  : _graphError != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Theme.of(context).colorScheme.error,
                                size: 48,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Failed to load graph data',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: _loadPopulationData,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _populationData.dataPoints.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No population data available',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : LineChart(
                              LineChartData(
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: true,
                                  horizontalInterval: _populationData.maxPopulation / 5,
                                  verticalInterval: _populationData.maxTick / 10,
                                  getDrawingHorizontalLine: (value) {
                                    return FlLine(
                                      color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                                      strokeWidth: 1,
                                    );
                                  },
                                  getDrawingVerticalLine: (value) {
                                    return FlLine(
                                      color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                                      strokeWidth: 1,
                                    );
                                  },
                                ),
                                titlesData: FlTitlesData(
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 30,
                                      interval: _populationData.maxTick / 5,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          value.toInt().toString(),
                                          style: Theme.of(context).textTheme.bodySmall,
                                        );
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 50,
                                      interval: _populationData.maxPopulation / 4,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          value.toInt().toString(),
                                          style: Theme.of(context).textTheme.bodySmall,
                                        );
                                      },
                                    ),
                                  ),
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                borderData: FlBorderData(
                                  show: true,
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                                minX: 0,
                                maxX: _populationData.maxTick.toDouble(),
                                minY: 0,
                                maxY: _populationData.maxPopulation.toDouble() * 1.1,
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: _populationData.dataPoints.map((point) {
                                      return FlSpot(
                                        point.tick.toDouble(),
                                        point.totalPopulation.toDouble(),
                                      );
                                    }).toList(),
                                    isCurved: true,
                                    gradient: LinearGradient(
                                      colors: [
                                        Theme.of(context).colorScheme.primary,
                                        Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                      ],
                                    ),
                                    barWidth: 3,
                                    isStrokeCapRound: true,
                                    dotData: const FlDotData(show: false),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      gradient: LinearGradient(
                                        colors: [
                                          Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                          Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class WorldMapPainter extends CustomPainter {
  final List<Settlement> settlements;
  final Settlement? selectedSettlement;
  final Color Function(SettlementTier) getSettlementColor;
  final double Function(SettlementTier) getSettlementSize;
  final int gridSize;

  WorldMapPainter({
    required this.settlements,
    required this.selectedSettlement,
    required this.getSettlementColor,
    required this.getSettlementSize,
    required this.gridSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    
    // Draw grid background
    paint.color = Colors.grey.withOpacity(0.1);
    paint.strokeWidth = 0.5;
    
    for (int i = 0; i <= gridSize; i++) {
      final pos = (i / gridSize) * size.width;
      canvas.drawLine(Offset(pos, 0), Offset(pos, size.height), paint);
      canvas.drawLine(Offset(0, pos), Offset(size.width, pos), paint);
    }

    // Draw settlements
    for (final settlement in settlements) {
      final x = (settlement.x / gridSize) * size.width;
      final y = (settlement.y / gridSize) * size.height;
      final settlementSize = getSettlementSize(settlement.tier);
      final isSelected = selectedSettlement?.id == settlement.id;

      // Draw selection highlight
      if (isSelected) {
        paint.color = Colors.white;
        paint.style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, y), settlementSize + 3, paint);
        
        paint.color = Colors.black;
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 2;
        canvas.drawCircle(Offset(x, y), settlementSize + 3, paint);
      }

      // Draw settlement
      paint.color = getSettlementColor(settlement.tier);
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), settlementSize, paint);
      
      // Draw border
      paint.color = Colors.black26;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 1;
      canvas.drawCircle(Offset(x, y), settlementSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 