import 'package:cherrytree_flutter/cherrytree/cherrytree_node_icon_theme.dart';
import 'package:flutter_test/flutter_test.dart';

String? _fakeStock(int id) => 'assets/cherrytree_icons/stock_$id.svg';

void main() {
  test('custom_icon_id wins when non-zero', () {
    const t = CherrytreeNodeIconTheme.defaults;
    final p = t.resolveAssetPath(
      customIconId: 99,
      treeDepth: 0,
      stockPath: _fakeStock,
    );
    expect(p, 'assets/cherrytree_icons/stock_99.svg');
  });

  test('cherry mode uses depth for custom_icon_id 0', () {
    const t = CherrytreeNodeIconTheme.defaults;
    expect(
      t.resolveAssetPath(
        customIconId: 0,
        treeDepth: 3,
        stockPath: _fakeStock,
      ),
      endsWith('cherry_cyan.svg'),
    );
  });

  test('none mode uses no-icon stock id', () {
    const t = CherrytreeNodeIconTheme(mode: CherrytreeNodeIconMode.none);
    final p = t.resolveAssetPath(
      customIconId: 0,
      treeDepth: 9,
      stockPath: _fakeStock,
    );
    expect(p, 'assets/cherrytree_icons/stock_26.svg');
  });

  test('config string round-trip matches upstream letters', () {
    expect(
      CherrytreeNodeIconTheme.modeToConfigString(CherrytreeNodeIconMode.cherry),
      'c',
    );
    expect(
      CherrytreeNodeIconTheme.modeToConfigString(CherrytreeNodeIconMode.customDefault),
      'b',
    );
    expect(
      CherrytreeNodeIconTheme.modeToConfigString(CherrytreeNodeIconMode.none),
      'n',
    );
    expect(CherrytreeNodeIconTheme.modeFromConfigString('c'), CherrytreeNodeIconMode.cherry);
    expect(CherrytreeNodeIconTheme.modeFromConfigString('b'), CherrytreeNodeIconMode.customDefault);
    expect(CherrytreeNodeIconTheme.modeFromConfigString('n'), CherrytreeNodeIconMode.none);
  });
}
