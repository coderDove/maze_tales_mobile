import 'package:maze_tales_multiplatform/data_mappers/json_mappers.dart';
import 'package:maze_tales_multiplatform/models/level_animation.dart';
import 'package:maze_tales_multiplatform/models/level_asset.dart';
import 'package:maze_tales_multiplatform/models/level_trigger.dart';

class LevelInfo extends JsonResultMappable {
  late final String name;
  late final List<LevelAsset> obstacles;
  late final List<LevelTriggersConfig> triggers;
  late final List<LevelAnimationsConfig> animations;
  late final LevelAsset? background;
  late final Map<String, dynamic>? discoveryTexts;

  @override
  JsonResultMappable fromJson(Map<String, dynamic> json) {
    name = json['name'] as String;

    final rawObstacles = json['obstacles'] as List;
    obstacles = rawObstacles.map((jsonObstacle) {
      var obstacleAsset = LevelAsset();
      obstacleAsset.fromJson(jsonObstacle as Map<String, dynamic>);

      return obstacleAsset;
    }).toList();

    final rawTriggers = json['triggers'] as List;
    triggers = rawTriggers.map((jsonTrigger) {
      var triggersConfig = LevelTriggersConfig();
      triggersConfig.fromJson(jsonTrigger as Map<String, dynamic>);

      return triggersConfig;
    }).toList();

    final rawAnimations = json['animations'] as List;
    animations = rawAnimations.map((jsonAnimation) {
      var animationsConfig = LevelAnimationsConfig();
      animationsConfig.fromJson(jsonAnimation as Map<String, dynamic>);

      return animationsConfig;
    }).toList();

    final backgroundRaw = json['background'] as Map<String, dynamic>;
    var backgroundAsset = LevelAsset();
    backgroundAsset.fromJson(backgroundRaw);
    background = backgroundAsset;

    discoveryTexts = json['discovery_texts'] as Map<String, dynamic>?;

    return this;
  }
}
