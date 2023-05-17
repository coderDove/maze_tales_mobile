import 'package:collection/collection.dart';

enum LevelAssetType { primary, secondary, tertiary, settings, unknown }

class LevelAssetTypeComposer {
  static LevelAssetType initializeFromRawValue(String rawValue) {
    final assetType = LevelAssetType.values.firstWhereOrNull((type) => type.toString() == 'LevelAssetType.$rawValue');

    return assetType ?? LevelAssetType.unknown;
  }
}
