import 'package:flutter/material.dart';

class LoadingShimmer extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;
  final EdgeInsetsGeometry margin;

  const LoadingShimmer({
    super.key,
    this.height = 60,
    this.width = double.infinity,
    this.borderRadius = 8,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: ShimmerLoader(),
      ),
    );
  }
}

class ShimmerLoader extends StatefulWidget {
  const ShimmerLoader({super.key});

  @override
  State<ShimmerLoader> createState() => _ShimmerLoaderState();
}

class _ShimmerLoaderState extends State<ShimmerLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ShimmerPainter(_controller.value),
        );
      },
    );
  }
}

class ShimmerPainter extends CustomPainter {
  final double progress;

  ShimmerPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final gradient = LinearGradient(
      colors: [
        Colors.grey.shade300!,
        Colors.grey.shade100!,
        Colors.grey.shade300!,
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final rect = Rect.fromLTWH(-size.width, 0, size.width * 3, size.height);
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..maskFilter = MaskFilter.blur(BlurStyle.solid, 4);

    final x = size.width * progress * 2 - size.width;
    final shimmerRect = Rect.fromLTWH(x, 0, size.width * 0.3, size.height);

    canvas.drawRect(shimmerRect, paint);
  }

  @override
  bool shouldRepaint(covariant ShimmerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// Pre-built shimmer components for common use cases
class ListItemShimmer extends StatelessWidget {
  final bool hasLeading;
  final bool hasTrailing;

  const ListItemShimmer({
    super.key,
    this.hasLeading = true,
    this.hasTrailing = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (hasLeading)
            Container(
              width: 48,
              height: 48,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 16,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  width: 120,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          if (hasTrailing)
            Container(
              width: 60,
              height: 16,
              margin: const EdgeInsets.only(left: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
        ],
      ),
    );
  }
}

class GridShimmer extends StatelessWidget {
  final int crossAxisCount;
  final double childAspectRatio;
  final int itemCount;

  const GridShimmer({
    super.key,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.0,
    this.itemCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return const LoadingShimmer(
          height: 120,
          borderRadius: 12,
        );
      },
    );
  }
}

class CardShimmer extends StatelessWidget {
  final bool hasImage;
  final bool hasActions;

  const CardShimmer({
    super.key,
    this.hasImage = false,
    this.hasActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasImage)
            Container(
              width: double.infinity,
              height: 120,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          Container(
            width: double.infinity,
            height: 20,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Container(
            width: 160,
            height: 16,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          if (hasActions)
            Row(
              children: [
                Container(
                  width: 80,
                  height: 36,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                Container(
                  width: 80,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
