import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:maze_tales_multiplatform/extensions/joystick_direction_extras.dart';
import 'package:maze_tales_multiplatform/extensions/vector2_extras.dart';
import 'package:maze_tales_multiplatform/game_core/maze_tales_game.dart';

class MainCharacter extends SpriteAnimationComponent with HasGameRef<MazeTalesGame>, CollisionCallbacks {
  JoystickComponent? _playerJoystick;
  SpriteAnimation? _idleAnimation;
  SpriteAnimation? _movementAnimation;
  MoveAlongPathEffect? _currentMovingEffect;
  Function? _movementFinished;
  bool _movementInProgress = false;
  bool _collisionDetected = false;
  bool _pathMovementActive = false;
  JoystickDirection _collisionDirection = JoystickDirection.idle;

  late final Vector2 _lastSize = size.clone();
  late final Transform2D _lastTransform = transform.clone();

  Vector2 get anchorPoint => Vector2(position.x, (position.y - size.y / 2.0) + size.y * 0.8);
  Vector2 get localAnchorPoint => Vector2(size.x / 2.0, size.y * 0.8);

  @override
  Future<void> onLoad() async {
    await _loadAnimations();
    _setInitialConfig();
    await _addHitbox();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_pathMovementActive && _playerJoystick != null) {
      if (!_playerJoystick!.delta.isZero()) {
        _movementInProgress = true;
        if (activeCollisions.isEmpty) {
          animation = _movementAnimation;
          _lastSize.setFrom(size);
          _lastTransform.setFrom(transform);

          final destinationAnchorPoint = anchorPoint;
          destinationAnchorPoint.add(_playerJoystick!.relativeDelta * 150.0 * dt);
          position = _calculatePositionFromCharacterAnchor(destinationAnchorPoint);
        } else {
          if (_collisionDirection.oppositeDirections.contains(_playerJoystick?.direction)) {
            animation = _movementAnimation;
            _lastSize.setFrom(size);
            _lastTransform.setFrom(transform);

            final destinationAnchorPoint = anchorPoint;
            destinationAnchorPoint.add(_playerJoystick!.relativeDelta * 150.0 * dt);
            position = _calculatePositionFromCharacterAnchor(destinationAnchorPoint);
          }
        }
      } else {
        animation = _idleAnimation;
        if (_collisionDetected) {
          transform.setFrom(_lastTransform);
          size.setFrom(_lastSize);
          _collisionDetected = false;
        }
        if (_movementInProgress) {
          if (_movementFinished != null) {
            _movementFinished!();
          }
        }
        _movementInProgress = false;
      }
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (!_pathMovementActive) {
      _collisionDetected = true;
      _collisionDirection = _playerJoystick?.direction ?? JoystickDirection.idle;
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
  }

  void assignJoystick(JoystickComponent playerJoystick) {
    _playerJoystick = playerJoystick;
  }

  void assignMovementFinishedCallback(Function movementFinishedCallback) {
    _movementFinished = movementFinishedCallback;
  }

  void startMovingByPath({required List<Vector2> pathPoints}) {
    stopMoving(becomingIdle: false);
    _pathMovementActive = true;
    final actualPositionPoints = pathPoints.map((point) => _calculatePositionFromCharacterAnchor(point));
    final movementPathOffsets = actualPositionPoints.map((point) => point.asOffset()).toList();
    movementPathOffsets.insert(0, position.toOffset());
    final movementPath = Path();
    movementPath.addPolygon(movementPathOffsets, false);
    final movingEffect = MoveAlongPathEffect(
      movementPath,
      EffectController(speed: 200.0),
      absolute: true,
      onComplete: () {
        stopMoving(becomingIdle: true);
        if (_movementFinished != null) {
          _movementFinished!();
        }
      },
    );
    add(movingEffect);
    _currentMovingEffect = movingEffect;
    animation = _movementAnimation;
  }

  Future<void> startMoving({required Vector2 destination}) async {
    stopMoving(becomingIdle: false);
    // final movingEffect = MoveToEffect(
    //   Vector2(destination.x - size.x / 2.0, destination.y - size.y * 0.9),
    //   EffectController(speed: 140.0),
    //   onComplete: () => stopMoving(becomingIdle: true),
    // );

    final destinationPosition = _calculatePositionFromCharacterAnchor(destination);
    final movementVector = Vector2(destinationPosition.x - position.x, destinationPosition.y - position.y);
    final movingEffect = MoveByEffect(
      movementVector,
      EffectController(speed: 140.0),
      onComplete: () => stopMoving(becomingIdle: true),
    );
    await add(movingEffect);
    // _currentMovingEffect = movingEffect;
    animation = _movementAnimation;
  }

  void stopMoving({required bool becomingIdle}) {
    if (_currentMovingEffect != null) {
      remove(_currentMovingEffect!);
      _currentMovingEffect = null;
    }
    if (becomingIdle) {
      animation = _idleAnimation;
      _pathMovementActive = false;
    }
  }

  // Private instance
  void _setInitialConfig() {
    size = Vector2.all(240.0);
    // center = Vector2(game.size.x / 2.0, game.size.y / 2.0);
    position = _calculatePositionFromCharacterAnchor(Vector2(1860.0, 1740.0));
    animation = _idleAnimation;
    anchor = Anchor.center;
    priority = 999;
  }

  Future<void> _addHitbox() async {
    final hitbox = CircleHitbox(radius: 5.0);
    hitbox.center = localAnchorPoint;
    // hitbox.renderShape = true;
    // final hitbox = RectangleHitbox(size: Vector2.all(20.0));
    // hitbox.center = localAnchorPoint;
    // hitbox.renderShape = true;
    await add(hitbox);
  }

  Future<void> _loadAnimations() async {
    _idleAnimation = await _composeAnimation(framesPath: 'animations/main_character_idle', framesCount: 119);
    _movementAnimation = await _composeAnimation(
      framesPath: 'animations/main_character_movement',
      framesCount: 80,
      stepTime: 0.04,
    );
  }

  Future<SpriteAnimation> _composeAnimation(
      {required String framesPath, required int framesCount, double stepTime = 0.05}) async {
    List<Sprite> animationSprites = [];
    for (var i = 0; i < framesCount; i++) {
      final frameImage = await game.images.load('$framesPath/$i.png');
      final frameSprite = Sprite(frameImage);
      animationSprites.add(frameSprite);
    }

    return SpriteAnimation.spriteList(animationSprites, stepTime: stepTime);
  }

  Vector2 _calculatePositionFromCharacterAnchor(Vector2 anchorPoint) {
    return Vector2(anchorPoint.x, anchorPoint.y - size.y * 0.8 + size.y / 2.0);
  }
}
