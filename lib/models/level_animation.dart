import 'package:maze_tales_multiplatform/data_mappers/json_mappers.dart';
import 'package:maze_tales_multiplatform/models/level_asset.dart';
import 'package:maze_tales_multiplatform/models/level_asset_type.dart';

class LevelAnimation extends JsonResultMappable {
  late final String name;
  late final LevelAsset asset;

  @override
  JsonResultMappable fromJson(Map<String, dynamic> json) {
    name = json['name'] as String;

    final assetRaw = json['asset'] as Map<String, dynamic>;
    var animationAsset = LevelAsset();
    animationAsset.fromJson(assetRaw);
    asset = animationAsset;

    return this;
  }
}

class LevelAnimationsConfig extends JsonResultMappable {
  late final LevelAssetType type;
  late final List<LevelAnimation> animations;

  @override
  JsonResultMappable fromJson(Map<String, dynamic> json) {
    final rawType = json['type'] as String;
    type = LevelAssetTypeComposer.initializeFromRawValue(rawType);

    final rawAnimations = json['animations'] as List;
    animations = rawAnimations.map((jsonAnimation) {
      var animation = LevelAnimation();
      animation.fromJson(jsonAnimation as Map<String, dynamic>);

      return animation;
    }).toList();

    return this;
  }
}
