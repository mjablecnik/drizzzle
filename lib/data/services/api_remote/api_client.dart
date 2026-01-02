import 'dart:convert';
import 'dart:io';
import 'package:drizzzle/data/services/api_remote/model/air_quality/air_quality.dart';
import 'package:drizzzle/data/services/api_remote/model/current/current.dart';
import 'package:drizzzle/data/services/api_remote/model/daily/daily.dart';
import 'package:drizzzle/data/services/api_remote/model/hourly/hourly.dart';
import 'package:drizzzle/data/services/api_remote/model/location/location.dart';
import 'package:drizzzle/utils/resource_string.dart';

import 'package:http/http.dart' as http;
import '../../../utils/result.dart';

class ApiClient {
  final http.Client _httpClient;
  ApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();
  // get location data
  Future<Result<Location>> getLocations(
    String name, [
    int count = 20,
  ]) async {
    final Uri httpUri = Uri(
        scheme: ResourceString.scheme,
        host: ResourceString.geocodingHost,
        path: ResourceString.geocodingPath,
        queryParameters: {
          ResourceString.geoNameQuery: name,
          ResourceString.geoCountQuery: '$count',
        });
    return _handleRequest<Location>(
      httpUri,
      (json) => Location.fromJson(json),
    );
  }

  // get current weather data
  Future<Result<Current>> getCurrentData(
    double latitude,
    double longitude,
    String? timezone,
  ) async {
    final Uri httpUri = Uri(
        scheme: ResourceString.scheme,
        host: ResourceString.weatherHost,
        path: ResourceString.weatherPath,
        queryParameters: {
          ResourceString.latitudeQuery: latitude.toString(),
          ResourceString.longitudeQuery: longitude.toString(),
          ResourceString.currentQuery: ResourceString.currentQueryValue,
          if (timezone != null) ResourceString.timezoneQuery: timezone,
          ResourceString.forecastQuery: ResourceString.forecastDaysQueryValue,
        });
    return _handleRequest<Current>(
      httpUri,
      (json) => Current.fromJson(json),
    );
  }

  // get hourly weather data
  Future<Result<Hourly>> getHourlyData(
    double latitude,
    double longitude,
    String? timezone,
  ) async {
    final Uri httpUri = Uri(
        scheme: ResourceString.scheme,
        host: ResourceString.weatherHost,
        path: ResourceString.weatherPath,
        queryParameters: {
          ResourceString.latitudeQuery: latitude.toString(),
          ResourceString.longitudeQuery: longitude.toString(),
          ResourceString.hourlyQuery: ResourceString.hourlyQueryValue,
          if (timezone != null) ResourceString.timezoneQuery: timezone,
          ResourceString.pastdaysQuery: '1',
          ResourceString.forecastQuery: '7', // Increased from 7 to 14 days to ensure we have hourly data for all daily forecast days
        });
    return _handleRequest<Hourly>(
      httpUri,
      (json) => Hourly.fromJson(json),
    );
  }

  // get daily weather data
  Future<Result<Daily>> getDailyData(
    double latitude,
    double longitude,
    String? timezone,
  ) async {
    final Uri httpUri = Uri(
        scheme: ResourceString.scheme,
        host: ResourceString.weatherHost,
        path: ResourceString.weatherPath,
        queryParameters: {
          ResourceString.latitudeQuery: latitude.toString(),
          ResourceString.longitudeQuery: longitude.toString(),
          ResourceString.dailyQuery: ResourceString.dailyQueryValue,
          if (timezone != null) ResourceString.timezoneQuery: timezone,
          ResourceString.pastdaysQuery: '1',
          ResourceString.forecastQuery: '7',
        });
    return _handleRequest<Daily>(
      httpUri,
      (json) => Daily.fromJson(json),
    );
  }

  // get air quality data
  Future<Result<AirQuality>> getAirQualityData(
      double latitude, double longitude, String? timezone) async {
    final Uri httpUri = Uri(
        scheme: ResourceString.scheme,
        host: ResourceString.airQualityHost,
        path: ResourceString.airQualityPath,
        queryParameters: {
          ResourceString.latitudeQuery: latitude.toString(),
          ResourceString.longitudeQuery: longitude.toString(),
          ResourceString.currentQuery: ResourceString.airQualityQueryValue,
          if (timezone != null) ResourceString.timezoneQuery: timezone,
          ResourceString.forecastQuery: ResourceString.forecastDaysQueryValue,
          'domains': 'cams_global',
        });
    return _handleRequest<AirQuality>(
      httpUri,
      (json) => AirQuality.fromJson(json),
    );
  }

  Future<Result<T>> _handleRequest<T>(
    Uri uri,
    T Function(Map<String, Object?>) fromJson,
  ) async {
    try {
      final response = await _httpClient.get(uri);
      if (response.statusCode != HttpStatus.ok) {
        return Result.error(Exception());
      }
      final json = jsonDecode(response.body) as Map<String, Object?>;
      return Result.ok(fromJson(json));
    } on Exception catch (error) {
      return Result.error(error);
    }
  }
}
