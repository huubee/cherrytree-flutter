/// Durations for interaction and persistence (Spike A).
abstract final class AppTiming {
  /// Delay after last keystroke before writing JSON to disk.
  static const Duration saveDebounce = Duration(milliseconds: 450);
}
