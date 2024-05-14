import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

const String basedApiUrl = 'http://140.123.101.199:5000';

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
    this.mylosting,
  });

  final String postUser;
  final String imageUrl;
  final String lostThingName;
  final String postUserEmail;
  final String content;
  final String location;
  final DateTime date;
  final String headShotUrl;
  final int? mylosting;

  String get formattedDate {
    return formatter.format(date);
  }

  factory LostThing.fromMap(Map<String, dynamic> map) {
    return LostThing(
      lostThingName: map['title'] as String? ?? '',
      content: map['context'] as String? ?? '',
      imageUrl: map['image'] as String? ?? '',
      date: DateTime.parse(map['date']),
      location: map['location'] as String? ?? '',
      postUser: map['author'] as String? ?? '',
      postUserEmail: map['author_email'] as String? ?? '',
      headShotUrl: map['headShotUrl'] as String? ?? '',
      mylosting: map['my_losting'] as int? ?? 0,
    );
  }
}
