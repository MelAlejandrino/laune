import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:stitch/main.dart';
import 'package:stitch/models/entry.dart';
import 'package:stitch/models/tag.dart';
import 'package:stitch/theme/app_theme.dart';

class NewEntryScreen extends StatefulWidget {
  final DateTime? initialDate;
  final String? entryId;
  
  const NewEntryScreen({super.key, this.initialDate, this.entryId});

  @override
  State<NewEntryScreen> createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  MoodType _selectedMood = MoodType.good;
  double _intensity = 4.0;
  final TextEditingController _noteController = TextEditingController();
  final List<String> _selectedTags = [];
  final TextEditingController _tagController = TextEditingController();
  bool _isAddingTag = false;
  late DateTime _timestamp;

  @override
  void initState() {
    super.initState();
    _timestamp = widget.initialDate ?? DateTime.now();
    
    // Load existing entry if in edit mode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.entryId != null) {
        final repository = MoodScope.of(context).moodRepository;
        final entry = repository.getEntryById(widget.entryId!);
        if (entry != null) {
          setState(() {
            _selectedMood = entry.mood;
            _intensity = entry.intensity.toDouble();
            _noteController.text = entry.note;
            _selectedTags.clear();
            _selectedTags.addAll(entry.tags.map((t) => t.name));
            _timestamp = entry.timestamp;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _saveEntry() {
    final repository = MoodScope.of(context).moodRepository;
    final entry = Entry(
      id: widget.entryId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      mood: _selectedMood,
      intensity: _intensity.toInt(),
      note: _noteController.text,
      tags: _selectedTags.map((name) => Tag(id: name, name: name)).toList(),
      timestamp: _timestamp,
    );
    
    if (widget.entryId != null) {
      repository.updateEntry(entry);
    } else {
      repository.addEntry(entry);
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          _buildBackgroundAtmosphere(context),
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(color: Colors.black26),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.9,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 40, offset: Offset(0, -20)),
                ],
              ),
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildReflectionInput(context),
                          const SizedBox(height: 32),
                          _buildMoodAndIntensitySection(context),
                          const SizedBox(height: 32),
                          _buildMoreOptions(context),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildFooter(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundAtmosphere(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: scheme.surface,
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(color: scheme.primary.withOpacity(0.1), shape: BoxShape.circle),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(color: scheme.secondary.withOpacity(0.1), shape: BoxShape.circle),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.entryId != null ? 'Update Post' : 'How are you?',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
              padding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSelector(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: MoodType.values.map((mood) {
        final isSelected = _selectedMood == mood;
        return InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => setState(() => _selectedMood = mood),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? scheme.primaryContainer.withOpacity(0.35)
                  : scheme.surfaceVariant.withOpacity(0.15),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isSelected ? scheme.primary.withOpacity(0.6) : scheme.outline.withOpacity(0.1),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  mood.emoji,
                  style: const TextStyle(fontSize: 18),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  Text(
                    mood.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: scheme.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIntensitySlider(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Intensity',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 16),
            ),
            Text(
              '${_intensity.toInt()}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: scheme.primary),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 10,
            activeTrackColor: scheme.primary.withOpacity(0.3),
            inactiveTrackColor: scheme.surfaceVariant.withOpacity(0.2),
            thumbColor: scheme.primary,
            overlayColor: scheme.primary.withOpacity(0.1),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
          ),
          child: Slider(
            value: _intensity,
            min: 1,
            max: 5,
            divisions: 4,
            onChanged: (v) => setState(() => _intensity = v),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('LOW', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: scheme.onSurfaceVariant)),
            Text('HIGH', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: scheme.onSurfaceVariant)),
          ],
        ),
      ],
    );
  }

  Widget _buildMoodAndIntensitySection(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceVariant.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          _buildMoodSelector(context),
          const SizedBox(height: 16),
          _buildIntensitySlider(context),
        ],
      ),
    );
  }

  Widget _buildMoreOptions(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceVariant.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outline.withOpacity(0.1)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 8),
        childrenPadding: const EdgeInsets.only(top: 12),
        title: Text(
          'More',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: scheme.onSurfaceVariant,
          ),
        ),
        trailing: const Icon(Icons.expand_more),
        onExpansionChanged: (_) {},
        initiallyExpanded: false,
        children: [
          _buildTagsSection(context),
          const SizedBox(height: 20),
          _buildDateTimeSelector(context),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildReflectionInput(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Reflection',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18),
            ),
            Text(
              '${_noteController.text.length} characters',
              style: const TextStyle(fontSize: 12, color: AppTheme.outline),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 220,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: scheme.surfaceVariant.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: scheme.outline.withOpacity(0.1)),
          ),
          child: TextField(
            controller: _noteController,
            onChanged: (v) => setState(() {}),
            minLines: 6,
            maxLines: null,
            decoration: const InputDecoration(
              hintText: 'Add a note...',
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagsSection(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const commonTags = ['#work', '#sleep', '#exercise', '#meditation', '#creative'];
    
    // Combine common tags with any current custom tags
    final allTags = {...commonTags, ..._selectedTags}.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tags', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ...allTags.map((tag) {
              final isSelected = _selectedTags.contains(tag);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedTags.remove(tag);
                    } else {
                      _selectedTags.add(tag);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? scheme.primary : scheme.surfaceVariant.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? scheme.onPrimary : scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            }),
            if (_isAddingTag)
              SizedBox(
                width: 120,
                child: TextField(
                  controller: _tagController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: '#tag',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(9999)),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      final tag = value.startsWith('#') ? value : '#$value';
                      setState(() {
                        if (!_selectedTags.contains(tag)) {
                          _selectedTags.add(tag);
                        }
                        _tagController.clear();
                        _isAddingTag = false;
                      });
                    } else {
                      setState(() => _isAddingTag = false);
                    }
                  },
                ),
              )
            else
              GestureDetector(
                onTap: () => setState(() => _isAddingTag = true),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scheme.surfaceVariant.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: scheme.primary.withOpacity(0.2)),
                  ),
                  child: Icon(Icons.add, size: 20, color: scheme.primary),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateTimeSelector(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surfaceVariant.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: scheme.surfaceVariant.withOpacity(0.3), shape: BoxShape.circle),
                child: Icon(Icons.schedule, color: scheme.primary),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('DATE & TIME', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.outline)),
                  Text(
                    DateFormat('MMM dd, hh:mm a').format(_timestamp),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.surface.withOpacity(0)],
        ),
      ),
      child: ElevatedButton(
        onPressed: _saveEntry,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.25),
          elevation: 12,
        ),
        child: Center(
          child: Text(
            widget.entryId != null ? 'Save Changes' : 'Save Entry',
          ),
        ),
      ),
    );
  }
}
