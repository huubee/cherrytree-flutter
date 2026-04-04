import 'package:shared_preferences/shared_preferences.dart';

/// Upstream CherryTree **tree** icon behaviour (for rich/plain nodes when `custom_icon_id` is 0).
///
/// Reference implementation: [CtTreeStore::get_node_icon](https://github.com/giuspen/cherrytree/blob/master/src/ct/ct_treestore.cc)
/// (`nodeDepth`, `syntax`, `customIconId`).
///
/// **Persisted settings** (desktop `config.cfg` ini, `[tree]` group) — see
/// [CtConfig](https://github.com/giuspen/cherrytree/blob/master/src/ct/ct_config.h) /
/// [ct_config.cc](https://github.com/giuspen/cherrytree/blob/master/src/ct/ct_config.cc):
///
/// | Key | Type | Upstream field | Meaning |
/// |-----|------|----------------|---------|
/// | `nodes_icons` | string | `nodesIcons` | `"c"` = cherries by depth, `"b"` = one default stock icon, `"n"` = no icon |
/// | `default_icon_text` | int | `defaultIconText` | Stock index when mode is `"b"` (default bullet id = 25) |
///
/// Constants: [NODE_ICON_TYPE_CHERRY], [NODE_ICON_TYPE_CUSTOM], [NODE_ICON_TYPE_NONE] in
/// `src/ct/ct_const.h` (`"c"`, `"b"`, `"n"`).
///
/// Depth colours: [NODE_CHERRY_ICONS] in `src/ct/ct_const.h` (11 cherries, repeated with `% 11`).
///
/// Per-node override: non-zero `custom_icon_id` in XML / SQLite → always [CtStockIcon::at](id).
///
/// Code/syntax nodes use a separate mapping (`get_code_icon_name`) — not modelled here yet.
class CherrytreeNodeIconTheme {
  const CherrytreeNodeIconTheme({
    this.mode = CherrytreeNodeIconMode.cherry,
    this.defaultStockId = kCherrytreeDefaultIconStockId,
  });

  /// Upstream default: [NODE_ICON_TYPE_CHERRY] (`"c"`).
  static const CherrytreeNodeIconTheme defaults = CherrytreeNodeIconTheme();

  /// [CtConst::NODE_ICON_BULLET_ID] — `ct_node_bullet`.
  static const int kCherrytreeDefaultIconStockId = 25;

  /// [CtConst::NODE_ICON_NO_ICON_ID] — `ct_node_no_icon`.
  static const int kCherrytreeNoIconStockId = 26;

  /// Same order as upstream `NODE_CHERRY_ICONS` in `ct_const.h`.
  static const List<String> cherryIconNamesByDepth = <String>[
    'cherry_red',
    'cherry_blue',
    'cherry_orange',
    'cherry_cyan',
    'cherry_orange_dark',
    'cherry_sherbert',
    'cherry_yellow',
    'cherry_green',
    'cherry_purple',
    'cherry_black',
    'cherry_grey',
  ];

  final CherrytreeNodeIconMode mode;
  final int defaultStockId;

  /// Upstream `nodes_icons` string in `config.cfg`.
  static CherrytreeNodeIconMode modeFromConfigString(String? s) {
    switch (s) {
      case 'b':
        return CherrytreeNodeIconMode.customDefault;
      case 'n':
        return CherrytreeNodeIconMode.none;
      case 'c':
      default:
        return CherrytreeNodeIconMode.cherry;
    }
  }

  static String? modeToConfigString(CherrytreeNodeIconMode m) {
    switch (m) {
      case CherrytreeNodeIconMode.cherry:
        return 'c';
      case CherrytreeNodeIconMode.customDefault:
        return 'b';
      case CherrytreeNodeIconMode.none:
        return 'n';
    }
  }

  /// Returns an asset path under `assets/cherrytree_icons/`. [stockPath] maps stock id → path or null.
  String resolveAssetPath({
    required int customIconId,
    required int treeDepth,
    required String? Function(int stockId) stockPath,
  }) {
    if (customIconId != 0) {
      return stockPath(customIconId) ??
          _cherryAssetForDepth(treeDepth);
    }
    switch (mode) {
      case CherrytreeNodeIconMode.none:
        return stockPath(kCherrytreeNoIconStockId) ??
            _cherryAssetForDepth(treeDepth);
      case CherrytreeNodeIconMode.customDefault:
        return stockPath(defaultStockId) ?? _cherryAssetForDepth(treeDepth);
      case CherrytreeNodeIconMode.cherry:
        return _cherryAssetForDepth(treeDepth);
    }
  }

  static String _cherryAssetForDepth(int treeDepth) {
    final i = treeDepth % cherryIconNamesByDepth.length;
    return 'assets/cherrytree_icons/${cherryIconNamesByDepth[i]}.svg';
  }

  // --- Optional: persist like upstream [tree] section (for Settings UI later) ---

  static const prefKeyNodesIcons = 'cherrytree_nodes_icons';
  static const prefKeyDefaultIconText = 'cherrytree_default_icon_text';

  static Future<CherrytreeNodeIconTheme> loadFromPrefs() async {
    final p = await SharedPreferences.getInstance();
    final modeStr = p.getString(prefKeyNodesIcons);
    final def = p.getInt(prefKeyDefaultIconText);
    return CherrytreeNodeIconTheme(
      mode: modeFromConfigString(modeStr),
      defaultStockId: def ?? kCherrytreeDefaultIconStockId,
    );
  }

  static Future<void> saveToPrefs(CherrytreeNodeIconTheme theme) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
      prefKeyNodesIcons,
      modeToConfigString(theme.mode)!,
    );
    await p.setInt(prefKeyDefaultIconText, theme.defaultStockId);
  }
}

/// Mirrors `nodes_icons` / [NODE_ICON_TYPE_*] in upstream `ct_const.h`.
enum CherrytreeNodeIconMode {
  /// `"c"` — cycle [CherrytreeNodeIconTheme.cherryIconNamesByDepth] by tree depth.
  cherry,

  /// `"b"` — use [CherrytreeNodeIconTheme.defaultStockId] for every plain/rich node with no custom icon.
  customDefault,

  /// `"n"` — use `ct_node_no_icon` (stock id [kCherrytreeNoIconStockId]).
  none,
}
