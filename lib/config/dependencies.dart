import 'package:drizzzle/data/repositories/api_remote/location_repository.dart';
import 'package:drizzzle/data/repositories/api_remote/weather_repository.dart';
import 'package:drizzzle/data/repositories/storage_local/location_storage_repository.dart';
import 'package:drizzzle/data/services/db_local/db_client.dart';
import 'package:drizzzle/data/services/storage_local/location_storage_service.dart';
import 'package:drizzzle/services/startup/auto_refresh_service.dart';
import 'package:drizzzle/services/startup/startup_data_loader.dart';
import 'package:drizzzle/ui/home/view_models/daily_selection_view_model.dart';
import 'package:drizzzle/ui/home/view_models/home_view_model.dart';
import 'package:drizzzle/ui/home/view_models/unit_view_model.dart';
import 'package:drizzzle/ui/search/view_models/location_view_model.dart';
import 'package:drizzzle/ui/search/view_models/weather_view_model.dart';
import 'package:drizzzle/utils/resource_string.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<SingleChildWidget> providers(DbClient dbClient, SharedPreferences pref) {
  final LocationRepository locationRepository = LocationRepository();
  final WeatherRepository weatherRepository =
      WeatherRepository(dbClient: dbClient);
  
  // Create location storage services
  final LocationStorageService locationStorageService = 
      LocationStorageService(prefs: pref);
  final LocationStorageRepository locationStorageRepository = 
      LocationStorageRepository(storageService: locationStorageService);
  
  // Create weather view model
  final WeatherViewModel weatherViewModel = WeatherViewModel(
    weatherRepository: weatherRepository,
    locationStorageRepository: locationStorageRepository,
  );
  
  // Create startup services
  final AutoRefreshService autoRefreshService = AutoRefreshService(
    weatherRepository: weatherRepository,
    locationStorageRepository: locationStorageRepository,
    prefs: pref,
  );
  
  final StartupDataLoader startupDataLoader = StartupDataLoader(
    weatherViewModel: weatherViewModel,
    autoRefreshService: autoRefreshService,
  );
  
  final brightness = pref.getBool(SharedPreferencesKeys.brightnessKey);
  final indx = pref.getInt(SharedPreferencesKeys.colorKey);

  bool? isC = pref.getBool(SharedPreferencesKeys.temperatureUnitKey);
  bool? isKmh = pref.getBool(SharedPreferencesKeys.windSpeedUnitKey);
  if (isC == null) {
    isC = true;
    pref.setBool(SharedPreferencesKeys.temperatureUnitKey, isC);
  }
  if (isKmh == null) {
    isKmh = true;
    pref.setBool(SharedPreferencesKeys.windSpeedUnitKey, isKmh);
  }
  return [
    ChangeNotifierProvider(create: (_) => HomeViewModel(brightness, indx)),
    ChangeNotifierProvider(
        create: (_) =>
            LocationViewModel(locationRepository: locationRepository)),
    ChangeNotifierProvider.value(value: weatherViewModel),
    ChangeNotifierProvider.value(value: startupDataLoader),
    Provider.value(value: autoRefreshService),
    ChangeNotifierProvider(
        create: (_) => UnitViewModel(isC: isC!, isKmh: isKmh!)),
    ChangeNotifierProvider(create: (_) => DailySelectionViewModel()),
  ];
}
