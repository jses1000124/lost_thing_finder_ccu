import 'package:intl/intl.dart';

const String basedApiUrl = 'https://www.ccufinder.ninja:5000';

final formatter = DateFormat('yyyy/MM/dd');

class LostThing {
  LostThing({
    required this.lostThingName,
    required this.content,
    required this.date,
    required this.postUser,
    required this.postUserEmail,
    required this.imageUrl,
    required this.location,
    this.headShotIndex,
    this.mylosting,
    this.id,
    this.latitude,
    this.longitude,
  });

  final String postUser;
  final String imageUrl;
  final String lostThingName;
  final String postUserEmail;
  final String content;
  final String location;
  final DateTime date;
  final int? headShotIndex;
  final int? mylosting;
  final Object? id;
  final double? latitude;
  final double? longitude;

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
      postUser: map['author_nickname'] as String? ?? '',
      postUserEmail: map['author_email'] as String? ?? '',
      headShotIndex: map['userimg'] as int? ?? 0,
      mylosting: map['my_losting'] as int? ?? 0,
      id: map['id'] as Object? ?? 0,
      latitude: map['latitude'] as double? ?? 0,
      longitude: map['longitude'] as double? ?? 0,
    );
  }
  LostThing copyWith({
    String? lostThingName,
    String? content,
    DateTime? date,
    String? postUser,
    String? postUserEmail,
    String? imageUrl,
    String? location,
    int? headShotIndex,
    int? mylosting,
    Object? id,
    double? latitude,
    double? longitude,
  }) {
    return LostThing(
      lostThingName: lostThingName ?? this.lostThingName,
      content: content ?? this.content,
      date: date ?? this.date,
      postUser: postUser ?? this.postUser,
      postUserEmail: postUserEmail ?? this.postUserEmail,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      headShotIndex: headShotIndex ?? this.headShotIndex,
      mylosting: mylosting ?? this.mylosting,
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': lostThingName,
      'context': content,
      'location': location,
      'date': date.toIso8601String(),
      'image': imageUrl,
      'author_email': postUserEmail,
      'my_losting': mylosting,
      'author_nickname': postUser,
      'userimg': headShotIndex,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
