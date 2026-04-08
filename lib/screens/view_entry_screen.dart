import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:stitch/main.dart';
import 'package:stitch/models/entry.dart';
import 'package:stitch/theme/app_theme.dart';

class ViewEntryScreen extends StatelessWidget {
  final String entryId;

  const ViewEntryScreen({super.key, required this.entryId});

  @override
  Widget build(BuildContext context) {
    final repository = MoodScope.of(context).moodRepository;
    final entry = repository.getEntryById(entryId);

    if (entry == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Entry Not Found')),
        body: const Center(child: Text('The requested entry could not be found.')),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, entry),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIntensitySection(context, entry),
                  const SizedBox(height: 32),
                  _buildNoteSection(context, entry),
                  const SizedBox(height: 32),
                  _buildTagsSection(context, entry),
                  const SizedBox(height: 48),
                  _buildActions(context, entry),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, Entry entry) {
    return SliverAppBar(
      expandedHeight: 240.0,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
        style: IconButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.8),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    Theme.of(context).colorScheme.surface,
                  ],
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    entry.mood.emoji,
                    style: const TextStyle(fontSize: 80),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    entry.mood.label,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateFormat('EEEE, MMMM dd • hh:mm a').format(entry.timestamp),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntensitySection(BuildContext context, Entry entry) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: scheme.surfaceVariant.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Intensity Level',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                '${entry.intensity}/5',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: scheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: LinearProgressIndicator(
              value: entry.intensity / 5,
              minHeight: 12,
              backgroundColor: scheme.surfaceVariant.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation(scheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteSection(BuildContext context, Entry entry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reflection',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Text(
          entry.note.isEmpty ? 'No reflection added for this check-in.' : entry.note,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            height: 1.8,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildTagsSection(BuildContext context, Entry entry) {
    if (entry.tags.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: entry.tags.map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(
                '#${tag.name}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, Entry entry) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // Delete logic
              MoodScope.of(context).moodRepository.deleteEntry(entry.id);
              context.pop();
            },
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => context.push('/new-entry?editId=${entry.id}'),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit Entry'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }
}
