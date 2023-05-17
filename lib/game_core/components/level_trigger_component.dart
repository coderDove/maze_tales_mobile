import 'package:maze_tales_multiplatform/game_core/components/level_shape_component.dart';
import 'package:maze_tales_multiplatform/models/level_asset_type.dart';
import 'package:maze_tales_multiplatform/models/level_trigger.dart';

class LevelTriggerComponent extends LevelShapeComponent {
  final LevelTrigger trigger;
  final LevelAssetType triggerType;

  LevelTriggerComponent({required this.trigger, required this.triggerType}) : super(shapeAsset: trigger.asset);
}
