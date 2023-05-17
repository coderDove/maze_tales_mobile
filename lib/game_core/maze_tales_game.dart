import 'dart:ui';
import 'package:a_star_algorithm/a_star_algorithm.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_isolate/flame_isolate.dart';
import 'package:collection/collection.dart';
import 'package:maze_tales_multiplatform/extensions/offset_extras.dart';
import 'package:maze_tales_multiplatform/firebase/firesbase_storage_provider.dart';
import 'package:maze_tales_multiplatform/firebase/firestore_data_provider.dart';
import 'package:maze_tales_multiplatform/game_core/components/level_animation_component.dart';
import 'package:maze_tales_multiplatform/game_core/components/level_background.dart';
import 'package:maze_tales_multiplatform/game_core/components/level_obstacle_component.dart';
import 'package:maze_tales_multiplatform/game_core/components/level_tile.dart';
import 'package:maze_tales_multiplatform/game_core/components/level_trigger_component.dart';
import 'package:maze_tales_multiplatform/game_core/components/main_character.dart';
import 'package:maze_tales_multiplatform/game_core/maze_tales_level_composer.dart';
import 'package:maze_tales_multiplatform/models/level_asset_type.dart';
import 'package:maze_tales_multiplatform/models/level_discovery_text.dart';
import 'package:maze_tales_multiplatform/screens/common/dialogue_box/dialogue_box.dart';
import 'package:maze_tales_multiplatform/screens/common/transparent_overlay/transparent_overlay.dart';
import 'package:maze_tales_multiplatform/services/image_loader.dart';

class MazeTalesGame extends FlameGame with HasDraggables, HasCollisionDetection, TapDetector, FlameIsolate {
  late final RouterComponent _dialoguesRouter;

  final _mainCharacter = MainCharacter();

  LevelBackground? _levelBackground;

  final List<LevelObstacleComponent> _obstacles = [];
  final List<LevelTriggerComponent> _triggers = [];
  final List<LevelAnimationComponent> _animations = [];
  final List<Offset> _nonWalkablePoints = [];
  LevelDiscoveryText? _discoveryTextToPresent;

  static int _graphWidth = 0;
  static int _graphHeight = 0;

  Vector2 _joystickPosition = Vector2.zero();
  Vector2 _joystickSize = Vector2.zero();

  @override
  Future<void> onLoad() async {
    // await images.loadAllImages();

    _dialoguesRouter = RouterComponent(
      routes: {
        'empty': OverlayRoute((context, game) {
          return const TransparentOverlay();
        }),
        'show_dialogue': OverlayRoute((context, game) {
          return DialogueBox(text: _discoveryTextToPresent?.requiredText ?? '', type: DialogueBoxType.catAndDog);
        }),
      },
      initialRoute: 'empty',
    );

    await add(_dialoguesRouter);

    final firestoreProvider = FirestoreDataProvider();
    final levels = await firestoreProvider.fetchGameLevels();

    MazeTalesLevelComposer.sharedInstance.setLevel(levels.last);
    _levelBackground = MazeTalesLevelComposer.sharedInstance.currentLevelBackground();

    await add(_levelBackground!);

    _obstacles.addAll(MazeTalesLevelComposer.sharedInstance.currentLevelObstacles());
    _triggers.addAll(MazeTalesLevelComposer.sharedInstance.currentLevelTriggers());
    _animations.addAll(await MazeTalesLevelComposer.sharedInstance.currentLevelAnimations());

    await add(_mainCharacter);
    await add(ScreenHitbox());
    await loadMap();

    final joystick = await MazeTalesLevelComposer.sharedInstance.playerJoystick();
    _mainCharacter.assignJoystick(joystick);
    await add(joystick);

    _joystickPosition = joystick.position;
    _joystickSize = joystick.size;

    camera.worldBounds = _levelBackground!.toRect();
    camera.followComponent(_mainCharacter, relativeOffset: Anchor.center);
    camera.zoom = 0.4;

    _mainCharacter.assignMovementFinishedCallback(_characterMovementFinished);

    _startBackgroundAudio();
  }

  Future<void> _requestCharacterMovement(List<Offset> pathPoints) async {
    final movingPoints = pathPoints.map((point) => point.asVector2()).toList();
    _mainCharacter.startMovingByPath(pathPoints: movingPoints);
  }

