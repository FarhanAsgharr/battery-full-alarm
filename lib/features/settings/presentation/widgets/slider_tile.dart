import 'package:flutter/material.dart';

/// A labelled slider row.
///
/// The displayed value is local state while the user drags, and [onCommit] fires only
/// when they let go. Persisting on every frame would write to `SharedPreferences` and
/// cross the platform channel to the native service sixty times a second for a single
/// gesture — which showed up as jank on the volume and speech-rate sliders.
class SliderTile extends StatefulWidget {
  const SliderTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.formatValue,
    required this.onCommit,
    this.divisions,
  });

  final IconData icon;
  final String title;
  final double value;
  final double min;
  final double max;
  final int? divisions;

  /// Renders the label for a value — called live as the user drags.
  final String Function(double value) formatValue;

  /// Called once, when the gesture ends.
  final ValueChanged<double> onCommit;

  @override
  State<SliderTile> createState() => _SliderTileState();
}

class _SliderTileState extends State<SliderTile> {
  /// Non-null only while a drag is in progress.
  double? _dragValue;

  @override
  void didUpdateWidget(SliderTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    // An external change (a reset, or a settings reload) wins over a stale drag value.
    if (oldWidget.value != widget.value) _dragValue = null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = (_dragValue ?? widget.value).clamp(widget.min, widget.max);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(widget.icon, size: 22, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 16),
              Expanded(child: Text(widget.title, style: theme.textTheme.bodyLarge)),
              Text(
                widget.formatValue(value),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: widget.min,
            max: widget.max,
            divisions: widget.divisions,
            onChanged: (next) => setState(() => _dragValue = next),
            onChangeEnd: (next) {
              setState(() => _dragValue = null);
              widget.onCommit(next);
            },
          ),
        ],
      ),
    );
  }
}
