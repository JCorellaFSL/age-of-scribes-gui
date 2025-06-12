# Age of Scribes SSE - Control Panel

A comprehensive Flutter web application for controlling and monitoring the Age of Scribes Social Simulation Engine (SSE). This control panel provides real-time visualization, debugging tools, and administrative controls for the simulation engine.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)

## 🎯 Overview

The Age of Scribes SSE Control Panel is a modern web-based interface built with Flutter that provides comprehensive control and monitoring capabilities for the Age of Scribes social simulation engine. It features real-time data visualization, administrative tools, and debugging utilities for simulation management.

## ✨ Features

### 🖥️ **Real-Time Simulation Control**
- **Live Status Bar**: Displays current tick, simulation day, active settlements, NPCs, and uptime
- **Simulation Controls**: Start, pause, step, and initialize simulation operations
- **Parameter Configuration**: Adjust simulation years, tick speed, and random seed
- **Auto-refresh**: Real-time updates every 2 seconds

### 🗺️ **World Visualization**
- **Interactive Grid Map**: 50x50 grid canvas showing settlement locations
- **Settlement Details**: Click settlements to view population, stability, and tier information
- **Color-coded Tiers**: Visual distinction between villages, towns, cities, and metropolises
- **Real-time Updates**: World state refreshes every 5 seconds

### 🎯 **Win Conditions Management**
- **Victory Conditions**: Configure population thresholds, faction requirements, and time limits
- **Scenario Management**: Load predefined scenarios with custom win conditions
- **Defeat Conditions**: Set collapse limits and failure states
- **Template System**: Save and load custom scenario configurations

### 📊 **Simulation History & Analytics**
- **Time Travel**: Browse historical simulation states by tick
- **Population Graphs**: Visualize population trends over time using interactive charts
- **Data Export**: Export world data (CSV), tick logs (JSON), and summary reports
- **Replay System**: Review and analyze past simulation states

### 🕵️ **Intelligence & Events**
- **Faction Intelligence**: Monitor faction activities, alliances, and reputation
- **Guild Monitoring**: Track guild operations, status, and member counts
- **Live Event Feed**: Real-time stream of simulation events with filtering
- **Expandable Details**: Deep-dive into faction ideologies and recent actions

### 🛠️ **Admin Tools** *(New!)*
- **Force Event Trigger**: Manually inject events (wars, disasters, coups) for testing
- **Rumor Injection**: Create and propagate custom rumors through the information network
- **NPC Trace View**: Deep inspection of individual NPCs including memory, loyalty, and reputation
- **Debug Monitoring**: Flag NPCs for detailed logging and debugging

## 🏗️ Architecture

### Frontend Stack
- **Framework**: Flutter 3.x (Web)
- **Language**: Dart
- **Charts**: FL Chart for data visualization
- **HTTP Client**: Built-in Dart HTTP package
- **State Management**: StatefulWidget with proper lifecycle management

### Backend Requirements
The control panel requires a REST API server running on `localhost:5000` with the following endpoints:

#### Core Simulation Endpoints
```
GET  /api/health           - Health check
POST /api/initialize       - Initialize simulation
POST /api/start           - Start simulation
POST /api/pause           - Pause simulation
POST /api/step            - Execute single step
POST /api/auto-tick/start - Start auto-tick mode
POST /api/parameters      - Set simulation parameters
GET  /api/status          - Get simulation status
```

#### Data Endpoints
```
GET /api/world                    - World state and settlements
GET /api/win-conditions          - Current win conditions
POST /api/win-conditions         - Set win conditions
GET /api/scenarios               - Available scenarios
POST /api/scenarios/{id}/load    - Load scenario
GET /api/history/{tick}          - Historical tick snapshot
GET /api/export/{type}           - Export data
GET /api/metrics/population_curve - Population graph data
```

#### Intelligence Endpoints
```
GET /api/factions           - Active factions
GET /api/guilds            - Active guilds  
GET /api/events/recent     - Recent events (with filtering)
```

#### Admin Endpoints *(New!)*
```
POST /api/admin/trigger-event    - Force trigger events
POST /api/admin/inject-rumor     - Inject custom rumors
GET  /api/npc/{id}/trace        - Get NPC trace data
POST /api/admin/flag-npc-debug  - Flag NPC for debug monitoring
```

### Data Models

#### Core Models
- `SimParameters`: Simulation configuration (years, tick speed, seed)
- `TickStatusData`: Real-time status information
- `WorldState`: Settlement data and world configuration
- `WinConditions`: Victory/defeat conditions and scenarios

