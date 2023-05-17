import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maze_tales_multiplatform/models/level_info.dart';

class FirestoreDataProvider {
  final _firestore = FirebaseFirestore.instance;

  Future<List<LevelInfo>> fetchGameLevels() async {
    final querySnapshot = await _firestore.collection('game_levels').get();
    final levels = querySnapshot.docs.map((levelDoc) {
      var levelInfo = LevelInfo();
      levelInfo.fromJson(levelDoc.data());

      return levelInfo;
    }).toList();

    return levels;
  }
}
