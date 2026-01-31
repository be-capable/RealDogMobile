import 'package:flutter/material.dart';
import '../app_theme.dart';

class ClayContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final Color? color;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const ClayContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.color,
    this.borderRadius = 24.0,
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = color ?? AppTheme.white;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        margin: margin,
        padding: padding ?? const EdgeInsets.all(AppTheme.spaceMD),
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.4),
            width: 2,
          ),
          boxShadow: [
            // Outer shadow (Drop shadow)
            BoxShadow(
              color: AppTheme.text.withValues(alpha: 0.1),
              offset: const Offset(6, 6),
              blurRadius: 12,
            ),
            // Inner highlight (Top-Left) - Simulated with gradient or inner shadow logic if needed
            // For simple Flutter Container, we use gradient to simulate "Clay" curve
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              baseColor.withValues(alpha: 0.9), // Highlight
              baseColor, // Base
              baseColor.withValues(alpha: 0.95), // Shadow
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: child,
      ),
    );
  }
}
