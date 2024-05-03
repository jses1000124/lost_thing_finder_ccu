import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

const uuid = Uuid();

class LostThing {
  LostThing({
    required this.lostThingName,
    required this.content,
    required this.date,
    required this.imageUrl,
    required this.location,
  }) : id = uuid.v4();

  final String id;
  final String imageUrl;
  final String lostThingName;
  final String content;
  final String location;
  final DateTime date;

  String get formattedDate {
    return DateFormat('yyyy/MM/dd').format(date);
  }
}