  @override
  bool onTapDown(TapDownInfo info) {
    if (_dialoguesRouter.currentRoute.name == 'show_dialogue') {
      _hideDialogueOverlay();

      return false;
    }

    if (info.eventPosition.global.x < _joystickPosition.x + _joystickSize.x &&
        info.eventPosition.global.y > _joystickPosition.y - _joystickSize.y / 2.0) {
      return false;
    }

    final tapPoint = Vector2(info.eventPosition.game.x, info.eventPosition.game.y);
    final tappedObstacle = _obstacles.firstWhereOrNull((obstacle) => obstacle.isPointInside(tapPoint));
    if (tappedObstacle != null) {
      return false;
    }
    // isolate(_handleTap, {'x': info.eventPosition.game.x, 'y': info.eventPosition.game.y}).then(_requestCharacterMovement);

    final payload = {
      'x': tapPoint.x,
      'y': tapPoint.y,
      'startX': _mainCharacter.anchorPoint.x / LevelTile.tileSize,
      'startY': _mainCharacter.anchorPoint.y / LevelTile.tileSize,
      'nonWalkable': _nonWalkablePoints
    };

    isolate(_handleTap, payload).then(_requestCharacterMovement);

    return true;
  }

  static List<Offset> _handleTap(Map positionInfo) {
    final startX = positionInfo['startX'] as double;
    final startY = positionInfo['startY'] as double;
    final destinationX = (positionInfo['x'] as double) / LevelTile.tileSize;
    final destinationY = (positionInfo['y'] as double) / LevelTile.tileSize;

    final aStarPathFinder = AStar(
      rows: 154,
      columns: 213,
      start: Offset(startX, startY),
      end: Offset(destinationX, destinationY),
      barriers: positionInfo['nonWalkable'] as List<Offset>,
    );

    final pathTiles = aStarPathFinder.findThePath();
    final transformedOffsets = pathTiles
        .map((offset) => Offset(offset.dx * LevelTile.tileSize + LevelTile.tileSize / 2.0,
            offset.dy * LevelTile.tileSize + LevelTile.tileSize / 2.0))
        .toList();

    return transformedOffsets;
    // _mainCharacter.startMoving(destination: info.eventPosition.game);
    // _mainCharacter.startMovingByPath(path: movementPath);
  }

  Future<void> loadMap() async {
    await addAll(_obstacles);
    await addAll(_triggers);
    await addAll(_animations);

    _prepareTilesGraph();
    // await _preparePathfinder();
  }

  Future<void> _prepareTilesGraph() async {
    final levelWidth = _levelBackground!.size.x;
    final levelHeight = _levelBackground!.size.y;

    _graphWidth = (levelWidth / LevelTile.tileSize).ceil();
    _graphHeight = (levelHeight / LevelTile.tileSize).ceil();

    for (var y = 0; y < _graphHeight; y++) {
      for (var x = 0; x < _graphWidth; x++) {
        final tileMidX = x * LevelTile.tileSize + LevelTile.tileSize / 2.0;
        final tileMidY = y * LevelTile.tileSize + LevelTile.tileSize / 2.0;
        final tileCenter = Vector2(tileMidX, tileMidY);

        final containingObstacle = _obstacles.firstWhereOrNull((obstacle) => obstacle.isPointInside(tileCenter));
        if (containingObstacle != null) {
          containingObstacle.tiles.add(LevelTile(x: x.toDouble(), y: y.toDouble()));

          // _nonWalkablePoints.add(Offset(x.toDouble(), y.toDouble()));
          //
          // final tile = RectangleComponent(position: Vector2(x.toDouble() * LevelTile.tileSize, y.toDouble() * LevelTile.tileSize), size: Vector2.all(LevelTile.tileSize));
          // await add(tile);
        }
      }
    }

    for (var obstacle in _obstacles) {
      for (var edgeTile in obstacle.edgeTiles) {
        // final tileComponent = RectangleComponent(position: Vector2(edgeTile.x * LevelTile.tileSize, edgeTile.y * LevelTile.tileSize), size: Vector2.all(LevelTile.tileSize));
        _nonWalkablePoints.add(Offset(edgeTile.x.toDouble(), edgeTile.y.toDouble()));
        // await add(tileComponent);
      }
    }
  }

  Future<void> _prepareAnimations() async {
    List<Image> snowHouseFrames = [];
    for (var i = 1; i < 141; i++) {
      final frameImage = await ImageLoader.loadImageFromAsset('assets/images/animations/snow_house/$i.png');
      snowHouseFrames.add(frameImage);
    }

    final snowHouseAnimation = LevelAnimationComponent(
      name: '1',
      animationType: LevelAssetType.primary,
      frames: snowHouseFrames,
      position: Vector2(1073.0 * 2.0, 216.0 * 2.0),
      size: Vector2(204.0 * 2.0, 146.0 * 2.0),
    );

    _animations.add(snowHouseAnimation);

    List<Image> benchFrames = [];
    for (var i = 1; i < 121; i++) {
      final frameImage = await ImageLoader.loadImageFromAsset('assets/images/animations/bench/$i.png');
      benchFrames.add(frameImage);
    }

    final benchAnimation = LevelAnimationComponent(
      name: '2',
      animationType: LevelAssetType.primary,
      frames: benchFrames,
      position: Vector2(1028.0 * 2.0, 568.0 * 2.0),
      size: Vector2(226.0 * 2.0, 164.0 * 2.0),
    );

    _animations.add(benchAnimation);

    List<Image> presentsFrames = [];
    for (var i = 1; i < 151; i++) {
      final frameImage = await ImageLoader.loadImageFromAsset('assets/images/animations/presents/$i.png');
      presentsFrames.add(frameImage);
    }

    final presentsAnimation = LevelAnimationComponent(
      name: '3',
      animationType: LevelAssetType.primary,
      frames: presentsFrames,
      position: Vector2(120.0 * 2.0, 445.0 * 2.0),
      size: Vector2(92.0 * 2.0, 156.0 * 2.0),
    );

    _animations.add(presentsAnimation);

    return;

    List<Image> christmasTreeFrames = [];
    for (var i = 5; i < 64; i++) {
      final frameImage = await ImageLoader.loadImageFromAsset('assets/images/animations/christmas_tree/$i.png');
      christmasTreeFrames.add(frameImage);
    }

    final christmasTreeAnimation = LevelAnimationComponent(
      name: 'exit',
      animationType: LevelAssetType.settings,
      frames: christmasTreeFrames,
      position: Vector2(372.0 * 2.0, 487.0 * 2.0),
      size: Vector2(189.0 * 2.0, 350.0 * 2.0),
    );

    _animations.add(christmasTreeAnimation);
  }

