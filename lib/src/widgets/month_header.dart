import 'package:flutter/material.dart';

/// The calendar header with prev/next month buttons and a tappable title.
class MonthHeader extends StatelessWidget {
  final String title;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onTitleTap;

  const MonthHeader({
    super.key,
    required this.title,
    required this.onPrev,
    required this.onNext,
    required this.onTitleTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Widget navBtn(IconData icon, String label, VoidCallback onTap) {
      return IconButton(
        icon: Icon(icon, size: 20, color: scheme.onSurface),
        tooltip: label,
        onPressed: onTap,
        style: IconButton.styleFrom(
          backgroundColor: scheme.surfaceContainerHighest.withValues(
            alpha: 0.5,
          ),
          foregroundColor: scheme.onSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        visualDensity: VisualDensity.compact,
      );
    }

    return Row(
      children: [
        navBtn(Icons.chevron_left_rounded, 'Previous month', onPrev),
        Expanded(
          child: InkWell(
            onTap: onTitleTap,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ),
        ),
        navBtn(Icons.chevron_right_rounded, 'Next month', onNext),
      ],
    );
  }
}
