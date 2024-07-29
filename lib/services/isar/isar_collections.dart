import 'package:isar/isar.dart';

part 'isar_collections.g.dart';

@collection
class User {
  Id? id = Isar.autoIncrement;
  String? userId;
  String? token;
  String? name;
  String? image;
  String? email;
  String? brearerToken;
}

@collection
class GratitudeEntry {
  Id id = Isar.autoIncrement;
  String? text;
  String? date;

  @override
  String toString() {
    return '{id: $id, text: $text, date: $date}';
  }

  GratitudeEntry fromJson(Map<String, dynamic> json) {
    return GratitudeEntry()
      ..id = json['id']
      ..text = json['text']
      ..date = json['date'];
  }
}
