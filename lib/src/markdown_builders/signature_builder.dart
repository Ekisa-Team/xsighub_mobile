import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:xsighub_mobile/src/theme/button.dart';

class SignatureSyntax extends md.InlineSyntax {
  static const _pattern = r'\[signature:(.*?)\]\((.*?)\)';

  SignatureSyntax() : super(_pattern);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final signatureName = match[1];
    final signatureText = match[2];

    final textElement = md.Element.text('signature', signatureText ?? 'Firmar');
    textElement.attributes['signatureName'] =
        signatureName ?? '--unknown-signature--';

    parser.addNode(textElement);

    return true;
  }
}

class SignatureBuilder extends MarkdownElementBuilder {
  SignatureBuilder({
    required this.onPressed,
  });

  final ValueSetter onPressed;

  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    if (element.tag == 'signature') {
      return ElevatedButton.icon(
        style: primaryButtonStyle,
        label: Text(element.textContent),
        icon: const Icon(Icons.draw_rounded),
        onPressed: () => onPressed(element.attributes['signatureName']),
      );
    }

    return super.visitElementAfter(element, preferredStyle)!;
  }
}
