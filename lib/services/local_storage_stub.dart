/// Fallback storage used on non-web builds until a mobile persistence package is
/// added. It keeps the same API as the web implementation so the UI can be
/// tested everywhere.
class LocalStorageService {
  static final Map<String, String> _memory = <String, String>{};

  static String? readString(String key) => _memory[key];

  static void writeString(String key, String value) {
    _memory[key] = value;
  }
}
