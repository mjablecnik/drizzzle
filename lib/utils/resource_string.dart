class ResourceString {
  // geocoding
  static const scheme = 'https';
  static const geocodingHost = 'geocoding-api.open-meteo.com';
  static const geocodingPath = '/v1/search';

  // current hourly daily
  static const weatherHost = 'api.open-meteo.com';
  static const weatherPath = '/v1/forecast';

  // air quality
  static const airQualityHost = 'air-quality-api.open-meteo.com';
  static const airQualityPath = '/v1/air-quality';

  // geocoding query parameter
  static const geoNameQuery = 'name';
  static const geoCountQuery = 'count';

  // current hourly parameter
  static const latitudeQuery = 'latitude';
  static const longitudeQuery = 'longitude';
  static const currentQuery = 'current';
  static const hourlyQuery = 'hourly';
  static const dailyQuery = 'daily';
  static const timezoneQuery = 'timezone';
  static const forecastQuery = 'forecast_days';
  static const pastdaysQuery = 'past_days';

  // current hourly parameter value
  static const currentQueryValue =
      'temperature_2m,relative_humidity_2m,apparent_temperature,is_day,weather_code,cloud_cover,pressure_msl,surface_pressure,wind_speed_10m,wind_direction_10m,precipitation';
  static const hourlyQueryValue =
      'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation_probability,weather_code,wind_speed_10m,wind_direction_10m,is_day';
  static const forecastDaysQueryValue = '7';
  // daily parameter value
  static const dailyQueryValue =
      'weather_code,temperature_2m_max,temperature_2m_min,apparent_temperature_max,apparent_temperature_min,sunrise,sunset,uv_index_max,precipitation_probability_max,wind_speed_10m_max,wind_direction_10m_dominant';
  //https://air-quality-api.open-meteo.com/v1/air-quality?latitude=52.52&longitude=13.41&current=us_aqi,pm10,pm2_5,carbon_monoxide,nitrogen_dioxide,sulphur_dioxide,ozone,dust,uv_index&timezone=GMT&forecast_days=1&domains=cams_global
  // air quality parameter value
  static const airQualityQueryValue =
      'us_aqi,pm10,pm2_5,carbon_monoxide,nitrogen_dioxide,sulphur_dioxide,ozone,dust,uv_index';
}

class CurrentTable {
  static const tableName = 'current';
  static const columnLocationName = 'location_name';
  static const columnCurrentTemperature = 'current_temperature';
  static const columnCurrentRelativeHumidity = 'current_relative_humidity';
  static const columnCurrentPrecipitation = 'current_precipitation';
  static const columnCurrentApparentTemperature =
      'current_apparent_temperature';
  static const columnCurrentWeatherIconPath = 'current_weather_icon_path';
  static const columnCurrentWeatherIconDescription =
      'current_weather_icon_description';
  static const columnCurrentCloudCover = 'current_cloud_cover';
  static const columnCurrentAtmospherePressure = 'current_atmosphere_pressure';
  static const columnCurrentSurfacePressure = 'current_surface_pressure';
  static const columnCurrentWindSpeed = 'current_wind_speed';
  static const columnCurrentWindDirection = 'current_wind_direction';
  static const columnAqUsAqi = 'aq_us_aqi';
  static const columnAqUvIndex = 'aq_uv_index';
  static const columnAqdust = 'aq_dust';
  static const columnAqOzone = 'aq_ozone';
  static const columnAqSulphure = 'aq_sulphure';
  static const columnAqNitrogen = 'aq_nitrogen';
  static const columnAqCarbon = 'aq_carbon';
  static const columnAqPm2_5 = 'aq_pm2_5';
  static const columnAqPm10 = 'aq_pm10';
}

class DailyTable {
  static const tableName = 'daily';
  static const columnDailyTime = 'daily_time';
  static const columnDailyWeatherIconPath = 'daily_weather_icon_path';
  static const columnDailyTemperatureMax = 'daily_temperature_max';
  static const columnDailyTemperatureMin = 'daily_temperature_min';
  static const columnDailySunrise = 'daily_sunrise';
  static const columnDailySunset = 'daily_sunset';
  static const columnDailyPrecipitationProbablity =
      'daily_precipitationProbablity';
}

