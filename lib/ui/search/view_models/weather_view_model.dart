import 'package:drizzzle/data/repositories/api_remote/weather_repository.dart';
import 'package:drizzzle/data/repositories/storage_local/location_storage_repository.dart';
import 'package:drizzzle/domain/models/location_model.dart';
import 'package:drizzzle/domain/models/weather.dart';
import 'package:drizzzle/utils/result.dart';
import 'package:flutter/material.dart';

class WeatherViewModel extends ChangeNotifier {
  final WeatherRepository _weatherRepository;
  final LocationStorageRepository _locationStorageRepository;

  WeatherViewModel({
    required WeatherRepository weatherRepository,
    required LocationStorageRepository locationStorageRepository,
  }) : _weatherRepository = weatherRepository,
       _locationStorageRepository = locationStorageRepository;
  
  bool _loading = false;
  bool get loading => _loading;

  Result<Weather>? _weather;
  Result<Weather>? get weather => _weather;

  LocationModel? _currentLocation;
  LocationModel? get currentLocation => _currentLocation;

  Future<void> fetchAndSaveWeather(
      {required LocationModel locationModel}) async {
    _loading = true;
    notifyListeners();

    _weather = await _weatherRepository.fetchAndSaveWeather(locationModel);

    _loading = false;
    notifyListeners();
  }

  /// Fetches and saves weather data while also persisting the location
  Future<void> fetchAndSaveWeatherWithPersistence(
      {required LocationModel locationModel}) async {
    _loading = true;
    notifyListeners();

    // First, save the location
    final locationSaveResult = await _locationStorageRepository.persistLocation(locationModel);
    
    // Always update current location if location was saved successfully
    if (locationSaveResult is Ok<void>) {
      _currentLocation = locationModel;
    }
    
    // Then fetch and save weather data
    _weather = await _weatherRepository.fetchAndSaveWeather(locationModel);

    _loading = false;
    notifyListeners();
  }

  /// Refreshes weather data using the stored location
  Future<void> refreshWeatherFromStoredLocation() async {
    _loading = true;
    notifyListeners();

    try {
      final locationResult = await _locationStorageRepository.retrieveLastLocation();
      
      switch (locationResult) {
        case Ok<LocationModel?>():
          final location = locationResult.value;
          if (location != null) {
            // Always update current location first
            _currentLocation = location;
            
            // Then fetch and save weather data
            _weather = await _weatherRepository.fetchAndSaveWeather(location);
          } else {
            _weather = Result.error(Exception('No stored location found'));
          }
        case Error<LocationModel?>():
          _weather = Result.error(Exception('Failed to retrieve stored location'));
      }
    } catch (e) {
      _weather = Result.error(Exception('Failed to refresh weather: $e'));
    }

    _loading = false;
    notifyListeners();
  }

  /// Loads the stored location without fetching weather
  Future<void> loadStoredLocation() async {
    final locationResult = await _locationStorageRepository.retrieveLastLocation();
    
    switch (locationResult) {
      case Ok<LocationModel?>():
        _currentLocation = locationResult.value;
        // If we have a location but no weather data, try to load it from local storage
        if (_currentLocation != null && _weather == null) {
          _weather = await _weatherRepository.getLocalWeather();
        }
        notifyListeners();
      case Error<LocationModel?>():
        _currentLocation = null;
        notifyListeners();
    }
  }

  /// Checks if a location is currently stored
  bool hasStoredLocation() {
    return _locationStorageRepository.hasStoredLocation();
  }

  Future<void> getLocalWeather() async {
    _loading = true;
    notifyListeners();

    _weather = await _weatherRepository.getLocalWeather();

    _loading = false;
    notifyListeners();
  }
}
