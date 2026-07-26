import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

/// Single-field editor used for the user's name. Returns null when cancelled.
Future<String?> showTextFieldDialog({
  required BuildContext context,
  required String title,
  required String initialValue,
  String? hint,
  int? maxLength,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _TextFieldDialog(
      title: title,
      initialValue: initialValue,
      hint: hint,
      maxLength: maxLength,
    ),
  );
}

/// The controller lives inside the dialog's own [State] so it is disposed when the
/// route is gone — not while it is still animating out, which would leave the field
/// using a disposed controller for a frame.
class _TextFieldDialog extends StatefulWidget {
  const _TextFieldDialog({
    required this.title,
    required this.initialValue,
    this.hint,
    this.maxLength,
  });

  final String title;
  final String initialValue;
  final String? hint;
  final int? maxLength;

  @override
  State<_TextFieldDialog> createState() => _TextFieldDialogState();
}

class _TextFieldDialogState extends State<_TextFieldDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.of(context).pop(_controller.text.trim());

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: widget.maxLength,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(hintText: widget.hint),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.actionSave)),
      ],
    );
  }
}
