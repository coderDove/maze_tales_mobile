import 'package:maze_tales_multiplatform/data_mappers/json_mappers.dart';
import 'package:maze_tales_multiplatform/models/level_asset.dart';
import 'package:maze_tales_multiplatform/models/level_asset_type.dart';

class LevelTrigger extends JsonResultMappable {
  late final String name;
  late final LevelTriggerAnchor? anchor;
  late final LevelAsset asset;

  @override
  JsonResultMappable fromJson(Map<String, dynamic> json) {
    name = json['name'] as String;

    final anchorRaw = json['anchor'] as Map<String, dynamic>?;
    if (anchorRaw != null) {
      var triggerAnchor = LevelTriggerAnchor();
      triggerAnchor.fromJson(anchorRaw);
      anchor = triggerAnchor;
    } else {
      anchor = null;
    }

    final assetRaw = json['asset'] as Map<String, dynamic>;
    var triggerAsset = LevelAsset();
    triggerAsset.fromJson(assetRaw);
    asset = triggerAsset;

    return this;
  }
}

class LevelTriggerAnchor extends JsonResultMappable {
  late final double x;
  late final double y;
  late final double width;
  late final double height;

  @override
  JsonResultMappable fromJson(Map<String, dynamic> json) {
    x = json['x'].toDouble();
    y = json['y'].toDouble();
    width = json['width'].toDouble();
    height = json['height'].toDouble();

    return this;
  }
}

class LevelTriggersConfig extends JsonResultMappable {
  late final LevelAssetType type;
  late final List<LevelTrigger> triggers;

  @override
  JsonResultMappable fromJson(Map<String, dynamic> json) {
    final rawType = json['type'] as String;
    type = LevelAssetTypeComposer.initializeFromRawValue(rawType);

    final rawTriggers = json['triggers'] as List;
    triggers = rawTriggers.map((jsonTrigger) {
      var trigger = LevelTrigger();
      trigger.fromJson(jsonTrigger as Map<String, dynamic>);

      return trigger;
    }).toList();

    return this;
  }
}
