/// Layout constants so spacing and breakpoints stay consistent (see DEVELOPMENT_GUIDELINES).
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;

  /// Horizontal indent per tree level in the outline.
  static const double treeIndentStep = 16;

  /// Fixed width of the tree column on wide layouts.
  static const double sidebarWidth = 280;

  /// Minimum width to show tree + editor side by side.
  static const double wideLayoutBreakpoint = 720;

  /// Space between title field and body field in the editor.
  static const double editorFieldGap = 12;

  /// Outer padding around the note editor surface.
  static const double editorPadding = 16;
}