#### Intelligence Models
- `Faction`: Faction data with alliances, reputation, and actions
- `Guild`: Guild information with status and member data
- `GameEvent`: Event data with timestamps and affected entities
- `EventFilters`: Event filtering and pagination

#### History Models
- `TickSnapshot`: Historical simulation state
- `PopulationCurveData`: Population trend data for graphs
- `ExportType`: Data export configurations

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.0+ 
- Dart SDK 3.0+
- Chrome browser (for web development)
- Age of Scribes SSE backend server

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/JCorellaFSL/age-of-scribes-gui.git
   cd age-of-scribes-gui
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run -d chrome
   ```

4. **Access the control panel**
   Open your browser and navigate to `http://localhost:port` (Flutter will display the port)

### Backend Setup
Ensure the Age of Scribes SSE backend server is running on `localhost:5000` before using the control panel. The application will display connection errors if the backend is unavailable.

## 📱 Usage Guide

### Navigation
The application uses a bottom navigation bar with six main sections:

1. **Sim Config** - Configure simulation parameters
2. **World View** - Visualize the simulation world
3. **Win Conditions** - Manage victory/defeat conditions  
4. **History Tools** - Review and export historical data
5. **Intel & Events** - Monitor factions, guilds, and events
6. **Admin Tools** - Advanced debugging and manual controls

### Basic Workflow

1. **Configure Simulation**
   - Set simulation years (default: 5)
   - Adjust tick speed (default: 10)
   - Optionally set a random seed

2. **Set Win Conditions**
   - Define population thresholds
   - Specify required factions
   - Set time limits
   - Or load a predefined scenario

3. **Initialize & Start**
   - Initialize the simulation engine
   - Start the simulation or use step-by-step mode
   - Monitor progress via the status bar

4. **Monitor & Analyze**
   - Watch real-time world changes
   - Track faction and guild activities
   - Review historical trends
   - Export data for analysis

5. **Debug & Test** *(Admin Tools)*
   - Force specific events for testing
   - Inject rumors to test information propagation
   - Inspect individual NPCs for debugging

## 🔧 Development

### Project Structure
```
lib/
├── main.dart                 # App entry point and navigation
├── models/                   # Data models and DTOs
│   ├── sim_parameters.dart
│   ├── tick_status_data.dart
│   ├── world_state.dart
│   ├── win_conditions.dart
│   ├── simulation_history.dart
│   └── intelligence_data.dart
├── screens/                  # Main application screens
│   ├── sim_config_screen.dart
│   ├── world_view_screen.dart
│   ├── win_conditions_screen.dart
│   ├── simulation_history_screen.dart
│   ├── intel_events_screen.dart
│   └── admin_tools_screen.dart
├── services/                 # Business logic and API
│   └── api_service.dart
└── widgets/                  # Reusable UI components
    └── sim_status_bar.dart
```

### Key Design Patterns
- **StatefulWidget**: Used for screens requiring state management
- **Future/async**: Asynchronous API operations with proper error handling
- **Timer**: Periodic updates for real-time data
- **TabController**: Multi-tab interfaces with proper lifecycle management
- **Form Validation**: Input validation for user forms

### Error Handling
- Comprehensive try-catch blocks for all API operations
- User-friendly error messages via SnackBar notifications
- Graceful degradation when backend is unavailable
- Loading states and progress indicators

## 🎨 UI/UX Features

### Material Design 3
- Modern dark theme with purple color scheme
- Consistent spacing and typography
- Responsive layout for different screen sizes
- Accessibility-friendly color contrasts

### Interactive Elements
- Hover effects and animations
- Click feedback and loading states
- Progress bars and charts
- Expandable detail views

### Data Visualization
- Real-time population graphs using FL Chart
- Interactive world map with clickable settlements
- Color-coded faction and guild status indicators
- Progress bars for reputation and loyalty scores

## 🚧 Known Limitations

- Backend dependency: Requires running SSE server on localhost:5000
- Web-only: Currently optimized for web browsers (Chrome recommended)
- No authentication: Admin tools accessible without login (intended for development)
- Limited offline functionality: Requires active API connection

## 🔄 Future Enhancements

- [ ] User authentication and role-based access
- [ ] Mobile responsive design
- [ ] WebSocket integration for real-time updates
- [ ] Advanced data filtering and search
- [ ] Export to additional formats (PDF, Excel)
- [ ] Simulation recording and playback
- [ ] Custom dashboard configurations
- [ ] Multi-server support

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the excellent web framework
- FL Chart library for beautiful data visualizations
- Age of Scribes SSE development team

---

**Note**: This control panel is designed specifically for the Age of Scribes Social Simulation Engine and requires the corresponding backend server to function properly.
