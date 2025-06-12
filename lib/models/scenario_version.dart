class ScenarioVersion {
  final String id;
  final String title;
  final String description;
  final List<String> majorChanges;
  final DateTime createdAt;
  final int versionNumber;
  final bool isActive;
  final Map<String, dynamic>? parameters;

  const ScenarioVersion({
    required this.id,
    required this.title,
    required this.description,
    required this.majorChanges,
    required this.createdAt,
    required this.versionNumber,
    required this.isActive,
    this.parameters,
  });

  factory ScenarioVersion.fromJson(Map<String, dynamic> json) {
    return ScenarioVersion(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      majorChanges: List<String>.from(json['major_changes'] as List),
      createdAt: DateTime.parse(json['created_at'] as String),
      versionNumber: json['version_number'] as int,
      isActive: json['is_active'] as bool,
      parameters: json['parameters'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'major_changes': majorChanges,
      'created_at': createdAt.toIso8601String(),
      'version_number': versionNumber,
      'is_active': isActive,
      'parameters': parameters,
    };
  }
} 