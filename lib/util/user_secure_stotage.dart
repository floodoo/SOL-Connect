import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserSecureStorage {
  static const _storage = FlutterSecureStorage();
  static const _keyUsername = "username";
  static const _keyPassword = "password";
  static const _keyPhaseLoadBlockStart = "phaseLoadTimestampStart";
  static const _keyPhaseLoadBlockEnd = "phaseLoadTimestampEnd";

  static Future setUsername(String username) async => await _storage.write(key: _keyUsername, value: username);
  static Future setPassword(String password) async => await _storage.write(key: _keyPassword, value: password);
  static Future setPhaseLoadDateStart(DateTime loadTime) async => await _storage.write(key: _keyPhaseLoadBlockStart, value: loadTime.millisecondsSinceEpoch.toString());
  static Future setPhaseLoadDateEnd(DateTime endTime) async => await _storage.write(key: _keyPhaseLoadBlockEnd, value: endTime.millisecondsSinceEpoch.toString());

  static Future<String?> getUsername() async => await _storage.read(key: _keyUsername);
  static Future<String?> getPassword() async => await _storage.read(key: _keyPassword);
  
  static Future<DateTime?> getPhaseLoadBlockStart() async {
    String? millisec = await _storage.read(key: _keyPhaseLoadBlockStart);
    if(millisec != null) {
     return DateTime.fromMillisecondsSinceEpoch(int.parse(millisec));
    }
  }

  static Future<DateTime?> getPhaseLoadBlockEnd() async {
    String? millisec = await _storage.read(key: _keyPhaseLoadBlockEnd);
    if(millisec != null) {
     return DateTime.fromMillisecondsSinceEpoch(int.parse(millisec));
    }
  }

  static Future clearPhaseDates() async {
    _storage.delete(key: _keyPhaseLoadBlockStart);
    _storage.delete(key: _keyPhaseLoadBlockEnd);
  }

  static Future clear() async => await _storage.deleteAll();
}
