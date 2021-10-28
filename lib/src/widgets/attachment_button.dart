import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'inherited_chat_theme.dart';
import 'inherited_l10n.dart';

/// A class that represents attachment button widget
class AttachmentButton extends StatelessWidget {
  /// Creates attachment button widget
  const AttachmentButton({
    Key? key,
    this.onPressed,
  }) : super(key: key);

  /// Callback for attachment button tap event
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      margin: const EdgeInsets.only(right: 16),
      width: 24,
      child: IconButton(
        icon: SvgPicture.asset(
          'assets/icon/add1.svg',
          color: InheritedChatTheme.of(context)!.theme!.secondaryColor,
          width: 18,
          height: 18,
        ),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        tooltip:
            InheritedL10n.of(context)!.l10n!.attachmentButtonAccessibilityLabel,
      ),
    );
  }
}
