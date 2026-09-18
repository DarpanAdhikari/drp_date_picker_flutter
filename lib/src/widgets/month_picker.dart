import 'package:flutter/material.dart';

/// A grid of months (1-12) used for month navigation.
class MonthPicker extends StatelessWidget {
  final int currentMonth;
  final bool primaryIsBs;
  final bool devanagari;
  final ValueChanged<int> onSelect;

  const MonthPicker({
    super.key,
    required this.currentMonth,
    required this.primaryIsBs,
    required this.devanagari,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final names = primaryIsBs
        ? const [
            'Baisakh',
            'Jestha',
            'Ashadh',
            'Shrawan',
            'Bhadra',
            'Ashwin',
            'Kartik',
            'Mangsir',
            'Poush',
            'Magh',
            'Falgun',
            'Chaitra',
          ]
        : const [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec',
          ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 6,
      crossAxisSpacing: 6,
      childAspectRatio: 2.2,
      children: [
        for (var i = 1; i <= 12; i++) _monthButton(context, names[i - 1], i),
      ],
    );
  }

  Widget _monthButton(BuildContext context, String label, int month) {
    final scheme = Theme.of(context).colorScheme;
    final isCurrent = month == currentMonth;
    return OutlinedButton(
      onPressed: () => onSelect(month),
      style: OutlinedButton.styleFrom(
        backgroundColor: isCurrent
            ? scheme.primary
            : scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        foregroundColor: isCurrent ? scheme.onPrimary : scheme.onSurface,
        side: BorderSide(
          color: isCurrent ? scheme.primary : scheme.outlineVariant,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 10),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}
