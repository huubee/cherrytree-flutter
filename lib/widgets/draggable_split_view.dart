import 'package:flutter/material.dart';

/// Draggable split between two children along [axis].
///
/// [ratio] is the fraction of the main axis given to [firstChild]
/// (height fraction when vertical, width fraction when horizontal).
/// Drag updates are clamped to stay within min/max extents.
/// When available space is below [minTotalExtentToSplit], [firstChild]
/// is hidden and [secondChild] takes the full extent (e.g. when an on-screen
/// soft keyboard opens on mobile devices).
class DraggableSplitView extends StatelessWidget {
  const DraggableSplitView({
    super.key,
    required this.axis,
    required this.firstChild,
    required this.secondChild,
    required this.ratio,
    required this.onRatioChanged,
    this.minFirstExtent = 64.0,
    this.minSecondExtent = 120.0,
    this.minTotalExtentToSplit = 280.0,
  });

  final Axis axis;
  final Widget firstChild;
  final Widget secondChild;
  final double ratio;
  final ValueChanged<double> onRatioChanged;
  final double minFirstExtent;
  final double minSecondExtent;
  final double minTotalExtentToSplit;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (axis == Axis.vertical) {
          final totalHeight = constraints.maxHeight;
          if (totalHeight <= 0) return const SizedBox.shrink();

          // When available height is too small (e.g. soft keyboard open in portrait mode),
          // hide firstChild and the split handle so secondChild (editor) gets the entire height.
          if (totalHeight < minTotalExtentToSplit) {
            return Column(
              children: [
                Expanded(
                  key: const ValueKey('split_second_child'),
                  child: secondChild,
                ),
              ],
            );
          }

          const handleExtent = 16.0;
          final availableExtent = totalHeight - handleExtent;
          final maxTop = (availableExtent - minSecondExtent).clamp(minFirstExtent, availableExtent);
          final topHeight = (totalHeight * ratio).clamp(minFirstExtent, maxTop);

          return Column(
            children: [
              SizedBox(
                key: const ValueKey('split_first_child'),
                height: topHeight,
                child: firstChild,
              ),
              _VerticalSplitHandle(
                key: const ValueKey('split_handle'),
                totalExtent: totalHeight,
                firstExtent: topHeight,
                minExtent: minFirstExtent,
                maxExtent: maxTop,
                onRatioChanged: onRatioChanged,
              ),
              Expanded(
                key: const ValueKey('split_second_child'),
                child: secondChild,
              ),
            ],
          );
        }

        final totalWidth = constraints.maxWidth;
        if (totalWidth <= 0) return const SizedBox.shrink();

        final minFirst = minFirstExtent > 64.0 ? minFirstExtent : 140.0;
        final minSecond = minSecondExtent > 120.0 ? minSecondExtent : 180.0;
        const handleExtent = 16.0;
        final availableExtent = totalWidth - handleExtent;
        final maxLeft = (availableExtent - minSecond).clamp(minFirst, availableExtent);
        final leftWidth = (totalWidth * ratio).clamp(minFirst, maxLeft);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              key: const ValueKey('split_first_child_h'),
              width: leftWidth,
              child: firstChild,
            ),
            _HorizontalSplitHandle(
              key: const ValueKey('split_handle_h'),
              totalExtent: totalWidth,
              firstExtent: leftWidth,
              minExtent: minFirst,
              maxExtent: maxLeft,
              onRatioChanged: onRatioChanged,
            ),
            Expanded(
              key: const ValueKey('split_second_child_h'),
              child: secondChild,
            ),
          ],
        );
      },
    );
  }
}

class _VerticalSplitHandle extends StatelessWidget {
  const _VerticalSplitHandle({
    super.key,
    required this.totalExtent,
    required this.firstExtent,
    required this.minExtent,
    required this.maxExtent,
    required this.onRatioChanged,
  });

  final double totalExtent;
  final double firstExtent;
  final double minExtent;
  final double maxExtent;
  final ValueChanged<double> onRatioChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanUpdate: (details) {
        final newFirst = (firstExtent + details.delta.dy).clamp(minExtent, maxExtent);
        var newRatio = newFirst / totalExtent;
        newRatio = newRatio.clamp(0.05, 0.95);
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
    super.key,
    required this.totalExtent,
    required this.firstExtent,
    required this.minExtent,
    required this.maxExtent,
    required this.onRatioChanged,
  });

  final double totalExtent;
  final double firstExtent;
  final double minExtent;
  final double maxExtent;
  final ValueChanged<double> onRatioChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanUpdate: (details) {
        final newFirst = (firstExtent + details.delta.dx).clamp(minExtent, maxExtent);
        var newRatio = newFirst / totalExtent;
        newRatio = newRatio.clamp(0.05, 0.95);
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
