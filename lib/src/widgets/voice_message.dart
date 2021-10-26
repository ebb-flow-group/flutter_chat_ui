import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_sound/public/util/flutter_sound_helper.dart';
import '../util.dart';
import 'inherited_chat_theme.dart';
import 'inherited_l10n.dart';
import 'inherited_user.dart';

// enum PlayerState { stopped, playing, paused }

class VoiceMessage extends StatefulWidget {
  /// Creates a voice message widget based on a [types.VoiceMessage]
  const VoiceMessage({
    Key? key,
    @required this.message,
    @required this.currentUserIsAuthor,
    this.onPressed,
  }) : super(key: key);

  /// [types.VoiceMessage]
  final types.VoiceMessage? message;

  final bool? currentUserIsAuthor;

  /// Called when user taps on a file
  final void Function(types.VoiceMessage)? onPressed;

  @override
  _VoiceMessageState createState() => _VoiceMessageState();
}

class _VoiceMessageState extends State<VoiceMessage> {
  AudioPlayer? audioPlayer;

  Duration? duration;
  Duration? position;

  PlayerState playerState = PlayerState.STOPPED;

  /*get isPlaying => playerState == PlayerState.playing;

  get isPaused => playerState == PlayerState.paused;*/

  get durationText =>
      duration != null ? duration.toString().split('.').first : '';

  get positionText =>
      position != null ? position.toString().split('.').first : '';

  bool isMuted = false;

  /*StreamSubscription? _positionSubscription;
  StreamSubscription? _audioPlayerStateSubscription;*/

  List<String> urlList = [];
  String firstUrl = '';
  Timer? timer;
  Duration interval = const Duration(seconds: 1);
  int globalTimerMaxSeconds = 0, currentSeconds = 0, timerMaxSeconds = 0;
  String get getterTimerText =>
      '${((timerMaxSeconds - currentSeconds) ~/ 60).toString().padLeft(2, '0')}:${((timerMaxSeconds - currentSeconds) % 60).toString().padLeft(2, '0')}';

  String timerText = '';

  @override
  void initState() {
    super.initState();

    setState(() {
      globalTimerMaxSeconds =  widget.message!.duration;
      timerMaxSeconds = widget.message!.duration;
      timerText = '${timerMaxSeconds}s';
    });
  }

  void startTimeout([int? milliseconds]) {
    final duration = interval;
    Timer.periodic(duration, (timer) {
      if(mounted)
      {
        setState(() {
          //        print(timer.tick);
          this.timer = timer;
          currentSeconds = timer.tick;
          timerText = getterTimerText;
          if (timer.tick >= timerMaxSeconds) {
            timer.cancel();
            timerMaxSeconds = globalTimerMaxSeconds;
            timerText = '${globalTimerMaxSeconds}s';
          }
        });
      }
    });
  }

  @override
  void dispose() {
    /*_positionSubscription!.cancel();
    _audioPlayerStateSubscription!.cancel();*/
    if(audioPlayer != null) audioPlayer!.dispose();
    super.dispose();
  }

  void onComplete() {
    audioPlayer!.stop();
    setState(() {
      playerState = PlayerState.COMPLETED;
      if(Platform.isAndroid)
        {
          duration = const Duration(seconds: 0);
          position = const Duration(seconds: 0);
        }
    });
  }

  void play() async{

    audioPlayer = AudioPlayer(playerId: widget.message!.uri.split('/').last);
    audioPlayer!.onAudioPositionChanged
        .listen((p) => setState(() => position = p));
    audioPlayer!.onPlayerStateChanged.listen((s) {
      if (s == PlayerState.PLAYING) {
        audioPlayer!.onDurationChanged.listen((Duration d) {
          print('Max duration: $d');
          setState(() => duration = d);
        });
        setState(() {
          playerState = PlayerState.PLAYING;
          print('PLAYINGGGG');
          Future.delayed(const Duration(seconds: 1), () => startTimeout());
        });
      } else if (s == PlayerState.PAUSED) {
        setState(() {
          playerState = PlayerState.PAUSED;
          print('PAUSEDDDDD');
        });
      } else if (s == PlayerState.COMPLETED) {
       setState(() {
         playerState = PlayerState.COMPLETED;
         print('COMPLETEDDDDD');
       });
        onComplete();

        // audioPlayer.dispose();
      }
    }, onError: (msg) {
      setState(() {
        playerState = PlayerState.COMPLETED;
        print('STOPPPED BCOZ ERROR');
      });
      print('ERORRRRRRR: $msg');
      // onStop();

      // audioPlayer.dispose();
    });

    await audioPlayer!.play(widget.message!.uri, isLocal: false);
  }

