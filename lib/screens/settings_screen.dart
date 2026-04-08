import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stitch/main.dart';
import 'package:stitch/services/notification_service.dart';
import 'package:stitch/theme/app_theme.dart';
import 'package:stitch/widgets/app_top_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _dailyReminder = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 30);
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final authRepo = MoodScope.of(context).authRepository;
    
    final int hour = prefs.getInt('reminder_hour') ?? 20;
    final int minute = prefs.getInt('reminder_minute') ?? 30;

    setState(() {
      _dailyReminder = prefs.getBool('daily_reminder') ?? true;
      _reminderTime = TimeOfDay(hour: hour, minute: minute);
      _biometricEnabled = authRepo.isBiometricEnabled;
    });
  }

  Future<void> _updateTheme(ThemeMode mode) async {
    final moodScope = MoodScope.of(context);
    moodScope.themeModeNotifier.value = mode;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
  }

  Future<void> _toggleReminder(bool value) async {
    setState(() => _dailyReminder = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('daily_reminder', value);
    
    if (value) {
      await NotificationService().scheduleDailyReminder(_reminderTime);
    } else {
      await NotificationService().cancelAll();
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _reminderTime) {
      setState(() => _reminderTime = picked);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('reminder_hour', picked.hour);
      await prefs.setInt('reminder_minute', picked.minute);
      
      if (_dailyReminder) {
        await NotificationService().scheduleDailyReminder(picked);
      }
    }
  }

  void _showToast(String message, {bool isError = true}) {
    if (!mounted) return;
    final scheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                color: isError ? scheme.onError : scheme.onPrimary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: isError ? scheme.onError : scheme.onPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: isError ? scheme.error : scheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          duration: const Duration(seconds: 3),
          elevation: 0,
        ),
      );
  }

  Future<void> _toggleBiometrics(bool value) async {
    final authRepo = MoodScope.of(context).authRepository;

    if (value) {
      // Check hardware support first
      final canUse = await authRepo.canUseBiometrics();
      if (!canUse) {
        _showToast('This device does not support biometric authentication.');
        return;
      }

      // Ask user to verify biometrics before enabling
      bool verified = false;
      try {
        verified = await authRepo.verifyBiometrics();
      } on PlatformException catch (e) {
        // NotAvailable = no biometrics enrolled; NotEnrolled = same on some devices
        final code = e.code;
        if (code == 'NotAvailable' || code == 'NotEnrolled' || code == 'no_fragment_activity') {
          _showToast('No biometrics are set up on this device. Please enroll a fingerprint or face in your device settings.');
        } else {
          _showToast('Biometric error: ${e.message ?? e.code}');
        }
        return;
      } catch (e) {
        _showToast('An unexpected error occurred. Please try again.');
        return;
      }

      if (!verified) {
        _showToast('Biometric verification failed or was cancelled.');
        return;
      }
    }

    await authRepo.setBiometricEnabled(value);
    setState(() => _biometricEnabled = value);

    if (!value) {
      _showToast('Biometric lock disabled.', isError: false);
    } else {
      _showToast('Biometric lock enabled!', isError: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = MoodScope.of(context).themeModeNotifier.value;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: const AppTopBar(title: 'Laune'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Text(MoodScope.of(context).authRepository.userName ?? 'Mindful User', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 48),
              
              _buildSectionHeader(context, 'App Settings'),
              const SizedBox(height: 16),
              _buildSettingsGroup(context, [
                _buildReminderTile(context),
                _buildToggleTile(
                  context,
                  icon: Icons.fingerprint,
                  color: scheme.secondaryContainer,
                  iconColor: scheme.secondary,
                  title: 'Biometric Lock',
                  subtitle: 'FaceID or TouchID',
                  value: _biometricEnabled,
                  onChanged: _toggleBiometrics,
                ),
                _buildThemeTile(context, themeMode),
              ]),
              const SizedBox(height: 32),
              
              _buildSectionHeader(context, 'Data Management'),
              const SizedBox(height: 16),
              _buildSettingsGroup(context, [
                _buildLinkTile(context, 'Reset PIN', () => context.push('/login?reset=true')),
              ]),
              const SizedBox(height: 32),
              
              _buildSectionHeader(context, 'Support & Privacy'),
              const SizedBox(height: 16),
              _buildLinkTile(context, 'Privacy Policy', () => context.push('/privacy-policy')),
              const SizedBox(height: 8),
              _buildLinkTile(context, 'Help Center', () => context.push('/help-center')),
              const SizedBox(height: 8),
              _buildLinkTile(context, 'Terms of Service', () => context.push('/terms-of-service')),
              
              const SizedBox(height: 48),
              Center(
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          MoodScope.of(context).authRepository.logout();
                          context.go('/login');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: scheme.error,
                          side: BorderSide(color: scheme.error.withOpacity(0.2)),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                        ),
                        child: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('LAUNE', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 10, letterSpacing: 2)),
                    const SizedBox(height: 4),
                    Text('Version 2.4.1 (Build 890)', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5))),
                  ],
                ),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(title.toUpperCase(), style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 10, letterSpacing: 2.0));
  }

  Widget _buildSettingsGroup(BuildContext context, List<Widget> children) {
    return Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Column(children: children));
  }

  Widget _buildReminderTile(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: scheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusDefault)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: scheme.primaryContainer.withOpacity(0.2), shape: BoxShape.circle),
                child: Icon(Icons.notifications, color: scheme.primary, size: 20),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Daily Reminder', style: TextStyle(fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () => _selectTime(context),
                    child: Text(
                      '${_reminderTime.format(context)} • Every Day',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontSize: 10,
                        color: scheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: _dailyReminder,
            onChanged: _toggleReminder,
            activeColor: scheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTile(BuildContext context, {required IconData icon, required Color color, required Color iconColor, required String title, required String subtitle, required bool value, required ValueChanged<bool> onChanged}) {
    final scheme = Theme.of(context).colorScheme;
    return Container(margin: const EdgeInsets.symmetric(vertical: 4), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: scheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusDefault)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 20)), const SizedBox(width: 16), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), Text(subtitle, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 10))])]), Switch(value: value, onChanged: onChanged, activeColor: scheme.primary)]));
  }

  Widget _buildThemeTile(BuildContext context, ThemeMode mode) {
    final scheme = Theme.of(context).colorScheme;
    return Container(margin: const EdgeInsets.symmetric(vertical: 4), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: scheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusDefault)), child: Column(children: [Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: scheme.tertiaryContainer.withOpacity(0.2), shape: BoxShape.circle), child: Icon(Icons.palette, color: scheme.primary, size: 20)), const SizedBox(width: 16), const Text('App Theme', style: TextStyle(fontWeight: FontWeight.bold))]), const SizedBox(height: 16), Row(children: [_buildThemeButton(context, 'System', mode == ThemeMode.system, () => _updateTheme(ThemeMode.system)), const SizedBox(width: 8), _buildThemeButton(context, 'Light', mode == ThemeMode.light, () => _updateTheme(ThemeMode.light)), const SizedBox(width: 8), _buildThemeButton(context, 'Dark', mode == ThemeMode.dark, () => _updateTheme(ThemeMode.dark))])]));
  }

  Widget _buildThemeButton(BuildContext context, String label, bool isSelected, VoidCallback onTap) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(child: GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: isSelected ? scheme.primary.withOpacity(0.1) : scheme.surfaceVariant.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: isSelected ? Border.all(color: scheme.primary, width: 2) : null), child: Center(child: Text(label, style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? scheme.primary : scheme.onSurfaceVariant))))));
  }

  Widget _buildLinkTile(BuildContext context, String label, VoidCallback onTap) {
    return GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.w600)), const Icon(Icons.chevron_right)])));
  }
}
