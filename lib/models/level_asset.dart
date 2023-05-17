import 'package:maze_tales_multiplatform/data_mappers/json_mappers.dart';

class LevelAsset extends JsonResultMappable {
  late final String id;
  late final String name;
  late final String? assetUrl;
  late final double x;
  late final double y;
  late final double width;
  late final double height;
  late final LevelAssetPathsBundle vectorPaths;

  @override
  JsonResultMappable fromJson(Map<String, dynamic> json) {
    id = json['id'] as String;
    name = json['name'] as String;
    assetUrl = json['assetUrl'] as String?;
    x = json['x'].toDouble();
    y = json['y'].toDouble();
    width = json['width'].toDouble();
    height = json['height'].toDouble();

    final vectorPathsRaw = json['vectorPaths'] as Map<String, dynamic>;
    var assetVectorPaths = LevelAssetPathsBundle();
    assetVectorPaths.fromJson(vectorPathsRaw);
    vectorPaths = assetVectorPaths;

    return this;
  }
}

class LevelAssetPathsBundle extends JsonResultMappable {
  late final String x1;
  late final String x2;
  late final String x3;

  @override
  JsonResultMappable fromJson(Map<String, dynamic> json) {
    x1 = json['x1'] as String;
    x2 = json['x2'] as String;
    x3 = json['x3'] as String;

    return this;
  }
}
