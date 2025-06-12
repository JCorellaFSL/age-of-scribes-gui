import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/world_state.dart';
import '../services/api_service.dart';

class WorldViewScreen extends StatefulWidget {
  const WorldViewScreen({super.key});

  @override
  State<WorldViewScreen> createState() => _WorldViewScreenState();
}

class _WorldViewScreenState extends State<WorldViewScreen> {
  WorldState _worldState = WorldState.empty();
  bool _isLoading = false;
  String? _error;
  Settlement? _selectedSettlement;
  Timer? _updateTimer;

  // Grid configuration
  static const int gridSize = 50;
  static const double canvasSize = 600.0;
  static const double cellSize = canvasSize / gridSize;

  @override
  void initState() {
    super.initState();
    _loadWorldData();
    _startPeriodicUpdates();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  void _startPeriodicUpdates() {
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_isLoading) {
        _loadWorldData();
      }
    });
  }

  Future<void> _loadWorldData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final worldState = await ApiService.fetchWorldState();
      if (mounted) {
        setState(() {
          _worldState = worldState;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
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

  void _onSettlementTap(Settlement? settlement) {
    setState(() {
      _selectedSettlement = settlement;
    });
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
          if (_isLoading && _worldState.settlements.isEmpty)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading world data...'),
                  ],
                ),
              ),
            )
          else if (_error != null)
            Expanded(
              child: Center(
                child: _buildErrorCard(),
              ),
            )
          else
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWorldCanvas(),
                  const SizedBox(width: 24),
                  _buildInfoPanel(),
                ],
              ),
            ),
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
              'World View',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            if (_worldState.settlements.isNotEmpty)
              Text(
                '${_worldState.settlements.length} settlements • Day ${_worldState.currentDay}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        Row(
          children: [
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            IconButton(
              onPressed: _isLoading ? null : _loadWorldData,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh World Data',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorCard() {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load world data',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadWorldData,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorldCanvas() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'World Map (${gridSize}x$gridSize)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildLegend(),
            const SizedBox(height: 16),
            Container(
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
                    settlements: _worldState.settlements,
                    selectedSettlement: _selectedSettlement,
                    getSettlementColor: _getSettlementColor,
                    getSettlementSize: _getSettlementSize,
                    gridSize: gridSize,
                  ),
                  child: GestureDetector(
                    onTapUp: (details) {
                      final RenderBox renderBox = context.findRenderObject() as RenderBox;
                      final localPosition = renderBox.globalToLocal(details.globalPosition);
                      
                      // Find tapped settlement
                      Settlement? tappedSettlement;
                      for (final settlement in _worldState.settlements) {
                        final settlementX = (settlement.x / gridSize) * canvasSize;
                        final settlementY = (settlement.y / gridSize) * canvasSize;
                        final distance = sqrt(
                          pow(localPosition.dx - settlementX, 2) + 
                          pow(localPosition.dy - settlementY, 2)
                        );
                        
                        if (distance <= _getSettlementSize(settlement.tier)) {
                          tappedSettlement = settlement;
                          break;
                        }
                      }
                      
                      _onSettlementTap(tappedSettlement);
                    },
                    child: MouseRegion(
                      onHover: (event) {
                        // Handle hover for desktop - could add hover preview
                      },
                      child: Container(
                        width: canvasSize,
                        height: canvasSize,
                        color: Colors.transparent,
                      ),
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

  Widget _buildLegend() {
    return Wrap(
      spacing: 16.0,
      runSpacing: 8.0,
      children: SettlementTier.values.map((tier) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: _getSettlementSize(tier),
              height: _getSettlementSize(tier),
              decoration: BoxDecoration(
                color: _getSettlementColor(tier),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              tier.displayName,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildInfoPanel() {
    return SizedBox(
      width: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWorldStats(),
          const SizedBox(height: 16),
          _buildSettlementDetails(),
        ],
      ),
    );
  }

  Widget _buildWorldStats() {
    final tierCounts = <SettlementTier, int>{};
    for (final settlement in _worldState.settlements) {
      tierCounts[settlement.tier] = (tierCounts[settlement.tier] ?? 0) + 1;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'World Statistics',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...SettlementTier.values.map((tier) {
              final count = tierCounts[tier] ?? 0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getSettlementColor(tier),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(tier.displayName)),
                    Text('$count'),
                  ],
                ),
              );
            }).toList(),
            const Divider(),
            Row(
              children: [
                const Expanded(child: Text('Total Settlements')),
                Text('${_worldState.settlements.length}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettlementDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settlement Details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (_selectedSettlement != null) ...[
              _buildDetailRow('Name', _selectedSettlement!.name),
              _buildDetailRow('Tier', _selectedSettlement!.tier.displayName),
              _buildDetailRow('Position', '(${_selectedSettlement!.x.toInt()}, ${_selectedSettlement!.y.toInt()})'),
              _buildDetailRow('Population', '${_selectedSettlement!.population}'),
              _buildDetailRow('Stability', '${(_selectedSettlement!.stability * 100).toInt()}%'),
            ] else
              Text(
                'Tap on a settlement to view details',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
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