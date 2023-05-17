import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/layers.dart';
import 'package:maze_tales_multiplatform/game_core/components/level_tile.dart';
import 'package:svg_path_parser/svg_path_parser.dart';
import 'package:maze_tales_multiplatform/models/level_asset.dart';

abstract class LevelShapeComponent extends PositionComponent {
  final LevelAsset shapeAsset;
  final int _positionScale = 3;
  late final Path _shapePath;

  String get scaledVectorPath {
    switch (_positionScale) {
      case 1:
        return shapeAsset.vectorPaths.x1;
      case 2:
        return shapeAsset.vectorPaths.x2;
      case 3:
        return shapeAsset.vectorPaths.x3;
      default:
        return shapeAsset.vectorPaths.x1;
    }
  }

  LevelShapeComponent({required this.shapeAsset});

  @override
  Future<void> onLoad() async {
    _shapePath = parseSvgPath(scaledVectorPath);
    position = Vector2(shapeAsset.x * _positionScale, shapeAsset.y * _positionScale);
    size = Vector2(_shapePath.getBounds().width, _shapePath.getBounds().height);
  }

  bool isPointInside(Vector2 point) {
    // return false;

    int innerPointsCount = 0;
    if (_shapePath.contains(Offset(point.x - shapeAsset.x * _positionScale, point.y - shapeAsset.y * _positionScale))) {
      innerPointsCount += 1;
    }
    if (_shapePath.contains(Offset(point.x - LevelTile.tileSize / 2.0 - shapeAsset.x * _positionScale,
        point.y - LevelTile.tileSize / 2.0 - shapeAsset.y * _positionScale))) {
      innerPointsCount += 1;
    }
    if (_shapePath.contains(Offset(point.x - LevelTile.tileSize / 2.0 - shapeAsset.x * _positionScale,
        point.y + LevelTile.tileSize / 2.0 - shapeAsset.y * _positionScale))) {
      innerPointsCount += 1;
    }
    if (_shapePath.contains(Offset(point.x + LevelTile.tileSize / 2.0 - shapeAsset.x * _positionScale,
        point.y - LevelTile.tileSize / 2.0 - shapeAsset.y * _positionScale))) {
      innerPointsCount += 1;
    }
    if (_shapePath.contains(Offset(point.x + LevelTile.tileSize / 2.0 - shapeAsset.x * _positionScale,
        point.y + LevelTile.tileSize / 2.0 - shapeAsset.y * _positionScale))) {
      innerPointsCount += 1;
    }

    return innerPointsCount > 3;
  }

  // bool isPointInside(Vector2 point) {
  //   // return false;
  //
  //   int innerPointsCount = 0;
  //   if (_shapePath.contains(Offset(point.x, point.y))) {
  //     innerPointsCount += 1;
  //   }
  //   if (_shapePath.contains(Offset(point.x - LevelTile.tileSize / 2.0, point.y - LevelTile.tileSize / 2.0))) {
  //     innerPointsCount += 1;
  //   }
  //   if (_shapePath.contains(Offset(point.x - LevelTile.tileSize / 2.0, point.y + LevelTile.tileSize / 2.0))) {
  //     innerPointsCount += 1;
  //   }
  //   if (_shapePath.contains(Offset(point.x + LevelTile.tileSize / 2.0, point.y - LevelTile.tileSize / 2.0))) {
  //     innerPointsCount += 1;
  //   }
  //   if (_shapePath.contains(Offset(point.x + LevelTile.tileSize / 2.0, point.y + LevelTile.tileSize / 2.0))) {
  //     innerPointsCount += 1;
  //   }
  //
  //   return innerPointsCount > 3;
  // }
}
