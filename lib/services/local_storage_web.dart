// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Browser localStorage works when hosted from GitHub Pages. It is per browser
/// and per domain, so it is good enough for alpha feedback on saved cars/settings.
class LocalStorageService {
  static String? readString(String key) => html.window.localStorage[key];

  static void writeString(String key, String value) {
    html.window.localStorage[key] = value;
  }
}
