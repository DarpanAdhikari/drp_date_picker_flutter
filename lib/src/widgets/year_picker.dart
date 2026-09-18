import 'package:flutter/material.dart';

import '../converters/bs_data.dart';
import '../utils/digits.dart';

/// A scrollable grid of years used for year navigation.
class YearPicker extends StatelessWidget {
  final int currentYear;
  final bool primaryIsBs;
  final bool devanagari;
  final ValueChanged<int> onSelect;

  const YearPicker({
    super.key,
    required this.currentYear,
    required this.primaryIsBs,
    required this.devanagari,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final min = primaryIsBs ? bsYearMin : adYearMin;
    final max = primaryIsBs ? bsYearMax : adYearMax;
    final years = [for (var y = min; y <= max; y++) y];

    final scheme = Theme.of(context).colorScheme;

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      childAspectRatio: 2.2,
      mainAxisSpacing: 6,
      crossAxisSpacing: 6,
      children: [
        for (final y in years)
          OutlinedButton(
            onPressed: () => onSelect(y),
            style: OutlinedButton.styleFrom(
              backgroundColor: y == currentYear
                  ? scheme.primary
                  : scheme.surfaceContainerHighest.withValues(alpha: 0.4),
              foregroundColor: y == currentYear
                  ? scheme.onPrimary
                  : scheme.onSurface,
              side: BorderSide(
                color: y == currentYear
                    ? scheme.primary
                    : scheme.outlineVariant,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
            child: Text(
              devanagari ? toDigitsString(y.toString()) : y.toString(),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}
