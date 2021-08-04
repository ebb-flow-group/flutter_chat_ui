import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import '../util.dart';
import 'inherited_chat_theme.dart';
import 'inherited_l10n.dart';
import 'inherited_user.dart';

/// A class that represents file message widget
class VoiceMessage extends StatelessWidget {
  /// Creates a file message widget based on a [types.VoiceMessage]
  const VoiceMessage({
    Key? key,
    required this.message,
    this.onPressed,
  }) : super(key: key);

  /// [types.VoiceMessage]
  final types.VoiceMessage message;

  /// Called when user taps on a file
  final void Function(types.VoiceMessage)? onPressed;

  @override
  Widget build(BuildContext context) {
    final _user = InheritedUser.of(context).user;
    final _color = _user.id == message.author.id
        ? InheritedChatTheme.of(context).theme.sentMessageDocumentIconColor
        : InheritedChatTheme.of(context).theme.receivedMessageDocumentIconColor;

    return Semantics(
      label: InheritedL10n.of(context).l10n.fileButtonAccessibilityLabel,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 24, 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: _color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(21),
              ),
              height: 42,
              width: 42,
              child: InheritedChatTheme.of(context).theme.documentIcon != null
                  ? InheritedChatTheme.of(context).theme.documentIcon!
                  : Icon(
                      Icons.play_arrow,
                      color: _color,
                    ),
            ),
            Flexible(
              child: Container(
                margin: const EdgeInsets.only(
                  left: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.name,
                      style: _user.id == message.author.id
                          ? InheritedChatTheme.of(context)
                              .theme
                              .sentMessageBodyTextStyle
                          : InheritedChatTheme.of(context)
                              .theme
                              .receivedMessageBodyTextStyle,
                      textWidthBasis: TextWidthBasis.longestLine,
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                        top: 4,
                      ),
                      child: Text(formatBytes(message.size),
                          style: _user.id == message.author.id
                              ? InheritedChatTheme.of(context)
                                  .theme
                                  .sentMessageCaptionTextStyle
                              : InheritedChatTheme.of(context)
                                  .theme
                                  .receivedMessageCaptionTextStyle),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
