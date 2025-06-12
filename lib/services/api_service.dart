import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/sim_parameters.dart';
import '../models/tick_status_data.dart';
import '../models/world_state.dart';
import '../models/win_conditions.dart';
import '../models/simulation_history.dart';
import '../models/intelligence_data.dart';

class ApiService {
  static const String _baseUrl = 'http://localhost:5000/api'; // Fixed port to match API server
  
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  /// Health check endpoint
  static Future<Map<String, dynamic>?> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/health'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      debugPrint('Health check failed with status: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('Error checking API health: $e');
      return null;
    }
  }

  /// Initialize simulation
  static Future<bool> initializeSimulation() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/initialize'),
        headers: _headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      debugPrint('Initialize simulation failed with status: ${response.statusCode}');
      debugPrint('Response: ${response.body}');
      return false;
    } catch (e) {
      debugPrint('Error initializing simulation: $e');
      return false;
    }
  }

  /// Start simulation
  static Future<bool> startSimulation() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/start'),
        headers: _headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      debugPrint('Start simulation failed with status: ${response.statusCode}');
      debugPrint('Response: ${response.body}');
      return false;
    } catch (e) {
      debugPrint('Error starting simulation: $e');
      return false;
    }
  }

  /// Pause simulation
  static Future<bool> pauseSimulation() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/pause'),
        headers: _headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      debugPrint('Pause simulation failed with status: ${response.statusCode}');
      debugPrint('Response: ${response.body}');
      return false;
    } catch (e) {
      debugPrint('Error pausing simulation: $e');
      return false;
    }
  }

  /// Execute single simulation step
  static Future<bool> stepSimulation() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/step'),
        headers: _headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      debugPrint('Step simulation failed with status: ${response.statusCode}');
      debugPrint('Response: ${response.body}');
      return false;
    } catch (e) {
      debugPrint('Error stepping simulation: $e');
      return false;
    }
  }

  /// Start auto-tick mode
  static Future<bool> startAutoTick() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auto-tick/start'),
        headers: _headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      debugPrint('Start auto-tick failed with status: ${response.statusCode}');
      debugPrint('Response: ${response.body}');
      return false;
    } catch (e) {
      debugPrint('Error starting auto-tick: $e');
      return false;
    }
  }

  /// Sets simulation parameters via POST /api/parameters
  static Future<bool> setSimulationParameters(SimParameters parameters) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/parameters'),
        headers: _headers,
        body: jsonEncode(parameters.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      debugPrint('Set parameters failed with status: ${response.statusCode}');
      debugPrint('Response: ${response.body}');
      return false;
    } catch (e) {
      debugPrint('Error setting simulation parameters: $e');
      return false;
    }
  }

  /// Fetches current simulation status
  static Future<Map<String, dynamic>?> fetchStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/status'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      debugPrint('Fetch status failed with status: ${response.statusCode}');
      debugPrint('Response: ${response.body}');
      return null;
    } catch (e) {
      debugPrint('Error fetching status: $e');
      return null;
    }
  }

  /// Fetches tick-specific status data for the status bar
  static Future<TickStatusData> fetchTickStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/status'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return TickStatusData.fromJson(data);
      }
      debugPrint('Fetch tick status failed with status: ${response.statusCode}');
      debugPrint('Response: ${response.body}');
      return TickStatusData.error();
    } catch (e) {
      debugPrint('Error fetching tick status: $e');
      return TickStatusData.error();
    }
  }

  /// Fetches world data (raw format for backwards compatibility)
  static Future<Map<String, dynamic>?> fetchWorld() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/world'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      debugPrint('Fetch world failed with status: ${response.statusCode}');
      debugPrint('Response: ${response.body}');
      return null;
    } catch (e) {
      debugPrint('Error fetching world data: $e');
      return null;
    }
  }

  /// Fetches structured world state with settlements
  static Future<WorldState> fetchWorldState() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/world'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return WorldState.fromJson(data);
      }
      debugPrint('Fetch world state failed with status: ${response.statusCode}');
      debugPrint('Response: ${response.body}');
      return WorldState.empty();
    } catch (e) {
      debugPrint('Error fetching world state: $e');
      return WorldState.empty();
    }
  }

  /// Fetches win conditions (raw format for backwards compatibility)
  static Future<Map<String, dynamic>?> fetchWinConditions() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/win-conditions'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      debugPrint('Fetch win conditions failed with status: ${response.statusCode}');
      debugPrint('Response: ${response.body}');
      return null;
    } catch (e) {
      debugPrint('Error fetching win conditions: $e');
      return null;
    }
  }

  /// Sets win conditions for the simulation
  static Future<bool> setWinConditions(WinConditions conditions) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/win-conditions'),
        headers: _headers,
        body: jsonEncode(conditions.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      debugPrint('Set win conditions failed with status: ${response.statusCode}');
      debugPrint('Response: ${response.body}');
      return false;
    } catch (e) {
      debugPrint('Error setting win conditions: $e');
      return false;
    }
  }

  /// Fetches list of available scenarios
  static Future<List<Scenario>> fetchScenarioList() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/scenarios'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final scenarios = <Scenario>[];
        
        if (data is List) {
          for (final scenarioJson in data) {
            if (scenarioJson is Map<String, dynamic>) {
              scenarios.add(Scenario.fromJson(scenarioJson));
            }
          }
        } else if (data is Map<String, dynamic> && data.containsKey('scenarios')) {
          final scenariosList = data['scenarios'];
          if (scenariosList is List) {
            for (final scenarioJson in scenariosList) {
              if (scenarioJson is Map<String, dynamic>) {
                scenarios.add(Scenario.fromJson(scenarioJson));
              }
            }
          }
        }
        
        return scenarios;
      }
      debugPrint('Fetch scenarios failed with status: ${response.statusCode}');
      debugPrint('Response: ${response.body}');
      return [];
    } catch (e) {
      debugPrint('Error fetching scenarios: $e');
      return [];
    }
  }

  /// Loads a scenario by ID
  static Future<bool> loadScenarioById(String scenarioId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/scenarios/$scenarioId/load'),
        headers: _headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      debugPrint('Load scenario failed with status: ${response.statusCode}');
      debugPrint('Response: ${response.body}');
      return false;
    } catch (e) {
      debugPrint('Error loading scenario: $e');
      return false;
    }
  }

  /// Fetches a historical tick snapshot
  static Future<TickSnapshot> fetchTickSnapshot(int tick) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/history/$tick'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return TickSnapshot.fromJson(data);
      }
      debugPrint('Fetch tick snapshot failed with status: ${response.statusCode}');
      debugPrint('Response: ${response.body}');
      return TickSnapshot.empty();
    } catch (e) {
      debugPrint('Error fetching tick snapshot: $e');
      return TickSnapshot.empty();
    }
  }

  /// Downloads export data and triggers browser download
  static Future<bool> downloadExport(ExportType exportType) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/export/${exportType.endpoint}'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        _triggerDownload(response.bodyBytes, exportType.fileName);
        return true;
      }
      debugPrint('Download export failed with status: ${response.statusCode}');
      debugPrint('Response: ${response.body}');
      return false;
    } catch (e) {
      debugPrint('Error downloading export: $e');
      return false;
    }
  }

  /// Fetches population curve data for graphing
  static Future<PopulationCurveData> fetchPopulationGraphData() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/metrics/population_curve'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return PopulationCurveData.fromJson(data);
      }
      debugPrint('Fetch population graph data failed with status: ${response.statusCode}');
      debugPrint('Response: ${response.body}');
      return PopulationCurveData.empty();
    } catch (e) {
      debugPrint('Error fetching population graph data: $e');
      return PopulationCurveData.empty();
    }
  }

  /// Fetches list of active factions
  static Future<List<Faction>> fetchFactions() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/factions'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final factions = <Faction>[];
        
        if (data is List) {
          for (final factionJson in data) {
            if (factionJson is Map<String, dynamic>) {
              factions.add(Faction.fromJson(factionJson));
            }
          }
        } else if (data is Map<String, dynamic> && data.containsKey('factions')) {
          final factionsList = data['factions'];
          if (factionsList is List) {
            for (final factionJson in factionsList) {
              if (factionJson is Map<String, dynamic>) {
                factions.add(Faction.fromJson(factionJson));
              }
            }
          }
        }
        
        return factions;
      }
      debugPrint('Fetch factions failed with status: ${response.statusCode}');
      debugPrint('Response: ${response.body}');
      return [];
    } catch (e) {
      debugPrint('Error fetching factions: $e');
      return [];
    }
  }

  /// Fetches list of active guilds
  static Future<List<Guild>> fetchGuilds() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/guilds'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final guilds = <Guild>[];
        
        if (data is List) {
          for (final guildJson in data) {
            if (guildJson is Map<String, dynamic>) {
              guilds.add(Guild.fromJson(guildJson));
            }
          }
        } else if (data is Map<String, dynamic> && data.containsKey('guilds')) {
          final guildsList = data['guilds'];
          if (guildsList is List) {
            for (final guildJson in guildsList) {
              if (guildJson is Map<String, dynamic>) {
                guilds.add(Guild.fromJson(guildJson));
              }
            }
          }
        }
        
        return guilds;
      }
      debugPrint('Fetch guilds failed with status: ${response.statusCode}');
      debugPrint('Response: ${response.body}');
      return [];
    } catch (e) {
      debugPrint('Error fetching guilds: $e');
      return [];
    }
  }

  /// Fetches recent events with optional filtering
  static Future<List<GameEvent>> fetchRecentEvents([EventFilters? filters]) async {
    try {
      var uri = Uri.parse('$_baseUrl/events/recent');
      
      if (filters != null) {
        final queryParams = filters.toQueryParams();
        if (queryParams.isNotEmpty) {
          uri = uri.replace(queryParameters: queryParams.map(
            (key, value) => MapEntry(key, value.toString())
          ));
        }
      }

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final events = <GameEvent>[];
        
        if (data is List) {
          for (final eventJson in data) {
            if (eventJson is Map<String, dynamic>) {
              events.add(GameEvent.fromJson(eventJson));
            }
          }
        } else if (data is Map<String, dynamic> && data.containsKey('events')) {
          final eventsList = data['events'];
          if (eventsList is List) {
            for (final eventJson in eventsList) {
              if (eventJson is Map<String, dynamic>) {
                events.add(GameEvent.fromJson(eventJson));
              }
            }
          }
        }
        
        return events;
      }
      debugPrint('Fetch recent events failed with status: ${response.statusCode}');
      debugPrint('Response: ${response.body}');
      return [];
    } catch (e) {
      debugPrint('Error fetching recent events: $e');
      return [];
    }
  }

  /// Triggers file download in web browser
  static void _triggerDownload(List<int> bytes, String fileName) {
    if (kIsWeb) {
      // Web-specific download implementation
      // Note: In production, you'd use dart:html for web downloads
      // For now, this is a placeholder that logs the action
      debugPrint('Triggering download for $fileName (${bytes.length} bytes)');
      // In real implementation:
      // final blob = html.Blob([bytes]);
      // final url = html.Url.createObjectUrlFromBlob(blob);
      // final anchor = html.AnchorElement(href: url)
      //   ..setAttribute('download', fileName)
      //   ..click();
      // html.Url.revokeObjectUrl(url);
    } else {
      // Desktop/mobile implementation would save to downloads folder
      debugPrint('Saving file $fileName (${bytes.length} bytes) to downloads');
    }
  }

  /// Generic method to handle API errors with detailed logging
  static void _logApiError(String endpoint, int statusCode, String responseBody) {
    debugPrint('API Error on $endpoint:');
    debugPrint('Status Code: $statusCode');
    debugPrint('Response: $responseBody');
  }

  // Admin Tools methods

  /// Triggers a forced event via POST /api/admin/trigger-event
  static Future<bool> triggerEvent(Map<String, dynamic> eventData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/admin/trigger-event'),
        headers: _headers,
        body: jsonEncode(eventData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      debugPrint('Trigger event failed with status: ${response.statusCode}');
      debugPrint('Response: ${response.body}');
      return false;
    } catch (e) {
      debugPrint('Error triggering event: $e');
      return false;
    }
  }

  /// Injects a rumor via POST /api/admin/inject-rumor
  static Future<bool> injectRumor(Map<String, dynamic> rumorData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/admin/inject-rumor'),
        headers: _headers,
        body: jsonEncode(rumorData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      debugPrint('Inject rumor failed with status: ${response.statusCode}');
      debugPrint('Response: ${response.body}');
      return false;
    } catch (e) {
      debugPrint('Error injecting rumor: $e');
      return false;
    }
  }

  /// Fetches NPC trace data via GET /api/npc/{id}/trace
  static Future<Map<String, dynamic>?> fetchNpcTrace(String npcId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/npc/$npcId/trace'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      debugPrint('Fetch NPC trace failed with status: ${response.statusCode}');
      debugPrint('Response: ${response.body}');
      return null;
    } catch (e) {
      debugPrint('Error fetching NPC trace: $e');
      return null;
    }
  }

  /// Flags an NPC for debug monitoring
  static Future<bool> flagNpcForDebug(String npcId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/admin/flag-npc-debug'),
        headers: _headers,
        body: jsonEncode({'npc_id': npcId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      debugPrint('Flag NPC for debug failed with status: ${response.statusCode}');
      debugPrint('Response: ${response.body}');
      return false;
    } catch (e) {
      debugPrint('Error flagging NPC for debug: $e');
      return false;
    }
  }
} 