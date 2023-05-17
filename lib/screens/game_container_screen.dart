import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maze_tales_multiplatform/game_core/maze_tales_game.dart';

class GameContainerScreen extends StatefulWidget {
  const GameContainerScreen({super.key});

  @override
  State<GameContainerScreen> createState() => _GameContainerScreenState();
}

class _GameContainerScreenState extends State<GameContainerScreen> {
  final _mazeTalesGame = MazeTalesGame();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(game: _mazeTalesGame),
    );
  }
}
