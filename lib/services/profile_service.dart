import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/diet_profile.dart';

class ProfileService {
  static const String _key = 'diet_profile';

  Future<void> saveProfile(DietProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(profile.toJson()));
  }

  Future<DietProfile?> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return null;
    return DietProfile.fromJson(jsonDecode(data) as Map<String, dynamic>);
  }

  Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
