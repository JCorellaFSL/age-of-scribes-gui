class PatchNotes {
  final String version;
  final DateTime releaseDate;
  final List<String> featureChanges;
  final List<String> bugFixes;
  final List<String> backendNotes;
  final List<String> guildLogicUpdates;
  final List<String> aiUpdates;
  final List<String> factionBehaviorChanges;

  const PatchNotes({
    required this.version,
    required this.releaseDate,
    required this.featureChanges,
    required this.bugFixes,
    required this.backendNotes,
    required this.guildLogicUpdates,
    required this.aiUpdates,
    required this.factionBehaviorChanges,
  });

  factory PatchNotes.fromJson(Map<String, dynamic> json) {
    return PatchNotes(
      version: json['version'] as String,
      releaseDate: DateTime.parse(json['release_date'] as String),
      featureChanges: List<String>.from(json['feature_changes'] as List),
      bugFixes: List<String>.from(json['bug_fixes'] as List),
      backendNotes: List<String>.from(json['backend_notes'] as List),
      guildLogicUpdates: List<String>.from(json['guild_logic_updates'] as List),
      aiUpdates: List<String>.from(json['ai_updates'] as List),
      factionBehaviorChanges: List<String>.from(json['faction_behavior_changes'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'release_date': releaseDate.toIso8601String(),
      'feature_changes': featureChanges,
      'bug_fixes': bugFixes,
      'backend_notes': backendNotes,
      'guild_logic_updates': guildLogicUpdates,
      'ai_updates': aiUpdates,
      'faction_behavior_changes': factionBehaviorChanges,
    };
  }
} 