  void _characterMovementFinished() {
    final approachedTrigger =
        _triggers.firstWhereOrNull((trigger) => trigger.isPointInside(_mainCharacter.anchorPoint));
    if (approachedTrigger != null) {
      final triggerName = approachedTrigger.trigger.name;
      final triggerType = approachedTrigger.triggerType;
      final triggerAnimation = _animations
          .firstWhereOrNull((animation) => animation.name == triggerName && animation.animationType == triggerType);
      triggerAnimation?.playAnimation();

      print(approachedTrigger.triggerType);
      print(approachedTrigger.trigger.name);

      _discoveryTextToPresent = MazeTalesLevelComposer.sharedInstance.discoveryTextForTrigger(
        triggerType: triggerType.name,
        triggerName: triggerName,
      );
      if (_discoveryTextToPresent != null) {
        _showDialogueOverlay();
      }
    }
  }

  void _startBackgroundAudio() {
    FlameAudio.bgm.play('park.mp3');
  }

  Future<void> _showDialogueOverlay() async {
    _dialoguesRouter.pushNamed('show_dialogue');
  }

  void _hideDialogueOverlay() {
    _discoveryTextToPresent = null;
    _dialoguesRouter.popUntilNamed('empty');
  }
}

class ChristmasTree extends SpriteAnimationComponent with HasGameRef<MazeTalesGame> {
  @override
  Future<void> onLoad() async {
    List<Sprite> animationSprites = [];
    for (var i = 5; i < 64; i++) {
      final frameImage = game.images.fromCache('animations/christmas_tree/$i.png');
      final frameSprite = Sprite(frameImage);
      animationSprites.add(frameSprite);
    }

    animation = SpriteAnimation.spriteList(animationSprites, stepTime: 0.05);
    size = Vector2(189.0, 350.0);
    position = Vector2(372.0, 487.0);
  }
}

class Bench extends SpriteAnimationComponent with HasGameRef<MazeTalesGame> {
  @override
  Future<void> onLoad() async {
    List<Sprite> animationSprites = [];
    for (var i = 0; i < 121; i++) {
      final frameImage = game.images.fromCache('animations/bench/$i.png');
      final frameSprite = Sprite(frameImage);
      animationSprites.add(frameSprite);
    }

    animation = SpriteAnimation.spriteList(animationSprites, stepTime: 0.05);
    size = Vector2(226.0, 164.0);
    position = Vector2(1028.0, 568.0);
  }
}

class SnowHouse extends SpriteAnimationComponent with HasGameRef<MazeTalesGame> {
  @override
  Future<void> onLoad() async {
    List<Sprite> animationSprites = [];
    for (var i = 1; i < 141; i++) {
      final frameImage = game.images.fromCache('animations/snow_house/$i.png');
      final frameSprite = Sprite(frameImage);
      animationSprites.add(frameSprite);
    }

    animation = SpriteAnimation.spriteList(animationSprites, stepTime: 0.05);
    size = Vector2(204.0 * 3.0, 146.0 * 3.0);
    position = Vector2(1073.0 * 3.0, 216.0 * 3.0);
  }
}

class Presents extends SpriteAnimationComponent with HasGameRef<MazeTalesGame> {
  @override
  Future<void> onLoad() async {
    List<Sprite> animationSprites = [];
    for (var i = 01; i < 151; i++) {
      final frameImage = game.images.fromCache('animations/presents/$i.png');
      final frameSprite = Sprite(frameImage);
      animationSprites.add(frameSprite);
    }

    animation = SpriteAnimation.spriteList(animationSprites, stepTime: 0.05);
    size = Vector2(92.0, 156.0);
    position = Vector2(120.0, 445.0);
  }
}
