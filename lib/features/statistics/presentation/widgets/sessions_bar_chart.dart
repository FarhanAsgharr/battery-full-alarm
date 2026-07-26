import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';

/// A minimal bar chart of sessions per day.
///
/// Drawn with plain widgets rather than a charting package: the data is a handful of
/// integers, and this keeps the dependency list — and the APK — smaller.
class SessionsBarChart extends StatelessWidget {
  const SessionsBarChart({
    super.key,
    required this.data,
    required this.localeCode,
    this.height = 160,
  });

  final Map<DateTime, int> data;
  final String localeCode;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (data.isEmpty) return const SizedBox.shrink();

    final entries = data.entries.toList();
    final maxValue = entries.map((entry) => entry.value).reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        child: SizedBox(
          height: height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final entry in entries)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${entry.value}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: entry.value / maxValue),
                          duration: const Duration(milliseconds: 450),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, _) => FractionallySizedBox(
                            heightFactor: 1,
                            child: Container(
                              height: (height - 52) * value.clamp(0.06, 1.0),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          entries.length > 10
                              ? Formatters.weekdayShort(localeCode, entry.key)
                              : Formatters.dayLabel(localeCode, entry.key),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