  Future stop() async
  {
    await audioPlayer!.stop();
    setState(() {
      playerState = PlayerState.PAUSED;
      playerState = PlayerState.STOPPED;
      duration = const Duration(seconds: 0);
      position = const Duration(seconds: 0);
    });
  }

  Future pause() async {
    await audioPlayer!.pause();
    setState(() {
      playerState = PlayerState.PAUSED;
      timer!.cancel();
      timerMaxSeconds = timerMaxSeconds - currentSeconds;
    });
    // setState(() => playerState = PlayerState.paused);
  }

  Future resume() async {
    await audioPlayer!.resume();
    setState(() {
      // firstUrl = widget.message.uri;
      playerState = PlayerState.PLAYING;
    });
    // startTimeout();
    // setState(() => playerState = PlayerState.paused);
  }

  @override
  Widget build(BuildContext context) {
    final _user = InheritedUser.of(context)!.user;
    final _color = _user!.id == widget.message!.author.id
        ? InheritedChatTheme.of(context)!.theme!.sentMessageDocumentIconColor
        : InheritedChatTheme.of(context)!.theme!.receivedMessageDocumentIconColor;

    return Semantics(
      key: widget.key,
      label: InheritedL10n.of(context)!.l10n!.fileButtonAccessibilityLabel,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 24, 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [

            GestureDetector(
                onTap: () {
                  if (playerState == PlayerState.PLAYING) {
                    pause();
                  } else if(playerState == PlayerState.PAUSED){
                    resume();
                  }else {
                    print('PLAYED AUDIO PATH: ${widget.message!.uri}');
                    play();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 14.0),
                  child: playerState == PlayerState.PLAYING
                      ? const Icon(
                    Icons.pause_rounded,
                    color: Colors.white,
                    size: 34,
                  )
                      : const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                )),

            Expanded(
              child: LinearProgressIndicator(
                value: position != null && position!.inSeconds > 0 && duration != null && duration!.inSeconds > 0
                    ? (position?.inSeconds.toDouble() ?? 0.0) /
                    (duration?.inSeconds.toDouble() ?? 0.0)
                    : 0.0,
                valueColor: const AlwaysStoppedAnimation(Colors.white),
                backgroundColor: Colors.grey[300],
                minHeight: 4.5,
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 24.0),
              child: Text(
                timerText,
                style: _user.id == widget.message!.author.id
                    ? InheritedChatTheme.of(context)!
                    .theme!
                    .sentMessageBodyTextStyle
                    : InheritedChatTheme.of(context)!
                    .theme!
                    .receivedMessageBodyTextStyle,
                textWidthBasis: TextWidthBasis.longestLine,
              ),
            ),

            /*Container(
              decoration: BoxDecoration(
                color: _color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(21),
              ),
              height: 42,
              width: 42,
              child: InheritedChatTheme.of(context).theme.documentIcon ?? _buildControlAndProgressView()*//*AudioController(key: UniqueKey(), message: widget.message)*//*,
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
            ),*/
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
                value: position != null && position!.inMilliseconds > 0 && duration != null && duration!.inMilliseconds > 0
                    ? (position?.inMilliseconds.toDouble() ?? 0.0) /
                    (duration?.inMilliseconds.toDouble() ?? 0.0)
                    : 0.0,
                valueColor: const AlwaysStoppedAnimation(Colors.cyan),
                backgroundColor: Colors.grey.shade400,
              ),
              GestureDetector(
                  onTap: () {
                    if (playerState == PlayerState.PLAYING) {
                      pause();
                    } else if(playerState == PlayerState.PAUSED){
                      resume();
                    }else {
                      print('PLAYED AUDIO PATH: ${widget.message!.uri}');
                      play();
                    }
                  },
                  child: playerState == PlayerState.PLAYING
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
