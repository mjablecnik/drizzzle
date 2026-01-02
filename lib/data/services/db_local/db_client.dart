import 'dart:io';

import 'package:drizzzle/domain/models/daily_model.dart';
import 'package:drizzzle/domain/models/hourly_model.dart';
import 'package:drizzzle/domain/models/weather.dart';
import 'package:drizzzle/utils/converter_functions.dart';
import 'package:drizzzle/utils/resource_string.dart';
import 'package:drizzzle/utils/result.dart';
import 'package:drizzzle/utils/widget_update_function.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class DbClient {
  final Database db;

  DbClient({required this.db});
  Future<void> insert(Weather weather) async {
    await db.insert(
        CurrentTable.tableName,
        {
          'id': 1,
          CurrentTable.columnLocationName: weather.locationName,
          CurrentTable.columnCurrentTemperature: weather.currentTemperature,
          CurrentTable.columnCurrentRelativeHumidity:
              weather.currentRelativeHumidity,
          CurrentTable.columnCurrentPrecipitation: weather.currentPrecipitation,
          CurrentTable.columnCurrentApparentTemperature:
              weather.currentApparentTemperature,
          CurrentTable.columnCurrentWeatherIconPath:
              weather.currentWeatherIconPath,
          CurrentTable.columnCurrentWeatherIconDescription:
              weather.currentWeatherIconDescription,
          CurrentTable.columnCurrentCloudCover: weather.currentCloudCover,
          CurrentTable.columnCurrentAtmospherePressure:
              weather.currentAtmospherePressure,
          CurrentTable.columnCurrentSurfacePressure:
              weather.currentSurfacePressure,
          CurrentTable.columnCurrentWindSpeed: weather.currentWindSpeed,
          CurrentTable.columnCurrentWindDirection: weather.currentWindDirection,
          CurrentTable.columnAqUsAqi: weather.aqUsAqi,
          CurrentTable.columnAqUvIndex: weather.aqUvIndex,
          CurrentTable.columnAqdust: weather.aqdust,
          CurrentTable.columnAqOzone: weather.aqOzone,
          CurrentTable.columnAqSulphure: weather.aqSulphure,
          CurrentTable.columnAqNitrogen: weather.aqNitrogen,
          CurrentTable.columnAqCarbon: weather.aqCarbon,
          CurrentTable.columnAqPm2_5: weather.aqPm2_5,
          CurrentTable.columnAqPm10: weather.aqPm10
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
    for (final entry in weather.hourlyModelList.asMap().entries) {
      final index = entry.key;
      final hourlyModel = entry.value;
      await db.insert(
        HourlyTable.tableName,
        {
          'id': index,
          HourlyTable.columnHourlyTime: hourlyModel.hourlyTime,
          HourlyTable.columnHourlyTemperature: hourlyModel.hourlyTemperature,
          HourlyTable.columnHourlyRelativeHumidity:
              hourlyModel.hourlyRelativeHumidity,
          HourlyTable.columnHourlyApparentTemperature:
              hourlyModel.hourlyApparentTemperature,
          HourlyTable.columnHourlyWeatherIconPath:
              hourlyModel.hourlyWeatherIconPath,
          HourlyTable.columnHourlyPrecipitationProbablity:
              hourlyModel.hourlyPrecipitationProbablity,
          HourlyTable.columnHourlyWindSpeed: hourlyModel.hourlyWindSpeed,
          HourlyTable.columnHourlyWindDirection: hourlyModel.hourlyWindDirection
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      ); // await each operation
    }

    for (final entry in weather.dailyModelList.asMap().entries) {
      final index = entry.key;
      final dailyModel = entry.value;
      await db.insert(
        DailyTable.tableName,
        {
          'id': index,
          DailyTable.columnDailyTime: dailyModel.dailyTime,
          DailyTable.columnDailyWeatherIconPath:
              dailyModel.dailyWeatherIconPath,
          DailyTable.columnDailyTemperatureMax: dailyModel.dailyTemperatureMax,
          DailyTable.columnDailyTemperatureMin: dailyModel.dailyTemperatureMin,
          DailyTable.columnDailySunrise: dailyModel.dailySunrise,
          DailyTable.columnDailySunset: dailyModel.dailySunset,
          DailyTable.columnDailyPrecipitationProbablity:
              dailyModel.dailyPrecipitationProbablity
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    return;
  }

  Future<Result<Weather>> getWeather() async {
    List<Map> currentMaps =
        await db.query(CurrentTable.tableName, where: 'id=?', whereArgs: [1]);
    if (currentMaps.isEmpty) {
      return Result.error(Exception());
    }
    var hourlyIds = List.generate(24*8, (int i) => i);
    String placeholders = List.filled(hourlyIds.length, '?').join(',');

    List<Map> hourlyMaps = await db.query(HourlyTable.tableName,
        where: 'id IN ($placeholders)',
        whereArgs: List.generate(24*8, (int i) => i));
    if (hourlyMaps.isEmpty) {
      return Result.error(Exception());
    }

    var dailyIds = List.generate(8, (int i) => i);
    placeholders = List.filled(dailyIds.length, '?').join(',');

    List<Map> dailyMaps = await db.query(DailyTable.tableName,
        where: 'id IN ($placeholders)', whereArgs: dailyIds);
    if (dailyMaps.isEmpty) {
      return Result.error(Exception());
    }
    final hourlyModelList = hourlyMaps.map((m) {
      final hourlyMap = m;
      return HourlyModel(
        hourlyTime: hourlyMap[HourlyTable.columnHourlyTime] as String,
        hourlyTemperature:
            hourlyMap[HourlyTable.columnHourlyTemperature] as String,
        hourlyRelativeHumidity:
            hourlyMap[HourlyTable.columnHourlyRelativeHumidity] as String,
        hourlyApparentTemperature:
            hourlyMap[HourlyTable.columnHourlyApparentTemperature] as String,
        hourlyWeatherIconPath:
            hourlyMap[HourlyTable.columnHourlyWeatherIconPath] as String,
        hourlyPrecipitationProbablity:
            hourlyMap[HourlyTable.columnHourlyPrecipitationProbablity]
                as String,
        hourlyWindSpeed: hourlyMap[HourlyTable.columnHourlyWindSpeed] as String,
        hourlyWindDirection:
            hourlyMap[HourlyTable.columnHourlyWindDirection] as int,
      );
    }).toList();

    final dailyModelList = dailyMaps.map((m) {
      final dailyMap = m;

      return DailyModel(
        dailyTime: dailyMap[DailyTable.columnDailyTime] as String,
        dailyWeatherIconPath:
            dailyMap[DailyTable.columnDailyWeatherIconPath] as String,
        dailyTemperatureMax:
            dailyMap[DailyTable.columnDailyTemperatureMax] as String,
        dailyTemperatureMin:
            dailyMap[DailyTable.columnDailyTemperatureMin] as String,
        dailySunrise: dailyMap[DailyTable.columnDailySunrise] as String,
        dailySunset: dailyMap[DailyTable.columnDailySunset] as String,
        dailyPrecipitationProbablity:
            dailyMap[DailyTable.columnDailyPrecipitationProbablity] as String,
      );
    }).toList();

    final currentMap = currentMaps.first;

    final weather = Weather(
      locationName: currentMap[CurrentTable.columnLocationName] as String,
      currentTemperature:
          currentMap[CurrentTable.columnCurrentTemperature] as String,
      currentRelativeHumidity:
          currentMap[CurrentTable.columnCurrentRelativeHumidity] as String,
      currentPrecipitation:
          currentMap[CurrentTable.columnCurrentPrecipitation] as String,
      currentApparentTemperature:
          currentMap[CurrentTable.columnCurrentApparentTemperature] as String,
      currentWeatherIconPath:
          currentMap[CurrentTable.columnCurrentWeatherIconPath] as String,
      currentWeatherIconDescription:
          currentMap[CurrentTable.columnCurrentWeatherIconDescription]
              as String,
      currentCloudCover:
          currentMap[CurrentTable.columnCurrentCloudCover] as String,
      currentAtmospherePressure:
          currentMap[CurrentTable.columnCurrentAtmospherePressure] as String,
      currentSurfacePressure:
          currentMap[CurrentTable.columnCurrentSurfacePressure] as String,
      currentWindSpeed:
          currentMap[CurrentTable.columnCurrentWindSpeed] as String,
      currentWindDirection:
          currentMap[CurrentTable.columnCurrentWindDirection] as int,
      hourlyModelList: hourlyModelList,
      dailyModelList: dailyModelList,
      aqUsAqi: currentMap[CurrentTable.columnAqUsAqi] as String,
      aqUvIndex: currentMap[CurrentTable.columnAqUvIndex] as String,
      aqdust: currentMap[CurrentTable.columnAqdust] as String,
      aqOzone: currentMap[CurrentTable.columnAqOzone] as String,
      aqSulphure: currentMap[CurrentTable.columnAqSulphure] as String,
      aqNitrogen: currentMap[CurrentTable.columnAqNitrogen] as String,
      aqCarbon: currentMap[CurrentTable.columnAqCarbon] as String,
      aqPm2_5: currentMap[CurrentTable.columnAqPm2_5] as String,
      aqPm10: currentMap[CurrentTable.columnAqPm10] as String,
    );
    if (Platform.isAndroid) {
      final pref = await SharedPreferences.getInstance();
      bool? isC = pref.getBool(SharedPreferencesKeys.temperatureUnitKey);

      await updateCurrentWidget(
          precipitationProbability:
              '${weather.dailyModelList[1].dailyPrecipitationProbablity}%',
          cityName: weather.locationName,
          weatherCondition: weather.currentWeatherIconDescription,
          weatherIconPath: weather.currentWeatherIconPath,
          currentTemperature: (isC == null || isC == true)
              ? '${weather.currentTemperature}\u00b0C'
              : '${celsiusToFahrenheit(weather.currentTemperature)}\u00b0F');
    }

    return Result.ok(weather);
  }
}
