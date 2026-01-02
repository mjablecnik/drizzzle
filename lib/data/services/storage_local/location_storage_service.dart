import 'dart:convert';
import 'package:drizzzle/domain/models/location_model.dart';
import 'package:drizzzle/utils/result.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationStorageService {
  static const String _locationKey = 'saved_location';
  final SharedPreferences _prefs;

  LocationStorageService({required SharedPreferences prefs}) : _prefs = prefs;

  /// Saves a LocationModel to SharedPreferences as JSON
  Future<Result<void>> saveLocation(LocationModel location) async {
    try {
      final jsonString = jsonEncode(location.toJson());
      final success = await _prefs.setString(_locationKey, jsonString);
      
      if (success) {
        return const Result.ok(null);
      } else {
        return Result.error(Exception('Failed to save location to SharedPreferences'));
      }
    } catch (e) {
      return Result.error(Exception('Failed to serialize location: $e'));
    }
  }

  /// Retrieves a LocationModel from SharedPreferences
  /// Returns null if no location is stored or if deserialization fails
  Future<Result<LocationModel?>> getStoredLocation() async {
    try {
      final jsonString = _prefs.getString(_locationKey);
      
      if (jsonString == null) {
        return const Result.ok(null);
      }

      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final location = LocationModel.fromJson(jsonMap);
      
      return Result.ok(location);
    } catch (e) {
      // Clear corrupted data and return null
      await clearStoredLocation();
      return const Result.ok(null);
    }
  }

  /// Clears the stored location from SharedPreferences
  Future<Result<void>> clearStoredLocation() async {
    try {
      final success = await _prefs.remove(_locationKey);
      
      if (success) {
        return const Result.ok(null);
      } else {
        return Result.error(Exception('Failed to clear stored location'));
      }
    } catch (e) {
      return Result.error(Exception('Failed to clear stored location: $e'));
    }
  }

  /// Checks if a location is currently stored
  bool hasStoredLocation() {
    return _prefs.containsKey(_locationKey);
  }
}