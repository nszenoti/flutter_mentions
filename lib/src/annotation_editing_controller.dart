part of flutter_mentions;

/// A custom implementation of [TextEditingController] to support @ mention or other
/// trigger based mentions.
class AnnotationEditingController extends TextEditingController {
  Map<String, Annotation> _mapping;
  String? _pattern;
  Set<String> _picked = <String>{}; // set of mentions which are picked from box

  /// Triggers when the suggestion was added by tapping on suggestion.
  final Function(Map<String, dynamic> m)? onMentionDrop;

  // Generate the Regex pattern for matching all the suggestions in one.
  AnnotationEditingController(this._mapping, {this.onMentionDrop})
  // : _pattern = _mapping.keys.isNotEmpty
  //       ? "(${_mapping.keys.map((key) => RegExp.escape(key)).join('|')})"
  //       : null;

  {
    _pattern = null;

    if (_mapping.keys.isNotEmpty) {
      //TODO: Optimize :- instead of considering all eligible patterns (just include those pattern corresp to Mention picked by the user)

      // All valid candidate patterns for {mentions}
      var result = _mapping.keys.map((key) => RegExp.escape(key)).toList();
      // Priorties the Detection of long text mentions first
      result.sort((b, a) => a.toLowerCase().compareTo(b.toLowerCase()));
      var finalresult = result.join('|');
      // TODO: Decide if need to keep constraint of word boundary at end (inorder to identify the Mention)
      //var patf1 = "($finalresult)\\b"; // to avoid other unnecessary detection
      _pattern = finalresult;
    }
  }

  /// Track the picked mention from suggestion box
  void register(String s) {
    _picked.add(s);
  }

  /// Can be used to get the markup from the controller directly.
  String get markupText {
    var anots = <String>{};

    final someVal = _mapping.isEmpty
        ? text
        : text.splitMapJoin(
            RegExp('$_pattern'),
            onMatch: (Match match) {
              final mention = _mapping[match[0]!] ??
                  _mapping[_mapping.keys.firstWhere((element) {
                    final reg = RegExp(element);

                    return reg.hasMatch(match[0]!);
                  })]!;

              var a = match[0]!;
              var isPicked = _picked.contains(a);

              if (isPicked) {
                anots.add(a);
              }
              // Default markup format for mentions
              if (!mention.disableMarkup && isPicked) {
                return mention.markupBuilder != null
                    ? mention.markupBuilder!(
                        mention.trigger, mention.id!, mention.display!)
                    : '${mention.trigger}[__${mention.id}__](__${mention.display}__)';
              } else {
                return match[0]!;
              }
            },
            onNonMatch: (String text) {
              return text;
            },
          );

    // Update the picked annotations set
    var droppedOut = _picked.difference(anots);
    _picked = _picked.intersection(anots);

    // var dropped = _registry.intersection(anots);
    if (droppedOut.isNotEmpty) {
      for (var d in droppedOut) {
        //_registry.removeAll(droppedOut);
        var annot = _mapping[d];
        var m = {'id': annot?.id, 'display': annot?.display};
        onMentionDrop?.call(m);
      }
    }

    return someVal;
  }

  Map<String, Annotation> get mapping {
    return _mapping;
  }

  set mapping(Map<String, Annotation> _mapping) {
    this._mapping = _mapping;

    //_pattern = "(${_mapping.keys.map((key) => RegExp.escape(key)).join('|')})";
    var result = _mapping.keys.map((key) => RegExp.escape(key)).toList();
    result.sort((b, a) => a.toLowerCase().compareTo(b.toLowerCase()));
    var finalresult = result.join('|');
    //var patf1 = "($finalresult)\\b"; // to avoid other unnecessary detection
    _pattern = finalresult;
  }

  @override
  TextSpan buildTextSpan(
      {BuildContext? context, TextStyle? style, bool? withComposing}) {
    var children = <InlineSpan>[];
    //var anots = <String>{};

    if (_pattern == null || _pattern == '()') {
      children.add(TextSpan(text: text, style: style));
    } else {
      text.splitMapJoin(
        RegExp('$_pattern'),
        onMatch: (Match match) {
          if (_mapping.isNotEmpty) {
            final mention = _mapping[match[0]!] ??
                _mapping[_mapping.keys.firstWhere((element) {
                  final reg = RegExp(element);

                  return reg.hasMatch(match[0]!);
                })]!;

            var a = match[0];
            var isPicked = _picked.contains(a);

            if (isPicked) {
              children.add(
                TextSpan(
                  text: a,
                  style: style!.merge(mention.style),
                ),
              );
              //anots.add(a!);
            } else {
              children.add(TextSpan(text: a, style: style));
            }
          }
          return '';
        },
        onNonMatch: (String text) {
          children.add(TextSpan(text: text, style: style));
          return '';
        },
      );
    }

    return TextSpan(style: style, children: children);
  }
}
