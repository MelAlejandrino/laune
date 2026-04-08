import 'package:flutter/material.dart';
import 'package:stitch/main.dart';
import 'package:stitch/theme/app_theme.dart';
import 'package:stitch/widgets/app_top_bar.dart';
import 'package:stitch/widgets/mood_card.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = MoodScope.of(context).moodRepository;
    
    return ListenableBuilder(
      listenable: repository,
      builder: (context, _) {
        final allEntries = repository.entries;
        final filteredEntries = allEntries.where((entry) {
          final query = _searchQuery.toLowerCase();
          final matchesNote = entry.note.toLowerCase().contains(query);
          final matchesTags = entry.tags.any((t) => t.name.toLowerCase().contains(query));
          final matchesDate = entry.timestamp.year == _selectedDate.year && entry.timestamp.month == _selectedDate.month;
          
          if (_searchQuery.isEmpty) {
            return matchesDate;
          }
          return (matchesNote || matchesTags) && matchesDate;
        }).toList();
        
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: const AppTopBar(title: 'Laune'),
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 32),
                        Text(
                          'History',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'A look back at your emotional landscape.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildSearchBar(context),
                        const SizedBox(height: 24),
                        _buildMonthPicker(context),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                if (filteredEntries.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Text(
                        _searchQuery.isEmpty 
                          ? 'No mood entries yet. Take a moment to log one!'
                          : 'No entries match your search.',
                      ),
                    ),
                  )
                else
                  _buildTimelineSliver(context, filteredEntries),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.1)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search notes or tags...',
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          prefixIcon: const Icon(Icons.search, size: 24),
          prefixIconColor: Theme.of(context).colorScheme.onSurfaceVariant,
          suffixIcon: _searchQuery.isNotEmpty 
            ? IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              )
            : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildMonthPicker(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildNavButton(context, Icons.chevron_left, () {
          setState(() => _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1));
        }),
        Text(
          DateFormat('MMMM yyyy').format(_selectedDate),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        _buildNavButton(context, Icons.chevron_right, () {
          setState(() => _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1));
        }),
      ],
    );
  }

  Widget _buildNavButton(BuildContext context, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }

  Widget _buildTimelineSliver(BuildContext context, List entries) {
    // Grouping entries by month
    final groupedEntries = <String, List>{};
    for (var entry in entries) {
      final month = DateFormat('MMMM yyyy').format(entry.timestamp);
      groupedEntries.putIfAbsent(month, () => []).add(entry);
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final month = groupedEntries.keys.elementAt(index);
            final monthEntries = groupedEntries[month]!;
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      month.toUpperCase(),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontSize: 10,
                        letterSpacing: 2.0,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Divider(color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5), thickness: 1),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ...monthEntries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: MoodCard(entry: e),
                )).toList(),
                const SizedBox(height: 24),
              ],
            );
          },
          childCount: groupedEntries.length,
        ),
      ),
    );
  }
}
