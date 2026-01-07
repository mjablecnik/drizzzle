import 'package:drizzzle/data/repositories/api_remote/weather_repository.dart';
import 'package:drizzzle/data/repositories/storage_local/location_storage_repository.dart';
import 'package:drizzzle/domain/models/location_model.dart';
import 'package:drizzzle/domain/models/weather.dart';
import 'package:drizzzle/utils/result.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AutoRefreshConfig {
  final Duration refreshTimeout;
  final Duration refreshCooldown;
  final bool enableAutoRefresh;
  final bool showLoadingIndicator;
  
  const AutoRefreshConfig({
    this.refreshTimeout = const Duration(seconds: 5),
    this.refreshCooldown = const Duration(minutes: 5),
    this.enableAutoRefresh = true,
    this.showLoadingIndicator = true,
  });
}

class StartupMetrics {
  final DateTime startTime;
  final DateTime? dataLoadedTime;
  final Duration? totalLoadTime;
  final bool wasDataFresh;
  final bool hadStoredLocation;
  final String? errorMessage;
  
  StartupMetrics({
    required this.startTime,
    this.dataLoadedTime,
    this.totalLoadTime,
    this.wasDataFresh = false,
    this.hadStoredLocation = false,
    this.errorMessage,
  });
}

class AutoRefreshService {
  final WeatherRepository _weatherRepository;
  final LocationStorageRepository _locationStorageRepository;
  final SharedPreferences _prefs;
  final AutoRefreshConfig _config;
  
  static const String _lastRefreshKey = 'last_auto_refresh';
  
  AutoRefreshService({
    required WeatherRepository weatherRepository,
    required LocationStorageRepository locationStorageRepository,
    required SharedPreferences prefs,
    AutoRefreshConfig? config,
  }) : _weatherRepository = weatherRepository,
       _locationStorageRepository = locationStorageRepository,
       _prefs = prefs,
       _config = config ?? const AutoRefreshConfig();

  Future<Result<Weather>> performAutoRefresh() async {
    if (!_config.enableAutoRefresh) {
      return Result.error(Exception('Auto refresh is disabled'));
    }

    try {
      // Get stored location
      final locationResult = await _locationStorageRepository.retrieveLastLocation();
      
      switch (locationResult) {
        case Ok<LocationModel?>():
          final location = locationResult.value;
          if (location == null) {
            return Result.error(Exception('No stored location found'));
          }
          
          // Fetch fresh weather data with timeout
          final weatherResult = await _weatherRepository
              .fetchAndSaveWeather(location)
              .timeout(_config.refreshTimeout);
          
          if (weatherResult is Ok) {
            await recordRefreshTime();
          }
          
          return weatherResult;
        case Error<LocationModel?>():
          return Result.error(Exception('Failed to retrieve stored location'));
      }
    } catch (e) {
      return Result.error(Exception('Auto refresh failed: $e'));
    }
  }

  Future<bool> shouldSkipRefresh() async {
    if (!_config.enableAutoRefresh) {
      return true;
    }
    
    final timeSinceLastRefresh = await getTimeSinceLastRefresh();
    if (timeSinceLastRefresh != null && timeSinceLastRefresh < _config.refreshCooldown) {
      return true;
    }
    
    return false;
  }

  Future<void> recordRefreshTime() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _prefs.setInt(_lastRefreshKey, now);
  }

  Future<Duration?> getTimeSinceLastRefresh() async {
    final lastRefreshMs = _prefs.getInt(_lastRefreshKey);
    if (lastRefreshMs == null) {
      return null;
    }
    
    final lastRefresh = DateTime.fromMillisecondsSinceEpoch(lastRefreshMs);
    return DateTime.now().difference(lastRefresh);
  }
  
  StartupMetrics createMetrics({
    required DateTime startTime,
    DateTime? dataLoadedTime,
    bool wasDataFresh = false,
    bool hadStoredLocation = false,
    String? errorMessage,
  }) {
    Duration? totalLoadTime;
    if (dataLoadedTime != null) {
      totalLoadTime = dataLoadedTime.difference(startTime);
    }
    
    return StartupMetrics(
      startTime: startTime,
      dataLoadedTime: dataLoadedTime,
      totalLoadTime: totalLoadTime,
      wasDataFresh: wasDataFresh,
      hadStoredLocation: hadStoredLocation,
      errorMessage: errorMessage,
    );
  }
}