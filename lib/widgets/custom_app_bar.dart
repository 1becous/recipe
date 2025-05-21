import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool pinned;
  final bool large;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.pinned = true,
    this.large = true,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    final defaultActions = [
      IconButton(
        icon: Icon(
          themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
        ),
        onPressed: () {
          themeProvider.setThemeMode(
            themeProvider.isDarkMode ? ThemeMode.light : ThemeMode.dark,
          );
        },
      ),
    ];

    return large
        ? SliverAppBar.large(
            title: Text(title),
            pinned: pinned,
            actions: actions ?? defaultActions,
          )
        : SliverAppBar(
            title: Text(title),
            pinned: pinned,
            actions: actions ?? defaultActions,
          );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 