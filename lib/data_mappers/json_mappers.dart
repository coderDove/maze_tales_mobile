abstract class JsonMappable {
  Map<String, dynamic> toJson();
}

abstract class JsonResultMappable {
  JsonResultMappable fromJson(Map<String, dynamic> json);
}
