import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

class ChoiceOption<T> {
  const ChoiceOption({required this.value, required this.label, this.subtitle});

  final T value;
  final String label;
  final String? subtitle;
}

/// A settings row that opens a single-select dialog. Used for interval, theme and
/// language so all three behave identically.
class ChoiceTile<T> extends StatelessWidget {
  const ChoiceTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final T value;
  final List<ChoiceOption<T>> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = options.where((option) => option.value == value).firstOrNull;
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: selected == null ? null : Text(selected.label),
      trailing: const Icon(Icons.expand_more_rounded),
      onTap: () => _pick(context),
    );
  }

  Future<void> _pick(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final chosen = await showDialog<T>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(title),
        children: [
          RadioGroup<T>(
            groupValue: value,
            onChanged: (selected) => Navigator.of(context).pop(selected),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final option in options)
                  RadioListTile<T>(
                    value: option.value,
                    title: Text(option.label),
                    subtitle: option.subtitle == null ? null : Text(option.subtitle!),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.actionCancel),
              ),
            ),
          ),
        ],
      ),
    );
    if (chosen != null && chosen != value) onChanged(chosen);
  }
}
