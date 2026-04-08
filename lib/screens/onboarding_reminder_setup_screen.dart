import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stitch/main.dart';
import 'package:stitch/services/notification_service.dart';

class OnboardingReminderSetupScreen extends StatefulWidget {
  const OnboardingReminderSetupScreen({super.key});

  @override
  State<OnboardingReminderSetupScreen> createState() => _OnboardingReminderSetupScreenState();
}

class _OnboardingReminderSetupScreenState extends State<OnboardingReminderSetupScreen> {
  bool _busy = false;

  Future<void> _onYes() async {
    if (_busy) return;
    setState(() => _busy = true);

    final authRepo = MoodScope.of(context).authRepository;
    final prefs = await SharedPreferences.getInstance();

    final hour = prefs.getInt('reminder_hour') ?? 20;
    final minute = prefs.getInt('reminder_minute') ?? 30;
    final time = TimeOfDay(hour: hour, minute: minute);

    bool scheduled = false;
    try {
      scheduled = await NotificationService().scheduleDailyReminder(time);
    } finally {
      await prefs.setInt('reminder_hour', time.hour);
      await prefs.setInt('reminder_minute', time.minute);
      await prefs.setBool('daily_reminder', scheduled);
      if (!scheduled) {
        await NotificationService().cancelAll();
      }
      await authRepo.setDailyReminderSetupComplete(true);
      if (!mounted) return;
      setState(() => _busy = false);
      context.go('/');
    }
  }

  Future<void> _onNo() async {
    if (_busy) return;
    setState(() => _busy = true);

    final authRepo = MoodScope.of(context).authRepository;
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('daily_reminder', false);
    await NotificationService().cancelAll();
    await authRepo.setDailyReminderSetupComplete(true);

    if (!mounted) return;
    setState(() => _busy = false);
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text('Daily Reminder Setup'),
        backgroundColor: scheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _busy ? null : () => context.go('/terms-accept'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Text(
                'Set up daily reminder?',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Get a gentle notification every day to check in on how you are feeling.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant.withOpacity(0.7),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _busy ? null : _onNo,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: scheme.onSurfaceVariant,
                        side: BorderSide(color: scheme.outline.withOpacity(0.2)),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                      ),
                      child: _busy
                          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text(
                              'NO',
                              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _busy ? null : _onYes,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                        elevation: 8,
                      ),
                      child: _busy
                          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text(
                              'YES',
                              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

