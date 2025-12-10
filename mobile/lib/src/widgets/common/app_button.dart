// src/ui/widgets/app_button.dart
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final ButtonType type;

  const AppButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.type = ButtonType.primary,
  });

  // Add this factory constructor for outlined button
  factory AppButton.outlined({
    required VoidCallback? onPressed,
    required Widget child,
    bool isLoading = false,
  }) {
    return AppButton(
      onPressed: onPressed,
      child: child,
      isLoading: isLoading,
      type: ButtonType.outlined,
    );
  }

  factory AppButton.primary({
    required VoidCallback? onPressed,
    required Widget child,
    bool isLoading = false,
  }) {
    return AppButton(
      onPressed: onPressed,
      child: child,
      isLoading: isLoading,
      type: ButtonType.primary,
    );
  }

  factory AppButton.secondary({
    required VoidCallback? onPressed,
    required Widget child,
    bool isLoading = false,
  }) {
    return AppButton(
      onPressed: onPressed,
      child: child,
      isLoading: isLoading,
      type: ButtonType.secondary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: _getButtonStyle(theme),
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: _getLoadingColor(theme),
              ),
            )
          : child,
    );
  }

  ButtonStyle _getButtonStyle(ThemeData theme) {
    switch (type) {
      case ButtonType.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        );
      case ButtonType.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
        );
      case ButtonType.outlined: // ADD THIS CASE
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: theme.colorScheme.primary,
          side: BorderSide(color: theme.colorScheme.primary),
          elevation: 0,
        );
    }
  }

  Color _getLoadingColor(ThemeData theme) {
    switch (type) {
      case ButtonType.primary:
        return theme.colorScheme.onPrimary;
      case ButtonType.secondary:
        return theme.colorScheme.onSurface;
      case ButtonType.outlined:
        return theme.colorScheme.primary;
    }
  }
}

// Update the enum to include outlined
enum ButtonType {
  primary,
  secondary,
  outlined,
}
