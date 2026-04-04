import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'cherrytree_node_icon_theme.dart';
import 'cherrytree_stock_icon_names.dart';

/// CherryTree node stock icons: names match upstream `giuspen/cherrytree` `icons/*.svg`
/// (GPLv3 — bundled under `assets/cherrytree_icons/`).
class CherrytreeStockIcons {
  CherrytreeStockIcons._();

  /// Asset path for [id] &gt; 0, or `null` if unknown / none.
  static String? assetPathForStockId(int id) {
    if (id <= 0 || id >= kCherrytreeStockIconNames.length) return null;
    final name = kCherrytreeStockIconNames[id];
    if (name == null) return null;
    return 'assets/cherrytree_icons/$name.svg';
  }

  /// Tree row icon — see [CherrytreeNodeIconTheme] for upstream `nodes_icons` / depth rules.
  static Widget treeIconForNode({
    required int customIconId,
    required int treeDepth,
    CherrytreeNodeIconTheme theme = CherrytreeNodeIconTheme.defaults,
    double size = 22,
    required Widget fallback,
  }) {
    final path = theme.resolveAssetPath(
      customIconId: customIconId,
      treeDepth: treeDepth,
      stockPath: assetPathForStockId,
    );
    return SvgPicture.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
      placeholderBuilder: (_) => fallback,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }
}
