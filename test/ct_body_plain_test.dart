import 'package:cherrytree_flutter/cherrytree/ct_body_plain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CtBodyPlain.normalizeSeparatedCheckboxLines', () {
    test('merges standalone checkbox line with following label', () {
      expect(
        CtBodyPlain.normalizeSeparatedCheckboxLines('[ ]\nsmbtree'),
        '[ ] smbtree',
      );
    });

    test('merges bullet checkbox form', () {
      expect(
        CtBodyPlain.normalizeSeparatedCheckboxLines('- [ ]\nNikto'),
        '- [ ] Nikto',
      );
    });

    test('does not merge when next line is another empty checkbox', () {
      const input = '[ ]\n[ ]';
      expect(CtBodyPlain.normalizeSeparatedCheckboxLines(input), input);
    });

    test('does not merge across blank line', () {
      const input = '[ ]\n\nsmbtree';
      expect(CtBodyPlain.normalizeSeparatedCheckboxLines(input), input);
    });

    test('leaves checkbox with inline text unchanged', () {
      const input = '[ ] nmap -sn 10.11.1.*';
      expect(CtBodyPlain.normalizeSeparatedCheckboxLines(input), input);
    });
  });
}
