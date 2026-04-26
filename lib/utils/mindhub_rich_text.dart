import 'package:flutter/material.dart';

class MindHubRichText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;

  const MindHubRichText({
    Key? key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.start,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      _buildTextSpan(context),
      style: style,
      textAlign: textAlign,
    );
  }


  TextSpan _buildTextSpan(BuildContext context) {
    final List<TextSpan> children = [];
    final String textContent = text;

    // Regex to match tags and normal text
    final RegExp regExp = RegExp(r'(<[^>]+>)|([^<]+)');
    final Iterable<Match> matches = regExp.allMatches(textContent);

    TextStyle baseStyle = style ?? DefaultTextStyle.of(context).style;
    List<TextStyle> styleStack = [baseStyle];

    for (final Match match in matches) {
      final String part = match.group(0)!;
      if (part.startsWith('<')) {
        // Tag handling
        if (part.startsWith('</')) {
          if (styleStack.length > 1) styleStack.removeLast();
        } else {
          TextStyle nextStyle = styleStack.last;
          if (part == '<b>') {
            nextStyle = nextStyle.copyWith(fontWeight: FontWeight.bold);
          } else if (part == '<i>') {
            nextStyle = nextStyle.copyWith(fontStyle: FontStyle.italic);
          } else if (part == '<u>') {
            nextStyle = nextStyle.copyWith(decoration: TextDecoration.underline);
          } else if (part.startsWith('<color=')) {
            try {
              // Handle both <color=#RRGGBB> and potentially shorter ones if any
              final hexMatch = RegExp(r'#([A-Fa-f0-9]{6})').firstMatch(part);
              if (hexMatch != null) {
                final hex = hexMatch.group(0)!;
                nextStyle = nextStyle.copyWith(
                    color: Color(int.parse(hex.replaceFirst('#', '0xFF'))));
              }
            } catch (_) {}
          }
          styleStack.add(nextStyle);
        }
      } else {
        // Text content handling
        children.add(TextSpan(text: part, style: styleStack.last));
      }
    }

    if (children.isEmpty && textContent.isNotEmpty) {
        return TextSpan(text: textContent, style: baseStyle);
    }

    return TextSpan(children: children);
  }
}
