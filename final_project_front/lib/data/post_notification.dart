import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> sendNotification(
    String targetEmail, String targetNickname, String text) async {
  var url = Uri.parse('https://onesignal.com/api/v1/notifications');
  var response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Basic ZTVhN2M0OWYtZDZjMy00NDY1LWEyNGMtMzBhNmNlN2JiOGZh',
    },
    body: jsonEncode({
      'app_id': '22ccb45f-f773-4a26-a4ea-aab2d267207a',
      "include_aliases": {
        "external_id": [targetEmail]
      },
      "headings": {"en": targetNickname},
      'contents': {'en': text},
      "target_channel": "push",
    }),
  );

  if (response.statusCode == 200) {
    // debugPrint('Notification sent successfully');
  } else {
    // debugPrint('Failed to send notification');
  }
}
