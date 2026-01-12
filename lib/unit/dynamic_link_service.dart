import 'dart:convert';
import 'package:http/http.dart' as http;

class DynamicLinkApi {
  static const String apiKey = "AIzaSyBooBYQv5XaszDGX3XW62XWaOJTP3danxI";

  static Future<String> createVideoLink(String videoId) async {
    final Uri url = Uri.parse(
      "https://firebasedynamiclinks.googleapis.com/v1/shortLinks?key=$apiKey",
    );

    final Map body = {
      "dynamicLinkInfo": {
        "domainUriPrefix": "https://filedock.in",
        "link": "https://filedock.in/video?id=$videoId",

        "androidInfo": {
          "androidPackageName": "com.filedock.user",
        },
        "iosInfo": {
          "iosBundleId": "com.filedock.user",
        }
      },
      "suffix": {"option": "SHORT"}
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);

    return data["shortLink"] ?? "";
  }
}
