import 'package:stitch/models/tag.dart';

enum MoodType {
  awful('😭', 'Awful'),
  sad('😞', 'Sad'),
  upset('😟', 'Upset'),
  neutral('😐', 'Neutral'),
  good('😊', 'Good'),
  calm('😌', 'Calm'),
  happy('😄', 'Happy'),
  excited('🤩', 'Excited'),
  strong('💪', 'Strong'),
  joyful('🥳', 'Joyful');

  final String emoji;
  final String label;
  const MoodType(this.emoji, this.label);

  static MoodType fromName(String name) {
    return MoodType.values.firstWhere((e) => e.name == name);
  }
}

class Entry {
  final String id;
  final MoodType mood;
  final int intensity;
  final String note;
  final List<Tag> tags;
  final DateTime timestamp;

  Entry({
    required this.id,
    required this.mood,
    required this.intensity,
    required this.note,
    required this.tags,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'mood': mood.name,
        'intensity': intensity,
        'note': note,
        'tags': tags.map((t) => t.toJson()).toList(),
        'timestamp': timestamp.toIso8601String(),
      };

  factory Entry.fromJson(Map<String, dynamic> json) => Entry(
        id: json['id'],
        mood: MoodType.fromName(json['mood']),
        intensity: json['intensity'],
        note: json['note'],
        tags: (json['tags'] as List).map((t) => Tag.fromJson(t)).toList(),
        timestamp: DateTime.parse(json['timestamp']),
      );

  Entry copyWith({
    String? id,
    MoodType? mood,
    int? intensity,
    String? note,
    List<Tag>? tags,
    DateTime? timestamp,
  }) {
    return Entry(
      id: id ?? this.id,
      mood: mood ?? this.mood,
      intensity: intensity ?? this.intensity,
      note: note ?? this.note,
      tags: tags ?? this.tags,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
