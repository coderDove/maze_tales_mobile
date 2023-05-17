import 'package:maze_tales_multiplatform/data_mappers/json_mappers.dart';

class LevelDiscoveryText extends JsonResultMappable {
  late final String requiredText;
  late final String? optionalText;
  late final String textPosition;

  @override
  JsonResultMappable fromJson(Map<String, dynamic> json) {
    requiredText = json['required_text'] as String;
    optionalText = json['optional_text'] as String;
    textPosition = json['text_position'] as String;

    return this;
  }
}
