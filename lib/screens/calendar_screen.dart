import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stitch/main.dart';
import 'package:stitch/models/entry.dart';
import 'package:stitch/theme/app_theme.dart';
import 'package:stitch/widgets/app_top_bar.dart';
import 'package:go_router/go_router.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final repository = MoodScope.of(context).moodRepository;
    
    return ListenableBuilder(
      listenable: repository,
      builder: (context, _) {
        final entries = repository.entries;
        final selectedEntries = entries.where((e) => 
          e.timestamp.year == _selectedDate.year &&
          e.timestamp.month == _selectedDate.month &&
          e.timestamp.day == _selectedDate.day
        ).toList();

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: const AppTopBar(title: 'Laune'),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  _buildCalendarHeader(context),
                  const SizedBox(height: 32),
                  _buildHeatmap(context, entries),
                  const SizedBox(height: 48),
                  _buildDailySummary(context, selectedEntries),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalendarHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('MMMM yyyy').format(_selectedDate),
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            Text(
              'Emotional Landscape',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Row(
          children: [
            _buildNavButton(context, Icons.chevron_left, () {
              setState(() => _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1));
            }),
            const SizedBox(width: 8),
            _buildNavButton(context, Icons.chevron_right, () {
              setState(() => _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1));
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildNavButton(BuildContext context, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }

  Widget _buildHeatmap(BuildContext context, List<Entry> entries) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusExtraLarge),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _buildWeekdayHeader(context),
          const SizedBox(height: 16),
          _buildDaysGrid(context, entries),
          const SizedBox(height: 32),
          _buildLegend(context),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader(BuildContext context) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((day) => Expanded(
        child: Center(
          child: Text(
            day.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontSize: 10,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildDaysGrid(BuildContext context, List<Entry> entries) {
    final firstDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final lastDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    
    int firstWeekday = firstDayOfMonth.weekday;
    int daysInMonth = lastDayOfMonth.day;

    final List<int?> days = [];
    for (int i = 1; i < firstWeekday; i++) {
      days.add(null);
    }
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(i);
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final dayNum = days[index];
        if (dayNum == null) return const SizedBox.shrink();
        
        final date = DateTime(_selectedDate.year, _selectedDate.month, dayNum);
        final isSelected = date.year == _selectedDate.year && date.month == _selectedDate.month && date.day == _selectedDate.day;
        
        final dayEntries = entries.where((e) => 
          e.timestamp.year == date.year && e.timestamp.month == date.month && e.timestamp.day == date.day
        ).toList();

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final isFuture = date.isAfter(today);

        String? firstEmoji;
        if (dayEntries.isNotEmpty) {
          firstEmoji = dayEntries.first.mood.emoji;
        }

        Color bgColor = isSelected ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4) : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.05);
        
        if (firstEmoji != null) {
          bgColor = Colors.transparent;
        }

        Color textColor = Theme.of(context).colorScheme.onSurfaceVariant;
        if (isFuture) {
          textColor = Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3);
        }

        return GestureDetector(
          onTap: isFuture ? null : () => setState(() => _selectedDate = date),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              if (firstEmoji != null)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Transform.scale(
                      scale: firstEmoji == '🥳' ? 1.8 : 1.4,
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: Text(firstEmoji),
                      ),
                    ),
                  ),
                ),
              if (isSelected)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
                    ),
                  ),
                ),
              Text(
                '$dayNum',
                style: TextStyle(
                  color: firstEmoji != null ? Colors.white : textColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w800,
                  fontSize: 16,
                  shadows: firstEmoji != null 
                    ? const [Shadow(color: Colors.black87, blurRadius: 8, offset: Offset(0, 1))] 
                    : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _buildLegendItem(context, Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2), 'No Data'),
        _buildLegendItem(context, Theme.of(context).colorScheme.primary.withOpacity(0.1), 'Reflections Recorded'),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 9),
        ),
      ],
    );
  }

  Widget _buildDailySummary(BuildContext context, List<Entry> selectedEntries) {
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final isFuture = selectedDay.isAfter(today);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMMM d').format(_selectedDate),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  '${selectedEntries.length} entries recorded',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: scheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                ),
              ],
            ),
            if (!isFuture)
              IconButton.filled(
                onPressed: () {
                  final now = DateTime.now();
                  final fullDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, now.hour, now.minute, now.second);
                  context.push('/new-entry?date=${fullDate.toIso8601String()}');
                },
                icon: const Icon(Icons.add_circle_outline),
                style: IconButton.styleFrom(
                  backgroundColor: scheme.primary.withOpacity(0.1),
                  foregroundColor: scheme.primary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        if (selectedEntries.isEmpty)
          _buildEmptyState(context, isFuture)
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: selectedEntries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _buildEntryCard(context, selectedEntries[index]);
            },
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isFuture) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: scheme.surfaceVariant.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
        border: Border.all(color: scheme.outline.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Icon(
            isFuture ? Icons.lock_clock_outlined : Icons.auto_awesome_outlined, 
            size: 48, 
            color: scheme.primary.withOpacity(0.2)
          ),
          const SizedBox(height: 16),
          Text(
            isFuture ? 'Looking towards the future...' : 'A blank canvas for your thoughts.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            isFuture ? 'You can only record reflections on the present or past.' : 'How was today? Capture your moment.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildEntryCard(BuildContext context, Entry entry) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => context.push('/view-entry/${entry.id}'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
          border: Border.all(color: scheme.outline.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  entry.mood.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.mood.label,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        DateFormat('hh:mm a').format(entry.timestamp),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.note.isEmpty ? 'A quiet moment reflected.' : entry.note,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
