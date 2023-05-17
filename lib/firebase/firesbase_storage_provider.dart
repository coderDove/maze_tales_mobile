import 'dart:ui';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flame/components.dart';
import 'package:flutter/rendering.dart';
import 'package:maze_tales_multiplatform/game_core/components/level_animation_component.dart';
import 'package:maze_tales_multiplatform/models/level_info.dart';
import 'package:maze_tales_multiplatform/services/image_loader.dart';

class FirebaseStorageProvider {
  final _storage = FirebaseStorage.instance;
  final _assetsRoot = 'maze_tales_levels';

  Future<void> fetchAnimationAssetsForLevel({required LevelInfo levelInfo}) async {
    for (var animationConfig in levelInfo.animations) {
      for (var animation in animationConfig.animations) {
        final assetsPath = '$_assetsRoot/${levelInfo.name}/animations/${animationConfig.type.name}/${animation.name}';
        final filesList = await _storage.ref().child(assetsPath).listAll();
        if (filesList.items.isNotEmpty) {
          List<Image> animationImages = [];
          for (var file in filesList.items) {
            final fileData = await file.getData();
            if (fileData != null) {
              final image = await ImageLoader.loadImageFromMemory(fileData);
              animationImages.add(image);
            }
          }

          final animationComponent = LevelAnimationComponent(
            name: animation.name,
            animationType: animationConfig.type,
            frames: animationImages,
            position: Vector2(animation.asset.x, animation.asset.y),
            size: Vector2(animation.asset.width, animation.asset.height),
          );

          print('Loaded');
        }
      }
    }
  }
}
