import 'package:flutter/material.dart';

/// Draggable split between two children along [axis].
///
/// [ratio] is the fraction of the main axis given to [firstChild]
/// (height fraction when vertical, width fraction when horizontal).
/// Drag updates are clamped to \[0.1, 0.9\].
class DraggableSplitView extends StatelessWidget {
  const DraggableSplitView({
    super.key,
    required this.axis,
    required this.firstChild,
    required this.secondChild,
    required this.ratio,
    required this.onRatioChanged,
  });

  final Axis axis;
  final Widget firstChild;
  final Widget secondChild;
  final double ratio;
  final ValueChanged<double> onRatioChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (axis == Axis.vertical) {
          final totalHeight = constraints.maxHeight;
          if (totalHeight <= 0) return const SizedBox.shrink();
          final topHeight = totalHeight * ratio;
          return Column(
            children: [
              SizedBox(height: topHeight, child: firstChild),
              _VerticalSplitHandle(
                totalExtent: totalHeight,
                firstExtent: topHeight,
                onRatioChanged: onRatioChanged,
              ),
              Expanded(child: secondChild),
            ],
          );
        }

        final totalWidth = constraints.maxWidth;
        if (totalWidth <= 0) return const SizedBox.shrink();
        final leftWidth = totalWidth * ratio;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(width: leftWidth, child: firstChild),
            _HorizontalSplitHandle(
              totalExtent: totalWidth,
              firstExtent: leftWidth,
              onRatioChanged: onRatioChanged,
            ),
            Expanded(child: secondChild),
          ],
        );
      },
    );
  }
}

class _VerticalSplitHandle extends StatelessWidget {
  const _VerticalSplitHandle({
    required this.totalExtent,
    required this.firstExtent,
    required this.onRatioChanged,
  });

  final double totalExtent;
  final double firstExtent;
  final ValueChanged<double> onRatioChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanUpdate: (details) {
        final newFirst = firstExtent + details.delta.dy;
        var newRatio = newFirst / totalExtent;
        newRatio = newRatio.clamp(0.1, 0.9);
        onRatioChanged(newRatio);
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Divider(height: 16, thickness: 1),
          Container(
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).disabledColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _HorizontalSplitHandle extends StatelessWidget {
  const _HorizontalSplitHandle({
    required this.totalExtent,
    required this.firstExtent,
    required this.onRatioChanged,
  });

  final double totalExtent;
  final double firstExtent;
  final ValueChanged<double> onRatioChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanUpdate: (details) {
        final newFirst = firstExtent + details.delta.dx;
        var newRatio = newFirst / totalExtent;
        newRatio = newRatio.clamp(0.1, 0.9);
        onRatioChanged(newRatio);
      },
      child: SizedBox(
        width: 16,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const VerticalDivider(width: 16, thickness: 1),
            Container(
              width: 4,
              height: 32,
              decoration: BoxDecoration(
                color: Theme.of(context).disabledColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
