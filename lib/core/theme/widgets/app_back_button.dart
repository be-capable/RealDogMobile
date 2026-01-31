import 'package:flutter/material.dart';
import '../app_theme.dart';
import 'clay_container.dart';

class AppBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String? semanticsLabel;
  final EdgeInsets padding;

  const AppBackButton({
    super.key,
    this.onTap,
    this.semanticsLabel,
    this.padding = const EdgeInsets.all(10),
  });

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    if (!canPop) return const SizedBox.shrink();

    return Semantics(
      button: true,
      label: semanticsLabel ?? 'Back',
      child: ClayContainer(
        onTap: onTap ?? () => Navigator.of(context).maybePop(),
        borderRadius: 18,
        color: Colors.white,
        padding: padding,
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: AppTheme.text.withValues(alpha: 0.75),
        ),
      ),
    );
  }
}

