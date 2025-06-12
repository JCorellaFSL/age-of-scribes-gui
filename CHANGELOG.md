# Changelog

All notable changes to the Age of Scribes SSE Control Panel will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-28

### Added

#### Core Features
- Initial release of Age of Scribes SSE Control Panel
- Real-time simulation status bar with tick, day, settlements, NPCs, and uptime
- Six-tab navigation system with Material Design 3 theming

#### Simulation Configuration
- Parameter configuration screen for simulation years, tick speed, and random seed
- Initialize, start, pause, and step simulation controls
- API service integration with comprehensive error handling

#### World Visualization  
- Interactive 50x50 grid world map with clickable settlements
- Color-coded settlement tiers (village, town, city, metropolis)
- Real-time settlement details (population, stability, coordinates)
- Auto-refresh world state every 5 seconds

#### Win Conditions Management
- Victory condition configuration (population, factions, time limits)
- Defeat condition setup (collapse limits)
- Scenario management system with predefined templates
- Save and load custom scenario configurations

#### Simulation History & Analytics
- Historical tick browsing with time-travel functionality
- Interactive population trend graphs using FL Chart
- Data export capabilities (CSV, JSON, summary reports)
- Replay system for analyzing past simulation states

#### Intelligence & Events Monitoring
- Real-time faction intelligence with alliances and reputation tracking
- Guild monitoring with status and member information
- Live event feed with filtering and pagination
- Expandable detail views for factions and guilds

#### Admin Tools *(NEW)*
- **Force Event Trigger**: Manual event injection for testing
  - Support for 8 event types: Caravan Attack, Guild War, Plague Outbreak, Political Coup, Natural Disaster, Trade Embargo, Religious Schism, Bandit Uprising
  - Optional target specification (settlement, guild, faction)
  - Real-time success/failure feedback
- **Rumor Injection Tool**: Custom rumor creation and propagation
  - Subject targeting (NPC, Guild ID)
  - Multi-line rumor text input
  - Origin settlement specification
  - Credibility rating (0.0-1.0) with validation
- **NPC Trace View**: Deep NPC inspection and debugging
  - Search by NPC ID or name
  - Comprehensive NPC data display (faction, guild, career, location)
  - Recent memory history (last 10 events)
  - Loyalty and reputation progress bars
  - Associated rumors with credibility ratings
  - Debug flag functionality for monitoring

### Technical Implementation
- Flutter 3.x web application with Dart
- REST API integration with localhost:5000 backend
- Material Design 3 with dark theme and purple color scheme
- Comprehensive error handling and loading states
- Form validation and user input sanitization
- Real-time data updates with Timer-based refresh
- Modular component architecture with reusable widgets

### API Endpoints
- Core simulation endpoints (health, initialize, start, pause, step, auto-tick, parameters, status)
- Data endpoints (world, win-conditions, scenarios, history, export, metrics)
- Intelligence endpoints (factions, guilds, events)
- Admin endpoints (trigger-event, inject-rumor, npc-trace, flag-npc-debug)

### UI/UX Features
- Responsive design optimized for web browsers
- Interactive hover effects and animations
- Progress indicators and loading states
- SnackBar notifications for user feedback
- Tab-based navigation with proper lifecycle management
- Accessibility-friendly color contrasts and typography

### Documentation
- Comprehensive README with setup instructions
- API endpoint documentation
- Architecture overview and data models
- Usage guide and development notes
- Contributing guidelines and license information 