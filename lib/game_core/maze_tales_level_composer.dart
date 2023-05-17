import 'dart:ui' as ui;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';
import 'package:maze_tales_multiplatform/game_core/components/level_animation_component.dart';
import 'package:maze_tales_multiplatform/game_core/components/level_background.dart';
import 'package:maze_tales_multiplatform/game_core/components/level_obstacle_component.dart';
import 'package:maze_tales_multiplatform/game_core/components/level_trigger_component.dart';
import 'package:maze_tales_multiplatform/models/level_asset_type.dart';
import 'package:maze_tales_multiplatform/models/level_discovery_text.dart';
import 'package:maze_tales_multiplatform/models/level_info.dart';
import 'package:maze_tales_multiplatform/models/level_trigger.dart';
import 'package:maze_tales_multiplatform/services/image_loader.dart';

class MazeTalesLevelComposer {
  static final MazeTalesLevelComposer sharedInstance = MazeTalesLevelComposer._internal();

  LevelInfo? _currentLevel;

  MazeTalesLevelComposer._internal();

  void setLevel(LevelInfo levelInfo) {
    _currentLevel = levelInfo;
  }

  void clearLevel() {
    _currentLevel = null;
  }

  Future<JoystickComponent> playerJoystick() async {
    final knobPaint = Paint();
    knobPaint.color = const Color(0xFFFFB800);

    final backgroundImage = await ImageLoader.loadImageFromAsset('assets/images/game/joystick_background.png');

    return JoystickComponent(
      knob: CircleComponent(radius: 24.0, paint: knobPaint),
      background: SpriteComponent.fromImage(backgroundImage, size: Vector2.all(112.0)),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
    );
  }

  LevelBackground? currentLevelBackground() {
    return _currentLevel?.background != null ? LevelBackground(backgroundAsset: _currentLevel!.background!) : null;
  }

  List<LevelObstacleComponent> currentLevelObstacles() {
    final obstacles = _currentLevel?.obstacles ?? [];

    return obstacles.map((obstacleAsset) => LevelObstacleComponent(obstacleAsset: obstacleAsset)).toList();
  }

  List<LevelTriggerComponent> currentLevelTriggers() {
    List<LevelTriggerComponent> levelTriggerComponents = [];
    final triggers = _currentLevel?.triggers ?? [];

    for (var triggersConfig in triggers) {
      final triggerComponents = triggersConfig.triggers
          .map((trigger) => LevelTriggerComponent(trigger: trigger, triggerType: triggersConfig.type));
      levelTriggerComponents.addAll(triggerComponents);
    }

    return levelTriggerComponents;
  }

  Future<List<LevelAnimationComponent>> currentLevelAnimations() async {
    List<LevelAnimationComponent> levelAnimationComponents = [];

    if (_currentLevel != null) {
      final firebaseStorage = FirebaseStorage.instance;
      const assetsRoot = 'maze_tales_levels';
      for (var animationConfig in _currentLevel!.animations) {
        for (var animation in animationConfig.animations) {
          final assetsPath = '$assetsRoot/${_currentLevel!.name}/animations/${animationConfig.type.name}/${animation.name}';
          final filesList = await firebaseStorage.ref().child(assetsPath).listAll();
          if (filesList.items.isNotEmpty) {
            List<ui.Image> animationImages = [];
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
              position: Vector2(animation.asset.x * 3.0, animation.asset.y * 3.0),
              size: Vector2(animation.asset.width * 3.0, animation.asset.height * 3.0),
            );
            levelAnimationComponents.add(animationComponent);
          }
        }
      }
    }

    return levelAnimationComponents;
  }

  LevelDiscoveryText? discoveryTextForTrigger({required String triggerType, required String triggerName}) {
    final rawDiscoveryText = _currentLevel?.discoveryTexts?[triggerType]?[triggerName] as Map<String, dynamic>?;
    if (rawDiscoveryText != null) {
      var discoveryText = LevelDiscoveryText();
      discoveryText.fromJson(rawDiscoveryText);

      return discoveryText;
    } else {
      return null;
    }
  }
}
