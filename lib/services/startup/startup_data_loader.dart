import 'package:drizzzle/domain/models/location_model.dart';
import 'package:drizzzle/services/startup/auto_refresh_service.dart';
import 'package:drizzzle/ui/search/view_models/weather_view_model.dart';
import 'package:flutter/foundation.dart';

enum StartupResult {
  freshDataLoaded,
  cachedDataLoaded,
  noDataAvailable,
  errorOccurred
}

enum StartupLoadingState {
  initializing,
  loadingStoredLocation,
  fetchingFreshData,
  processingData,
  completed,
  error
}

class StartupDataLoader extends ChangeNotifier {
  final WeatherViewModel _weatherViewModel;
  final AutoRefreshService _autoRefreshService;
  
  StartupDataLoader({
    required WeatherViewModel weatherViewModel,
    required AutoRefreshService autoRefreshService,
  }) : _weatherViewModel = weatherViewModel,
       _autoRefreshService = autoRefreshService;
  
  StartupLoadingState _loadingState = StartupLoadingState.initializing;
  StartupLoadingState get loadingState => _loadingState;
  
  StartupResult? _result;
  StartupResult? get result => _result;
  
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  bool _isInitializing = true;
  bool get isInitializing => _isInitializing;

  Future<StartupResult> initializeApp() async {
    try {
      _updateState(StartupLoadingState.initializing);
      
      // Load stored location first
      _updateState(StartupLoadingState.loadingStoredLocation);
      await _weatherViewModel.loadStoredLocation();
      
      // If no location is stored, set London as default
      if (!_weatherViewModel.hasStoredLocation() || _weatherViewModel.currentLocation == null) {
        final londonLocation = LocationModel(
          name: 'London',
          latitude: 51.5074,
          longitude: -0.1278,
          timezone: 'Europe/London',
          admin1: 'England',
          country: 'United Kingdom',
        );
        
        // Fetch and save weather for London with persistence
        await _weatherViewModel.fetchAndSaveWeatherWithPersistence(
          locationModel: londonLocation,
        );
        
        _updateState(StartupLoadingState.completed);
        _isInitializing = false;
        _result = StartupResult.freshDataLoaded;
        return _result!;
      }
      
      // Check if we should perform auto refresh for existing location
      if (await shouldPerformAutoRefresh()) {
        _updateState(StartupLoadingState.fetchingFreshData);
        
        // Perform auto refresh to get fresh data
        final refreshResult = await _autoRefreshService.performAutoRefresh();
        
        _updateState(StartupLoadingState.processingData);
        
        if (refreshResult.isOk) {
          _result = StartupResult.freshDataLoaded;
        } else {
          // If refresh failed, try to load cached data
          await _weatherViewModel.getLocalWeather();
          
          // If we still don't have weather data but have a location, try to fetch it
          if (_weatherViewModel.weather == null && _weatherViewModel.currentLocation != null) {
            await _weatherViewModel.fetchAndSaveWeather(
              locationModel: _weatherViewModel.currentLocation!,
            );
          }
          
          _result = _weatherViewModel.weather != null
              ? StartupResult.cachedDataLoaded
              : StartupResult.noDataAvailable;
        }
      } else {
        // Skip refresh, try to get local weather
        await _weatherViewModel.getLocalWeather();
        
        // If we still don't have weather data but have a location, try to fetch it
        if (_weatherViewModel.weather == null && _weatherViewModel.currentLocation != null) {
          await _weatherViewModel.fetchAndSaveWeather(
            locationModel: _weatherViewModel.currentLocation!,
          );
        }
        
        _result = _weatherViewModel.weather != null
            ? StartupResult.cachedDataLoaded
            : StartupResult.noDataAvailable;
      }
      
      _updateState(StartupLoadingState.completed);
      _isInitializing = false;
      
      return _result!;
    } catch (e) {
      _errorMessage = e.toString();
      _updateState(StartupLoadingState.error);
      _result = StartupResult.errorOccurred;
      _isInitializing = false;
      return _result!;
    }
  }

  Future<bool> shouldPerformAutoRefresh() async {
    // Always try to refresh if we have a stored location
    if (_weatherViewModel.hasStoredLocation()) {
      return !(await _autoRefreshService.shouldSkipRefresh());
    }
    return false;
  }

  Future<void> performStartupSequence() async {
    await initializeApp();
  }
  
  void _updateState(StartupLoadingState newState) {
    _loadingState = newState;
    notifyListeners();
  }
  
  void retry() {
    _errorMessage = null;
    _result = null;
    _isInitializing = true;
    initializeApp();
  }
}