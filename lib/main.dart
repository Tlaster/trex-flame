import 'dart:ui' as ui;

import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flame_splash_screen/flame_splash_screen.dart';
import 'package:flutter/services.dart';

import 'package:trex/game/game.dart';

void main() {
  runApp(const MaterialApp(
    title: 'TRexGame',
    color: Colors.white,
    debugShowCheckedModeBanner: false,
    home: const Scaffold(
      body: const TRexGameWrapper(),
    ),
  ));

  Flame.util.fullScreen();
}

class TRexGameWrapper extends StatefulWidget {
  const TRexGameWrapper({Key key, this.size}) : super(key: key);
  final Size size;
  @override
  _TRexGameWrapperState createState() => _TRexGameWrapperState();
}

class _TRexGameWrapperState extends State<TRexGameWrapper> {
  bool splashGone = false;
  TRexGame game;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() async {
    final bytes = await DefaultAssetBundle.of(context)
        .load("packages/trex/lib/assets/images/sprite.png");
    final codec = await ui.instantiateImageCodec(bytes.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    setState(() {
      game = TRexGame(
        spriteImage: frame.image,
        size: widget.size,
      );
      _focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return splashGone
        ? _buildGame(context)
        : FlameSplashScreen(
            theme: FlameSplashTheme.white,
            onFinish: (context) {
              setState(() {
                splashGone = true;
              });
            },
          );
  }

  void _onRawKeyEvent(RawKeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space) {
      game.onAction();
    }
  }

  Widget _buildGame(BuildContext context) {
    if (game == null) {
      return const Center(
        child: Text("Loading"),
      );
    }
    return Container(
      color: Colors.white,
      constraints: const BoxConstraints.expand(),
      child: Container(
          child: RawKeyboardListener(
        key: const ObjectKey("neh"),
        child: game.widget,
        focusNode: _focusNode,
        onKey: _onRawKeyEvent,
      )),
    );
  }
}