class HourlyTable {
  static const tableName = 'hourly';
  static const columnHourlyTime = 'hourly_time';
  static const columnHourlyTemperature = 'hourly_temperature';
  static const columnHourlyRelativeHumidity = 'hourly_relative_humidity';
  static const columnHourlyApparentTemperature = 'hourly_apparent_temperature';
  static const columnHourlyWeatherIconPath = 'hourly_weather_icon_path';
  static const columnHourlyPrecipitationProbablity =
      'hourly_precipitation_probablity';
  static const columnHourlyWindSpeed = 'hourly_wind_speed';
  static const columnHourlyWindDirection = 'hourly_wind_direction';
}

const String createCurrentTableExecution = '''
create table ${CurrentTable.tableName}(
  id integer primary key,
  ${CurrentTable.columnLocationName} text not null,
  ${CurrentTable.columnCurrentTemperature} text not null,
  ${CurrentTable.columnCurrentRelativeHumidity} text not null,
  ${CurrentTable.columnCurrentPrecipitation} text not null,
  ${CurrentTable.columnCurrentApparentTemperature} text not null,
  ${CurrentTable.columnCurrentWeatherIconPath} text not null,
  ${CurrentTable.columnCurrentWeatherIconDescription} text not null,
  ${CurrentTable.columnCurrentCloudCover} text not null,
  ${CurrentTable.columnCurrentAtmospherePressure} text not null,
  ${CurrentTable.columnCurrentSurfacePressure} text not null,
  ${CurrentTable.columnCurrentWindSpeed} text not null,
  ${CurrentTable.columnCurrentWindDirection} integer not null,
  ${CurrentTable.columnAqUsAqi} text not null,
  ${CurrentTable.columnAqUvIndex} text not null,
  ${CurrentTable.columnAqdust} text not null,
  ${CurrentTable.columnAqOzone} text not null,
  ${CurrentTable.columnAqSulphure} text not null,
  ${CurrentTable.columnAqNitrogen} text not null,
  ${CurrentTable.columnAqCarbon} text not null,
  ${CurrentTable.columnAqPm2_5} text not null,
  ${CurrentTable.columnAqPm10} text not null
)''';

const String createDailyTableExecution = '''
create table ${DailyTable.tableName}(
    id integer primary key,
    ${DailyTable.columnDailyTime} text not null,
    ${DailyTable.columnDailyWeatherIconPath} text not null,
    ${DailyTable.columnDailyTemperatureMax} text not null,
    ${DailyTable.columnDailyTemperatureMin} text not null,
    ${DailyTable.columnDailySunrise} text not null,
    ${DailyTable.columnDailySunset} text not null,
    ${DailyTable.columnDailyPrecipitationProbablity} text not null
)''';

const String createHourlyTableExecution = '''
create table ${HourlyTable.tableName}(
    id integer primary key,
    ${HourlyTable.columnHourlyTime} text not null,
    ${HourlyTable.columnHourlyTemperature} text not null,
    ${HourlyTable.columnHourlyRelativeHumidity} text not null,
    ${HourlyTable.columnHourlyApparentTemperature} text not null,
    ${HourlyTable.columnHourlyWeatherIconPath} text not null,
    ${HourlyTable.columnHourlyPrecipitationProbablity} text not null,
    ${HourlyTable.columnHourlyWindSpeed} text not null,
    ${HourlyTable.columnHourlyWindDirection} integer not null
)''';

class SharedPreferencesKeys {
  static const colorKey = "color";
  static const brightnessKey = "brightness";
  static const temperatureUnitKey = "temperature";
  static const windSpeedUnitKey = "wind_speed";
}

class AndroidWidgetNames {
  static const currentWeatherWidget = "CurrentWeatherWidget";
}

class AndroidWidgetKeys {
  static const temperatureKey = "current_temperature_text";
  static const cityNameKey = "current_city_text";
  static const weatherConditionKey = "current_weather_text";
  static const weatherIconIdKey = "current_weather_icon_id";
  static const precipitationProbabilityKey = "precipitation_key";
}
