import 'package:flutter/material.dart';

/// A titled group of settings rows. Used by every settings-style screen so the
/// spacing and typography stay identical across the app.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    this.title,
    required this.children,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
  });

  final String? title;
  final List<Widget> children;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Text(
              title!,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            child: Padding(padding: padding, child: Column(children: children)),
          ),
        ),
      ],
    );
  }
}

/// A short label/value row for read-only facts (battery details, about screen).
class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.label, required this.value, this.icon});

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
