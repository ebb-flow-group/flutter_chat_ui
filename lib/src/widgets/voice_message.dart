import 'dart:async';

import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import '../util.dart';
import 'inherited_chat_theme.dart';
import 'inherited_l10n.dart';
import 'inherited_user.dart';

enum PlayerState { stopped, playing, paused }

/// A class that represents file message widget
class _VoiceMessage extends StatelessWidget {
  /// Creates a file message widget based on a [types.VoiceMessage]
  const _VoiceMessage({
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

class VoiceMessage extends StatefulWidget {
  /// Creates a voice message widget based on a [types.VoiceMessage]
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
  _VoiceMessageState createState() => _VoiceMessageState();
}

class _VoiceMessageState extends State<VoiceMessage> {
  AudioPlayer audioPlayer = AudioPlayer();

  Duration? duration;
  Duration? position;

  PlayerState playerState = PlayerState.stopped;

  get isPlaying => playerState == PlayerState.playing;

  get isPaused => playerState == PlayerState.paused;

  get durationText =>
      duration != null ? duration.toString().split('.').first : '';

  get positionText =>
      position != null ? position.toString().split('.').first : '';

  bool isMuted = false;

  StreamSubscription? _positionSubscription;
  StreamSubscription? _audioPlayerStateSubscription;

  @override
  void initState() {
    super.initState();
    // initAudioPlayer();
  }

  @override
  void dispose() {
    _positionSubscription!.cancel();
    _audioPlayerStateSubscription!.cancel();
    audioPlayer.stop();
    super.dispose();
  }

  void initAudioPlayer() {
    audioPlayer = AudioPlayer();
    _positionSubscription = audioPlayer.onAudioPositionChanged
        .listen((p) => setState(() => position = p));
    _audioPlayerStateSubscription =
        audioPlayer.onPlayerStateChanged.listen((s) {
          if (s == AudioPlayerState.PLAYING) {
            setState(() => duration = audioPlayer.duration);
          } else if (s == AudioPlayerState.STOPPED) {
            onComplete();
            setState(() {
              position = duration;
            });
          }
        }, onError: (msg) {
          setState(() {
            playerState = PlayerState.stopped;
            duration = const Duration(seconds: 0);
            position = const Duration(seconds: 0);
          });
        });
  }

  void onComplete() {
    audioPlayer.stop();
    setState(() {
      playerState = PlayerState.stopped;
      duration = const Duration(seconds: 0);
      position = const Duration(seconds: 0);
    });
  }

  void play(String uri) async {

    /*if(playerState == PlayerState.playing || playerState == PlayerState.paused)
    {
      print('PLAYER STATE: $playerState');
      await audioPlayer.stop();
      setState(() {
        playerState = PlayerState.stopped;
        duration = const Duration(seconds: 0);
        position = const Duration(seconds: 0);
      });
    }*/

    audioPlayer = AudioPlayer();
    _positionSubscription = audioPlayer.onAudioPositionChanged
        .listen((p) => setState(() => position = p));
    _audioPlayerStateSubscription =
        audioPlayer.onPlayerStateChanged.listen((s) {
          if (s == AudioPlayerState.PLAYING) {
            setState(() => duration = audioPlayer.duration);
          } else if (s == AudioPlayerState.STOPPED) {
            onComplete();
            setState(() {
              position = duration;
            });
          }
        }, onError: (msg) {
          setState(() {
            playerState = PlayerState.stopped;
            duration = const Duration(seconds: 0);
            position = const Duration(seconds: 0);
          });
        });

    await audioPlayer.play(uri, isLocal: true);

    setState(() {
      playerState = PlayerState.playing;
    });
  }
  
  Future stop() async
  {
    await audioPlayer.stop();
    setState(() {
      playerState = PlayerState.paused;
      playerState = PlayerState.stopped;
      duration = const Duration(seconds: 0);
      position = const Duration(seconds: 0);
    });
  }

  Future pause() async {
    await audioPlayer.pause();
    await audioPlayer.stop();
    setState(() {
      playerState = PlayerState.paused;
      playerState = PlayerState.stopped;
      duration = const Duration(seconds: 0);
      position = const Duration(seconds: 0);
    });
    // setState(() => playerState = PlayerState.paused);
  }

  @override
  Widget build(BuildContext context) {
    final _user = InheritedUser.of(context).user;
    final _color = _user.id == widget.message.author.id
        ? InheritedChatTheme.of(context).theme.sentMessageDocumentIconColor
        : InheritedChatTheme.of(context).theme.receivedMessageDocumentIconColor;

    return Semantics(
      key: widget.key,
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
                  : _buildControlAndProgressView()/*AudioController(key: UniqueKey(), message: widget.message)*/,
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
                      widget.message.name,
                      style: _user.id == widget.message.author.id
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
                      child: Text(formatBytes(widget.message.size),
                          style: _user.id == widget.message.author.id
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

  Row _buildControlAndProgressView() =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          height: 42,
          width: 42,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: position != null && position!.inMilliseconds > 0
                    ? (position?.inMilliseconds.toDouble() ?? 0.0) /
                    (duration?.inMilliseconds.toDouble() ?? 0.0)
                    : 0.0,
                valueColor: const AlwaysStoppedAnimation(Colors.cyan),
                backgroundColor: Colors.grey.shade400,
              ),
              GestureDetector(
                  onTap: () {
                    if (playerState == PlayerState.playing) {
                      stop();
                    } else {
                      print('PLAYED AUDIO PATH: ${widget.message.uri}');
                      play(widget.message.uri);
                    }
                  },
                  child: playerState == PlayerState.playing
                      ? const Icon(
                    Icons.stop,
                    color: Colors.black,
                  )
                      : const Icon(
                    Icons.play_arrow,
                    color: Colors.black,
                  )),
            ],
          ),
        ),
      ]);
}

