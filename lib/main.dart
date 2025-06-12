import 'package:flutter/material.dart';
import 'screens/sim_config_screen.dart';
import 'screens/world_view_screen.dart';
import 'screens/win_conditions_screen.dart';
import 'screens/simulation_history_screen.dart';
import 'screens/intel_events_screen.dart';
import 'screens/admin_tools_screen.dart';
import 'widgets/sim_status_bar.dart';

void main() {
  runApp(const ScribesEngineControlPanel());
}

class ScribesEngineControlPanel extends StatelessWidget {
  const ScribesEngineControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scribes Engine Control Panel',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late TabController _tabController;

  static const List<Widget> _screens = <Widget>[
    SimConfigScreen(),
    WorldViewScreen(),
    WinConditionsScreen(),
    SimulationHistoryScreen(),
    IntelEventsScreen(),
    AdminToolsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scribes Engine Control Panel'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 4,
      ),
      body: Column(
        children: [
          const SimStatusBar(),
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.settings),
            selectedIcon: Icon(Icons.settings),
            label: 'Sim Config',
          ),
          NavigationDestination(
            icon: Icon(Icons.public),
            selectedIcon: Icon(Icons.public),
            label: 'World View',
          ),
          NavigationDestination(
            icon: Icon(Icons.flag),
            selectedIcon: Icon(Icons.flag),
            label: 'Win Conditions',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            selectedIcon: Icon(Icons.history),
            label: 'History Tools',
          ),
          NavigationDestination(
            icon: Icon(Icons.event),
            selectedIcon: Icon(Icons.event),
            label: 'Intel & Events',
          ),
          NavigationDestination(
            icon: Icon(Icons.admin_panel_settings),
            selectedIcon: Icon(Icons.admin_panel_settings),
            label: 'Admin Tools',
          ),
        ],
      ),
    );
  }
}
