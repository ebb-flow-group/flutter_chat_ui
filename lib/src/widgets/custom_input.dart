import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/src/widgets/inherited_chat_theme.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class NewLineIntent extends Intent {
  const NewLineIntent();
}

class SendMessageIntent extends Intent {
  const SendMessageIntent();
}

class CustomInput extends StatefulWidget {

  /// Creates [Input] widget
  const CustomInput({
    Key? key,
    this.isAttachmentUploading,
    this.onVoiceMessagePressed,
    this.onAttachmentPressed,
    required this.onSendPressed,
    this.onTextChanged,
  }) : super(key: key);

  /// See [AttachmentButton.onPressed]
  final void Function()? onAttachmentPressed;
  final void Function()? onVoiceMessagePressed;

  /// Whether attachment is uploading. Will replace attachment button with a
  /// [CircularProgressIndicator]. Since we don't have libraries for
  /// managing media in dependencies we have no way of knowing if
  /// something is uploading so you need to set this manually.
  final bool? isAttachmentUploading;

  /// Will be called on [SendButton] tap. Has [types.PartialText] which can
  /// be transformed to [types.TextMessage] and added to the messages list.
  final void Function(types.PartialText) onSendPressed;

  /// Will be called whenever the text inside [TextField] changes
  final void Function(String)? onTextChanged;

  @override
  _CustomInputState createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> {

  final _inputFocusNode = FocusNode();
  bool _sendButtonVisible = false;
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textController.addListener(_handleTextControllerChange);
  }

  @override
  void dispose() {
    _inputFocusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _handleSendPressed() {
    final _partialText = types.PartialText(text: _textController.text.trim());
    widget.onSendPressed(_partialText);
    _textController.clear();
  }

  void _handleTextControllerChange() {
    setState(() {
      _sendButtonVisible = _textController.text.trim() != '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final _query = MediaQuery.of(context);
    return Material(
      elevation: 8.0,
      color: InheritedChatTheme.of(context).theme.backgroundColor,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          0,//24 + _query.padding.left,
          20,
          0, //24 + _query.padding.right,
          20 + _query.viewInsets.bottom + _query.padding.bottom,
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.mic,
                color: InheritedChatTheme.of(context).theme.secondaryColor,
              ),
              onPressed: widget.onVoiceMessagePressed,
            ),
            if (widget.onAttachmentPressed != null) _attachmentWidget(),
            Expanded(
              child: Container(
                /*decoration: BoxDecoration(
                    color: InheritedChatTheme.of(context).theme.backgroundColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey[300]!,
                          blurRadius: 10.0,
                          spreadRadius: 5),
                    ]),*/
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                  controller: _textController,
                  focusNode: _inputFocusNode,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                      hintText: 'Say something...', border: InputBorder.none,
                    hintStyle: InheritedChatTheme.of(context)
                        .theme
                        .inputTextStyle
                        .copyWith(
                      color: InheritedChatTheme.of(context)
                          .theme
                          .inputTextColor
                          .withOpacity(0.5),
                    ),
                  ),
                  style: InheritedChatTheme.of(context)
                      .theme
                      .inputTextStyle
                      .copyWith(
                    color: InheritedChatTheme.of(context)
                        .theme
                        .inputTextColor,
                  ),
                  maxLines: 5,
                  minLines: 1,
                  onChanged: widget.onTextChanged,
                ),
              ),
            ),

            IconButton(
              icon: Icon(
                  Icons.send,
                  color: _sendButtonVisible
                      ? InheritedChatTheme.of(context).theme.secondaryColor
                      : Colors.grey[400]
              ),
              onPressed: () {
                if(_sendButtonVisible) {
                  _handleSendPressed();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _attachmentWidget() {
    if (widget.isAttachmentUploading == true) {
      return Container(
        height: 24,
        margin: const EdgeInsets.only(right: 16),
        width: 24,
        child: CircularProgressIndicator(
          backgroundColor: Colors.transparent,
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            InheritedChatTheme.of(context).theme.inputTextColor,
          ),
        ),
      );
    } else {
      return IconButton(
        icon: Icon(
          Icons.add_circle_rounded,
          color: InheritedChatTheme.of(context).theme.secondaryColor,
        ),
        onPressed: widget.onAttachmentPressed,
      );
    }
  }
}