class AudioController extends StatefulWidget {
  /// [types.VoiceMessage]
  final types.VoiceMessage message;

  const AudioController({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  _AudioControllerState createState() => _AudioControllerState();
}

class _AudioControllerState extends State<AudioController> {
  AudioPlayer audioPlayer = AudioPlayer();

  Duration? duration;
  Duration? position;

  PlayerState playerState = PlayerState.stopped;

  get isPlaying => playerState == PlayerState.playing;

  get isPaused => playerState == PlayerState.paused;

  get durationText =>
      duration != null ? duration.toString().split('.').first : '';

  get positionText =>
      position != null ? position.toString().split('.').first : '';

  bool isMuted = false;

  StreamSubscription? _positionSubscription;
  StreamSubscription? _audioPlayerStateSubscription;

  @override
  void initState() {
    super.initState();
    initAudioPlayer();
  }

  @override
  void dispose() {
    _positionSubscription!.cancel();
    _audioPlayerStateSubscription!.cancel();
    audioPlayer.stop();
    super.dispose();
  }

  void initAudioPlayer() {
    audioPlayer = AudioPlayer();
    _positionSubscription = audioPlayer.onAudioPositionChanged
        .listen((p) => setState(() => position = p));
    _audioPlayerStateSubscription =
        audioPlayer.onPlayerStateChanged.listen((s) {
      if (s == AudioPlayerState.PLAYING) {
        setState(() => duration = audioPlayer.duration);
      } else if (s == AudioPlayerState.STOPPED) {
        onComplete();
        setState(() {
          position = duration;
        });
      }
    }, onError: (msg) {
      setState(() {
        playerState = PlayerState.stopped;
        duration = Duration(seconds: 0);
        position = Duration(seconds: 0);
      });
    });
  }

  void onComplete() {
    setState(() => playerState = PlayerState.stopped);
    _positionSubscription!.cancel();
    _audioPlayerStateSubscription!.cancel();
    audioPlayer.stop();
  }

  void play(String uri) async {
    await audioPlayer.play(uri, isLocal: true);

    setState(() {
      playerState = PlayerState.playing;
    });
  }

  Future pause() async {
    await audioPlayer.pause();
    setState(() => playerState = PlayerState.paused);
  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        height: 42,
        width: 42,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: position != null && position!.inMilliseconds > 0
                  ? (position?.inMilliseconds.toDouble() ?? 0.0) /
                  (duration?.inMilliseconds.toDouble() ?? 0.0)
                  : 0.0,
              valueColor: const AlwaysStoppedAnimation(Colors.cyan),
              backgroundColor: Colors.grey.shade400,
            ),
            GestureDetector(
                onTap: () {
                  if (playerState == PlayerState.playing) {
                    pause();
                  } else {
                    print('PLAYED AUDIO PATH: ${widget.message.uri}');
                    play(widget.message.uri);
                  }
                },
                child: playerState == PlayerState.playing
                    ? const Icon(
                  Icons.pause,
                  color: Colors.black,
                )
                    : const Icon(
                  Icons.play_arrow,
                  color: Colors.black,
                )),
          ],
        ),
      ),
    ]);
  }
}
