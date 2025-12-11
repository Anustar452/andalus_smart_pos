// src/ui/widgets/common/custom_card.dart
// A customizable card widget with tap and long-press functionality, padding, margin, and styling
import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? backgroundColor;
  final double elevation;
  final BorderRadiusGeometry borderRadius;
  final EdgeInsetsGeometry? margin;
  final bool showBorder;
  final Color? borderColor;
  final double? width;
  final double? height;

  const CustomCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.onLongPress,
    this.backgroundColor,
    this.elevation = 2,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.margin,
    this.showBorder = false,
    this.borderColor,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      width: width,
      height: height,
      child: Card(
        elevation: elevation,
        color: backgroundColor ?? Theme.of(context).colorScheme.surface,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: showBorder
              ? BorderSide(
                  color: borderColor ??
                      Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  width: 1,
                )
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: _getBorderRadius(borderRadius),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }

  BorderRadius _getBorderRadius(BorderRadiusGeometry borderRadius) {
    if (borderRadius is BorderRadius) {
      return borderRadius;
    } else if (borderRadius is RoundedRectangleBorder) {
      // return (borderRadius.borderRadius as BorderRadius?) ??
      //     BorderRadius.circular(16);
      return BorderRadius.circular(16);
    } else {
      return BorderRadius.circular(16);
    }
  }
}
