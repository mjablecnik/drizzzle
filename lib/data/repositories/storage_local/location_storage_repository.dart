import 'package:drizzzle/data/services/storage_local/location_storage_service.dart';
import 'package:drizzzle/domain/models/location_model.dart';
import 'package:drizzzle/utils/result.dart';

class LocationStorageRepository {
  final LocationStorageService _storageService;

  LocationStorageRepository({required LocationStorageService storageService})
      : _storageService = storageService;

  /// Persists a LocationModel for later retrieval
  Future<Result<void>> persistLocation(LocationModel location) async {
    return await _storageService.saveLocation(location);
  }

  /// Retrieves the last saved LocationModel
  /// Returns null if no location has been saved
  Future<Result<LocationModel?>> retrieveLastLocation() async {
    return await _storageService.getStoredLocation();
  }

  /// Removes the stored location
  Future<Result<void>> removeStoredLocation() async {
    return await _storageService.clearStoredLocation();
  }

  /// Checks if a location is currently stored
  bool hasStoredLocation() {
    return _storageService.hasStoredLocation();
  }
}