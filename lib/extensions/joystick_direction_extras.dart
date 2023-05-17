import 'package:flame/components.dart';

extension Transform on JoystickDirection {
  List<JoystickDirection> get oppositeDirections {
    switch (this) {
      case JoystickDirection.up:
        return [JoystickDirection.downLeft, JoystickDirection.down, JoystickDirection.downRight];
      case JoystickDirection.upLeft:
        return [JoystickDirection.down, JoystickDirection.downRight, JoystickDirection.right];
      case JoystickDirection.upRight:
        return [JoystickDirection.down, JoystickDirection.downLeft, JoystickDirection.left];
      case JoystickDirection.right:
        return [JoystickDirection.downLeft, JoystickDirection.left, JoystickDirection.upLeft];
      case JoystickDirection.down:
        return [JoystickDirection.upRight, JoystickDirection.up, JoystickDirection.upLeft];
      case JoystickDirection.downRight:
        return [JoystickDirection.up, JoystickDirection.upLeft, JoystickDirection.left];
      case JoystickDirection.downLeft:
        return [JoystickDirection.up, JoystickDirection.upRight, JoystickDirection.right];
      case JoystickDirection.left:
        return [JoystickDirection.upRight, JoystickDirection.right, JoystickDirection.upRight];
      case JoystickDirection.idle:
        return [JoystickDirection.idle];
    }
  }

  JoystickDirection get oppositeDirection {
    switch (this) {
      case JoystickDirection.up:
        return JoystickDirection.down;
      case JoystickDirection.upLeft:
        return JoystickDirection.downRight;
      case JoystickDirection.upRight:
        return JoystickDirection.downLeft;
      case JoystickDirection.right:
        return JoystickDirection.left;
      case JoystickDirection.down:
        return JoystickDirection.up;
      case JoystickDirection.downRight:
        return JoystickDirection.upLeft;
      case JoystickDirection.downLeft:
        return JoystickDirection.upRight;
      case JoystickDirection.left:
        return JoystickDirection.right;
      case JoystickDirection.idle:
        return JoystickDirection.idle;
    }
  }
}
