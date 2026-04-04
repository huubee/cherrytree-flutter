import 'package:cherrytree_flutter/rich/note_body_codec.dart';

/// Plain text extracted from stored body (Quill JSON or legacy plain string).
String plainBody(String stored) {
  return NoteBodyCodec.documentFromStorage(stored).toPlainText().trim();
}
