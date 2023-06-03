import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

class SignatureSyntax extends md.InlineSyntax {
  static const _pattern = r'\[signature:(.*?)\]\((.*?)\)';

  SignatureSyntax() : super(_pattern);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final signatureName = match[1];
    final signatureText = match[2];

    final textElement = md.Element.text('signature', signatureText ?? 'Firmar');
    textElement.attributes['signatureName'] = signatureName ?? '';

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
        onPressed: () => onPressed(element.attributes['signatureName']),
        label: Text(element.textContent),
        icon: const Icon(Icons.draw_rounded),
      );
    }

    return super.visitElementAfter(element, preferredStyle)!;
  }
}
