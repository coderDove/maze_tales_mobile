import 'dart:ui';

import 'package:flame/components.dart';

extension Transforms on Offset {
  Vector2 asVector2() => Vector2(dx, dy);
}
