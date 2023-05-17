import 'package:collection/collection.dart';
import 'package:flame/collisions.dart';
import 'package:maze_tales_multiplatform/extensions/offset_extras.dart';
import 'package:maze_tales_multiplatform/game_core/components/level_shape_component.dart';
import 'package:maze_tales_multiplatform/game_core/components/level_tile.dart';
import 'package:maze_tales_multiplatform/models/level_asset.dart';
import 'package:maze_tales_multiplatform/services/svg_path_converter.dart';

class LevelObstacleComponent extends LevelShapeComponent {
  List<LevelTile> tiles = [];

  LevelObstacleComponent({required LevelAsset obstacleAsset}) : super(shapeAsset: obstacleAsset);

  List<LevelTile> get edgeTiles {
    List<LevelTile> obstacleEdgeTiles = [];

    for (var tile in tiles) {
      final rightTile = tiles.firstWhereOrNull((obstacleTile) => obstacleTile.x == tile.x - 1 && obstacleTile.y == tile.y);
      final topTile = tiles.firstWhereOrNull((obstacleTile) => obstacleTile.x == tile.x && obstacleTile.y == tile.y + 1);
      final leftTile = tiles.firstWhereOrNull((obstacleTile) => obstacleTile.x == tile.x + 1 && obstacleTile.y == tile.y);
      final bottomTile = tiles.firstWhereOrNull((obstacleTile) => obstacleTile.x == tile.x && obstacleTile.y == tile.y - 1);

      if (rightTile == null || topTile == null || leftTile == null || bottomTile == null) {
        tile.isEdgeTile = true;
        obstacleEdgeTiles.add(tile);
      }
    }

    return obstacleEdgeTiles;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    await _addHitbox();
  }

  // Private instance
  Future<void> _addHitbox() async {
    final svgPathConverter = SvgPathConverter();
    final shapePathOffsets = svgPathConverter.convert(svgPath: scaledVectorPath);
    final hitboxVertices = shapePathOffsets.map((offset) => offset.asVector2()).toList();

    final obstacleHitbox = PolygonHitbox(hitboxVertices);
    // obstacleHitbox.renderShape = true;
    await add(obstacleHitbox);
  }
}
