import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stitch/theme/app_theme.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showProfile;
  final String? profileImageUrl;

  const AppTopBar({
    Key? key,
    this.title = 'Laune',
    this.showProfile = true,
    this.profileImageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    
    return AppBar(
      backgroundColor: scheme.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      title: Row(
        children: [

          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/launeicon.jpg',
              height: 32,
              width: 32,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.settings_outlined, color: scheme.onSurfaceVariant),
          onPressed: () => context.go('/settings'),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
