// src/ui/widgets/app_text_field.dart
// A reusable text field widget with various customization options.
import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hintText;
  final String? helperText;
  final String? prefixText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool autocorrect;
  final bool enableSuggestions;
  final TextInputAction? textInputAction;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final bool enabled;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? initialValue; // Add this

  const AppTextField({
    super.key,
    this.controller,
    required this.label,
    this.hintText,
    this.helperText,
    this.prefixText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.textInputAction,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
    this.initialValue, // Add this
  }) : assert(controller == null || initialValue == null,
            'Cannot provide both a controller and an initialValue');

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        helperText: helperText,
        prefixText: prefixText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        counterText: maxLength != null ? null : '',
        enabled: enabled,
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      textInputAction: textInputAction,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      enabled: enabled,
      readOnly: readOnly,
      onTap: onTap,
    );
  }
}
