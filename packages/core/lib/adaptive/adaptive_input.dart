import 'package:factory_core/adaptive/platform.dart';
import 'package:factory_core/adaptive/theme.dart';
import 'package:flutter/cupertino.dart'
    show CupertinoColors, CupertinoTextField;
import 'package:flutter/material.dart'
    show InputDecoration, OutlineInputBorder, TextField;
import 'package:flutter/services.dart' show TextInputAction;
import 'package:flutter/widgets.dart';

/// Single-line text field that renders `CupertinoTextField` on iOS and
/// `TextField` (Material 3, outlined) on Android. Cursor + focused border
/// tint from `AdaptiveTheme.accent`.
///
/// Use for every text input in factory apps — never raw `EditableText`
/// or platform-specific field widgets directly.
class AdaptiveInput extends StatelessWidget {
  const AdaptiveInput({
    required this.controller,
    this.focusNode,
    this.placeholder,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.autofocus = false,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? placeholder;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool autofocus;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final theme = context.adaptiveTheme;
    if (AdaptivePlatform.isIOS) {
      return CupertinoTextField(
        controller: controller,
        focusNode: focusNode,
        placeholder: placeholder,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        obscureText: obscureText,
        enabled: enabled,
        autofocus: autofocus,
        maxLength: maxLength,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        cursorColor: theme.accent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: CupertinoColors.systemGrey4),
          borderRadius: BorderRadius.circular(theme.cornerRadius.sm),
        ),
      );
    }
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      enabled: enabled,
      autofocus: autofocus,
      maxLength: maxLength,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      cursorColor: theme.accent,
      decoration: InputDecoration(
        hintText: placeholder,
        border: const OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.accent, width: 2),
        ),
        counterText: '',
      ),
    );
  }
}
