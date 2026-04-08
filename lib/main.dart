import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stitch/repositories/auth_repository.dart';
import 'package:stitch/repositories/mood_repository.dart';
import 'package:stitch/router.dart';
import 'package:stitch/services/notification_service.dart';
import 'package:stitch/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Services
  final notificationService = NotificationService();
  await notificationService.init();
  
  // Initialize Repositories
  final authRepository = AuthRepository();
  await authRepository.init();
  
  final moodRepository = MoodRepository();
  await moodRepository.init();
  
  // Theme Management
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('is_dark_mode') ?? false;
  final themeModeNotifier = ValueNotifier<ThemeMode>(
    isDarkMode ? ThemeMode.dark : ThemeMode.light,
  );

  runApp(MoodLogApp(
    authRepository: authRepository,
    moodRepository: moodRepository,
    themeModeNotifier: themeModeNotifier,
  ));
}

class MoodLogApp extends StatelessWidget {
  final AuthRepository authRepository;
  final MoodRepository moodRepository;
  final ValueNotifier<ThemeMode> themeModeNotifier;

  const MoodLogApp({
    super.key,
    required this.authRepository,
    required this.moodRepository,
    required this.themeModeNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([themeModeNotifier, authRepository]),
      builder: (context, _) {
        return MoodScope(
          authRepository: authRepository,
          moodRepository: moodRepository,
          themeModeNotifier: themeModeNotifier,
          child: MaterialApp.router(
            title: 'Laune',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeModeNotifier.value,
            routerConfig: appRouter,
            debugShowCheckedModeBanner: false,
          ),
        );
      },
    );
  }
}

class MoodScope extends InheritedWidget {
  final AuthRepository authRepository;
  final MoodRepository moodRepository;
  final ValueNotifier<ThemeMode> themeModeNotifier;

  const MoodScope({
    super.key,
    required this.authRepository,
    required this.moodRepository,
    required this.themeModeNotifier,
    required super.child,
  });

  static MoodScope of(BuildContext context) {
    final MoodScope? result = context.dependOnInheritedWidgetOfExactType<MoodScope>();
    assert(result != null, 'No MoodScope found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(MoodScope oldWidget) => 
    authRepository != oldWidget.authRepository ||
    moodRepository != oldWidget.moodRepository || 
    themeModeNotifier != oldWidget.themeModeNotifier;
}
