import 'dart:ui';
import 'package:flame/components.dart';

extension Transforms on Vector2 {
  Offset asOffset() => Offset(x, y);
}
