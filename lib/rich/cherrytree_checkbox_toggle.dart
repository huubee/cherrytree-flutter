import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// Toggles CherryTree-style `[ ]` / `[x]` markers when the user taps on the marker.
class CherrytreeCheckboxToggle {
  CherrytreeCheckboxToggle._();

  static final _lineCheckbox = RegExp(r'^\s*(?:-\s*)?\[[ xX]\]');

  /// Returns `true` if a checkbox was toggled (caller may still want default tap handling).
  static bool tryToggleAtTapOffset(
    QuillController controller,
    int tapOffset,
  ) {
    final plain = controller.document.toPlainText();
    if (plain.isEmpty) return false;
    final o = tapOffset.clamp(0, plain.length);
    final lineStart = o == 0 ? 0 : plain.lastIndexOf('\n', o - 1) + 1;
    var lineEnd = plain.indexOf('\n', lineStart);
    if (lineEnd < 0) lineEnd = plain.length;
    final line = plain.substring(lineStart, lineEnd);
    final m = _lineCheckbox.firstMatch(line);
    if (m == null) return false;
    final relBracket = m.group(0)!.indexOf('[');
    final bracketStart = lineStart + m.start + relBracket;
    const bracketLen = 3;
    if (o < bracketStart || o >= bracketStart + bracketLen) return false;

    final mid = plain[bracketStart + 1];
    final newMid = (mid == ' ' || mid == 'x' || mid == 'X') ? (mid == ' ' ? 'x' : ' ') : null;
    if (newMid == null) return false;

    controller.replaceText(
      bracketStart + 1,
      1,
      newMid,
      TextSelection.collapsed(offset: o),
    );
    return true;
  }
}
