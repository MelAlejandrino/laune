import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stitch/main.dart';
import 'package:stitch/screens/home_screen.dart';
import 'package:stitch/screens/history_screen.dart';
import 'package:stitch/screens/calendar_screen.dart';

import 'package:stitch/screens/settings_screen.dart';
import 'package:stitch/screens/new_entry_screen.dart';
import 'package:stitch/screens/view_entry_screen.dart';
import 'package:stitch/screens/support_screens.dart';
import 'package:stitch/screens/name_setup_screen.dart';
import 'package:stitch/screens/pin_screen.dart';
import 'package:stitch/screens/terms_accept_screen.dart';
import 'package:stitch/screens/onboarding_reminder_setup_screen.dart';
import 'package:stitch/widgets/scaffold_with_nav_bar.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  redirect: (context, state) {
    final authRepo = MoodScope.of(context).authRepository;
    final location = state.matchedLocation;
    
    final isLoggingIn = location == '/login';
    final isSettingUpName = location == '/setup-name';
    final isAcceptingTerms = location == '/terms-accept';
    final isSettingUpReminder = location == '/setup-reminder';
    final isReset = state.uri.queryParameters['reset'] == 'true';

    if (!authRepo.isAuthenticated && !isLoggingIn) {
      return '/login';
    }

    if (authRepo.isAuthenticated) {
      // Force onboarding steps in order.
      if (authRepo.userName == null && !isSettingUpName) {
        return '/setup-name';
      }
      if (authRepo.userName != null && !authRepo.termsAccepted && !isAcceptingTerms) {
        return '/terms-accept';
      }
      if (authRepo.userName != null && authRepo.termsAccepted && !authRepo.isDailyReminderSetupComplete && !isSettingUpReminder) {
        return '/setup-reminder';
      }

      // If user is already done with a step, don't let them land there.
      if (!isLoggingIn && !isReset) {
        if (isSettingUpName && authRepo.userName != null) return '/';
        if (isAcceptingTerms && authRepo.termsAccepted) return '/';
        if (isSettingUpReminder && authRepo.isDailyReminderSetupComplete) return '/';
      }

      if (isLoggingIn && !isReset) return '/';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) {
        final isReset = state.uri.queryParameters['reset'] == 'true';
        return PinScreen(isReset: isReset);
      },
    ),
    GoRoute(
      path: '/setup-name',
      name: 'setup-name',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const NameSetupScreen(),
    ),
    GoRoute(
      path: '/terms-accept',
      name: 'terms-accept',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const TermsAcceptScreen(),
    ),
    GoRoute(
      path: '/setup-reminder',
      name: 'setup-reminder',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const OnboardingReminderSetupScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              name: 'home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/history',
              name: 'history',
              builder: (context, state) => const HistoryScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/calendar',
              name: 'calendar',
              builder: (context, state) => const CalendarScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              name: 'settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/new-entry',
      name: 'new-entry',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final dateStr = state.uri.queryParameters['date'];
        final editId = state.uri.queryParameters['editId'];
        final initialDate = dateStr != null ? DateTime.tryParse(dateStr) : null;
        return MaterialPage(
          fullscreenDialog: true,
          child: NewEntryScreen(initialDate: initialDate, entryId: editId),
        );
      },
    ),
    GoRoute(
      path: '/view-entry/:id',
      name: 'view-entry',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ViewEntryScreen(entryId: id);
      },
    ),
    // ... support screens ...
    GoRoute(
      path: '/privacy-policy',
      name: 'privacy-policy',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SupportScreen(title: 'Privacy Policy'),
    ),
    GoRoute(
      path: '/terms-of-service',
      name: 'terms-of-service',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SupportScreen(title: 'Terms of Service'),
    ),
    GoRoute(
      path: '/help-center',
      name: 'help-center',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SupportScreen(title: 'Help Center'),
    ),
  ],
);
