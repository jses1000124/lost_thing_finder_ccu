import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

final formatter = DateFormat('yyyy/MM/dd');

const uuid = Uuid();

class LostThing {
  LostThing({
    required this.lostThingName,
    required this.content,
    required this.date,
    required this.postUser,
    required this.postUserEmail,
    required this.imageUrl,
    required this.location,
    required this.headShotUrl,
  }) : id = uuid.v4();

  final String id;
  final String postUser;
  final String imageUrl;
  final String lostThingName;
  final String postUserEmail;
  final String content;
  final String location;
  final DateTime date;
  final String headShotUrl;

  String get formattedDate {
    return formatter.format(date);
  }
}
