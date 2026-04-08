import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:stitch/main.dart';
import 'package:stitch/models/entry.dart';
import 'package:stitch/theme/app_theme.dart';
import 'package:stitch/widgets/app_top_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = MoodScope.of(context).moodRepository;
    
    return ListenableBuilder(
      listenable: repository,
      builder: (context, _) {
        final lastEntry = repository.entries.isNotEmpty ? repository.entries.first : null;
        
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: const AppTopBar(title: 'Laune'),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreeting(context),
                  const SizedBox(height: 32),
                  _buildInteractionCard(context, lastEntry),
                  const SizedBox(height: 32),
                  _buildStatsGrid(context, repository.entries),
                  const SizedBox(height: 32),
                  _buildTopTags(context, repository.entries),
                  const SizedBox(height: 32),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGreeting(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat('EEEE, MMM dd').format(DateTime.now()),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Good Morning, ${MoodScope.of(context).authRepository.userName ?? 'Alex'}!',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ],
    );
  }

  Widget _buildInteractionCard(BuildContext context, Entry? lastEntry) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          height: 220,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
                Colors.transparent,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                lastEntry == null ? 'How are you today?' : 'Feeling ${lastEntry.mood.label}?',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                lastEntry == null 
                  ? 'Take a moment to check in.' 
                  : 'Your last check-in was ${DateFormat('hh:mm a').format(lastEntry.timestamp)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Positioned(
          bottom: -24,
          left: 0,
          right: 0,
          child: Center(
            child: ElevatedButton.icon(
              onPressed: () => context.push('/new-entry'),
              icon: const Icon(Icons.add),
              label: const Text('Quick Log'),
              style: ElevatedButton.styleFrom(
                shadowColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.15),
                elevation: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, List<Entry> entries) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final recentEntries = entries.where((e) => e.timestamp.isAfter(weekAgo)).toList();

    String weeklyAvgDisplay = 'N/A';
    if (recentEntries.isNotEmpty) {
      final moodCounts = <MoodType, int>{};
      for (var entry in recentEntries) {
        moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
      }
      
      // Find the most frequent mood (Mode instead of Mean)
      final mostFrequentMood = moodCounts.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
          
      weeklyAvgDisplay = '${mostFrequentMood.label} ${mostFrequentMood.emoji}';
    }

    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            context,
            icon: Icons.local_fire_department,
            iconColor: Colors.orange,
            label: 'Streak',
            value: '${MoodScope.of(context).moodRepository.streak} Days 🔥',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatItem(
            context,
            icon: Icons.star_border,
            iconColor: Theme.of(context).colorScheme.primary,
            label: 'Top This Week',
            value: weeklyAvgDisplay,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 20),
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontSize: 10,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopTags(BuildContext context, List<Entry> entries) {
    // Generate actual top tags from entries
    final tagCounts = <String, int>{};
    for (var entry in entries) {
      for (var tag in entry.tags) {
        tagCounts[tag.name] = (tagCounts[tag.name] ?? 0) + 1;
      }
    }
    final sortedTags = tagCounts.keys.toList()
      ..sort((a, b) => tagCounts[b]!.compareTo(tagCounts[a]!));
    final displayTags = sortedTags.take(5).toList();
    
    if (displayTags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Top Tags',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () => context.go('/history'),
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemCount: displayTags.length,
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Center(
                  child: Text(
                    displayTags[index].startsWith('#') ? displayTags[index] : '#${displayTags[index]}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

}
