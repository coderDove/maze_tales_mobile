import 'dart:ui';
import 'package:flame/components.dart';
import 'package:maze_tales_multiplatform/models/level_asset_type.dart';

class LevelAnimationComponent extends SpriteAnimationComponent {
  final String name;
  final LevelAssetType animationType;
  final List<Image> frames;
  final double timePerFrame;

  LevelAnimationComponent({
    required this.name,
    required this.animationType,
    required this.frames,
    required super.position,
    required super.size,
    this.timePerFrame = 0.05,
  });

  @override
  Future<void> onLoad() async {
    _setIdleState();
  }

  void playAnimation() {
    final animationSprites = frames.map((frame) => Sprite(frame)).toList();
    animation = SpriteAnimation.spriteList(animationSprites, stepTime: timePerFrame, loop: false);
    animation?.onComplete = _animationPlaybackFinished;
  }

  // Private instance
  void _setIdleState() {
    if (frames.isNotEmpty) {
      animation = SpriteAnimation.spriteList([Sprite(frames.first)], stepTime: timePerFrame, loop: false);
    } else {
      animation = null;
    }
  }

  void _animationPlaybackFinished() {
    _setIdleState();
  }
}
