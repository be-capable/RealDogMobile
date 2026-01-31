import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/widgets/clay_container.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  int _indexFromLocation(String location) {
    if (location.startsWith('/pets')) return 1;
    if (location.startsWith('/me')) return 2;
    return 0; // /translate (default)
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFromLocation(location);
    return Scaffold(
      body: child,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppTheme.spaceLG, 0, AppTheme.spaceLG, AppTheme.spaceLG),
          child: ClayContainer(
            borderRadius: 28,
            color: Colors.white,
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: currentIndex,
                selectedItemColor: AppTheme.primary,
                unselectedItemColor: AppTheme.text.withValues(alpha: 0.55),
                backgroundColor: Colors.transparent,
                elevation: 0,
                showSelectedLabels: true,
                showUnselectedLabels: true,
                onTap: (index) {
                  switch (index) {
                    case 0:
                      context.go('/translate');
                      break;
                    case 1:
                      context.go('/pets');
                      break;
                    case 2:
                      context.go('/me');
                      break;
                  }
                },
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.translate_outlined), label: 'Translate'),
                  BottomNavigationBarItem(icon: Icon(Icons.folder_outlined), label: 'Profiles'),
                  BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Me'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
