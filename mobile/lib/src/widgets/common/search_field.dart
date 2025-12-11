// lib/src/widgets/common/search_field.dart
// A reusable search field widget with customizable hint text and callbacks.
import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;

  const SearchField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: hintText,
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        filled: true,
        fillColor: theme.colorScheme.surface,
      ),
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }
}
