import 'package:flutter/material.dart';

/// A dismissible-free inline warning used for the states that stop alarms from
/// working: blocked notifications, background restrictions, a dead service, or a
/// missing text-to-speech voice.
class NoticeBanner extends StatelessWidget {
  const NoticeBanner({
    super.key,
    required this.title,
    required this.body,
    required this.icon,
    this.actionLabel,
    this.onAction,
    this.severity = NoticeSeverity.warning,
  });

  final String title;
  final String body;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final NoticeSeverity severity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (background, foreground) = switch (severity) {
      NoticeSeverity.warning => (scheme.tertiaryContainer, scheme.onTertiaryContainer),
      NoticeSeverity.error => (scheme.errorContainer, scheme.onErrorContainer),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: foreground, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(color: foreground, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      body,
                      style: theme.textTheme.bodySmall?.copyWith(color: foreground),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (actionLabel != null && onAction != null)
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(foregroundColor: foreground),
                child: Text(actionLabel!),
              ),
            ),
        ],
      ),
    );
  }
}

enum NoticeSeverity { warning, error }
