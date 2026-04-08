import 'package:stitch/models/entry.dart';
import 'package:stitch/models/tag.dart';

class MockData {
  static final List<Tag> tags = [
    Tag(id: '1', name: 'work'),
    Tag(id: '2', name: 'sleep'),
    Tag(id: '3', name: 'exercise'),
    Tag(id: '4', name: 'meditation'),
    Tag(id: '5', name: 'creative'),
    Tag(id: '6', name: 'productive'),
    Tag(id: '7', name: 'rest'),
    Tag(id: '8', name: 'travel'),
    Tag(id: '9', name: 'nature'),
    Tag(id: '10', name: 'social'),
  ];

  static final List<Entry> entries = [
    Entry(
      id: '1',
      mood: MoodType.good,
      intensity: 4,
      note: 'Had an incredibly productive morning session. The sunrise was particularly beautiful today, which set a calm tone for the day.',
      tags: [tags[0], tags[5]],
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    Entry(
      id: '2',
      mood: MoodType.sad,
      intensity: 2,
      note: 'Feeling a bit drained after a long week. Just taking it slow this evening with some hot tea and reading.',
      tags: [tags[6], tags[1]],
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    ),
    Entry(
      id: '3',
      mood: MoodType.excited,
      intensity: 5,
      note: 'Finally booked the tickets for the summer retreat! Can\'t wait to disconnect and reconnect with nature.',
      tags: [tags[7], tags[8]],
      timestamp: DateTime.now().subtract(const Duration(days: 3, hours: 5)),
    ),
    Entry(
      id: '4',
      mood: MoodType.calm,
      intensity: 3,
      note: 'Morning meditation session was really grounding today. Everything feels clear.',
      tags: [tags[3]],
      timestamp: DateTime.now().subtract(const Duration(days: 4, hours: 1)),
    ),
    Entry(
      id: '5',
      mood: MoodType.happy,
      intensity: 4,
      note: 'Great dinner with friends. Felt very connected and heard.',
      tags: [tags[9]],
      timestamp: DateTime.now().subtract(const Duration(days: 5, hours: 6)),
    ),
    Entry(
      id: '6',
      mood: MoodType.strong,
      intensity: 5,
      note: 'Hit a new personal record at the gym today. Energy is through the roof!',
      tags: [tags[2]],
      timestamp: DateTime.now().subtract(const Duration(days: 6, hours: 3)),
    ),
    Entry(
      id: '7',
      mood: MoodType.neutral,
      intensity: 3,
      note: 'A quiet day at the office. Not much happened, but felt steady.',
      tags: [tags[0]],
      timestamp: DateTime.now().subtract(const Duration(days: 7, hours: 2)),
    ),
    Entry(
      id: '8',
      mood: MoodType.joyful,
      intensity: 5,
      note: 'Finished a big project at work. The relief and pride are immense.',
      tags: [tags[0], tags[5]],
      timestamp: DateTime.now().subtract(const Duration(days: 10, hours: 4)),
    ),
    Entry(
      id: '9',
      mood: MoodType.upset,
      intensity: 2,
      note: 'Small argument with a colleague today. Trying not to let it ruin my evening.',
      tags: [tags[0]],
      timestamp: DateTime.now().subtract(const Duration(days: 12, hours: 1)),
    ),
    Entry(
      id: '10',
      mood: MoodType.awful,
      intensity: 1,
      note: 'Bad night\'s sleep and a very stressful morning. Feeling completely overwhelmed.',
      tags: [tags[1], tags[6]],
      timestamp: DateTime.now().subtract(const Duration(days: 14, hours: 5)),
    ),
  ];
}
