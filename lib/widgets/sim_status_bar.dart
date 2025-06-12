import 'dart:async';
import 'package:flutter/material.dart';
import '../models/tick_status_data.dart';
import '../services/api_service.dart';

class SimStatusBar extends StatefulWidget {
  const SimStatusBar({super.key});

  @override
  State<SimStatusBar> createState() => _SimStatusBarState();
}

class _SimStatusBarState extends State<SimStatusBar>
    with SingleTickerProviderStateMixin {
  TickStatusData _statusData = TickStatusData.loading();
  Timer? _updateTimer;
  late AnimationController _tickAnimationController;
  late Animation<double> _tickAnimation;

  @override
  void initState() {
    super.initState();
    
    // Setup tick animation
    _tickAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _tickAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _tickAnimationController,
      curve: Curves.ease,
    ));

    // Start periodic updates
    _startStatusUpdates();
    
    // Initial load
    _fetchStatus();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _tickAnimationController.dispose();
    super.dispose();
  }

  void _startStatusUpdates() {
    _updateTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _fetchStatus();
    });
  }

  Future<void> _fetchStatus() async {
    final newStatus = await ApiService.fetchTickStatus();
    if (mounted) {
      setState(() {
        final wasRunning = _statusData.isRunning;
        _statusData = newStatus;
        
        // Trigger tick animation if simulation is running
        if (_statusData.isRunning && !_statusData.hasError) {
          if (!wasRunning || _statusData.currentTick > 0) {
            _tickAnimationController.forward().then((_) {
              if (mounted) _tickAnimationController.reset();
            });
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      height: 56,
      width: double.infinity,
      color: colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left side: Tick and Day info
            Row(
              children: [
                _buildStatusIndicator(),
                const SizedBox(width: 12),
                _buildTickInfo(),
                const SizedBox(width: 24),
                _buildDayInfo(),
              ],
            ),
            
            // Right side: Settlements and Uptime
            Row(
              children: [
                _buildSettlementsInfo(),
                const SizedBox(width: 24),
                _buildUptimeInfo(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    if (_statusData.hasError) {
      return Icon(
        Icons.error_outline,
        color: Theme.of(context).colorScheme.error,
        size: 20,
      );
    }
    
    if (_statusData.isRunning) {
      return AnimatedBuilder(
        animation: _tickAnimation,
        builder: (context, child) {
          return Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.withOpacity(0.3 + (_tickAnimation.value * 0.7)),
            ),
          );
        },
      );
    }
    
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.orange.withOpacity(0.7),
      ),
    );
  }

  Widget _buildTickInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tick ${_statusData.currentTick}',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          _statusData.isRunning ? 'Running' : 'Paused',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: _statusData.isRunning ? Colors.green : Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildDayInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Day ${_statusData.simDay}',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        Text(
          'Simulation',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildSettlementsInfo() {
    return Row(
      children: [
        Icon(
          Icons.location_city,
          size: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 4),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_statusData.activeSettlements} Settlements',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            Text(
              '${_statusData.activeNPCs} NPCs',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUptimeInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'Uptime',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          _statusData.uptime,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
} 