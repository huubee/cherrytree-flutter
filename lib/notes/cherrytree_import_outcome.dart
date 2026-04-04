import '../cherrytree/cherrytree_read_result.dart';

/// Successful pick + read; [sourcePath] may be null when the provider only returns bytes.
class CherrytreeImportOutcome {
  CherrytreeImportOutcome({
    required this.result,
    this.sourcePath,
    required this.fileNameLower,
  });

  final CherrytreeReadResult result;
  final String? sourcePath;
  final String fileNameLower;
}
