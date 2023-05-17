import 'package:flame/components.dart';
import 'package:maze_tales_multiplatform/game_core/maze_tales_game.dart';
import 'package:maze_tales_multiplatform/models/level_asset.dart';
import 'package:maze_tales_multiplatform/services/image_loader.dart';

class LevelBackground extends SpriteComponent with HasGameRef<MazeTalesGame> {
  final LevelAsset backgroundAsset;

  LevelBackground({required this.backgroundAsset});

  @override
  Future<void> onLoad() async {
    if (backgroundAsset.assetUrl != null) {
      final backgroundImage = await ImageLoader.loadImageFromUrl(backgroundAsset.assetUrl!);
      final backgroundSprite = Sprite(backgroundImage);
      sprite = backgroundSprite;
      size = backgroundSprite.originalSize;
    }
  }
}
