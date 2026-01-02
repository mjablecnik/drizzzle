import 'package:drizzzle/domain/models/weather.dart';
import 'package:drizzzle/ui/home/views/home_error_view.dart';
import 'package:drizzzle/ui/home/views/home_initial_view.dart';
import 'package:drizzzle/ui/home/views/home_loading_view.dart';
import 'package:drizzzle/ui/home/views/home_success_view.dart';
import 'package:drizzzle/ui/search/view_models/weather_view_model.dart';
import 'package:drizzzle/ui/search/views/cloud_cover_view.dart';
import 'package:drizzzle/ui/search/views/current_view.dart';
import 'package:drizzzle/ui/search/views/daily_view.dart';
import 'package:drizzzle/ui/search/views/hourly_view.dart';
import 'package:drizzzle/ui/search/views/humidity_view.dart';
import 'package:drizzzle/ui/search/views/particles_view.dart';
import 'package:drizzzle/ui/search/views/precipitation_view.dart';
import 'package:drizzzle/ui/search/views/pressure_view.dart';
import 'package:drizzzle/ui/search/views/uv_index_view.dart';
import 'package:drizzzle/ui/search/views/wind_speed_view.dart';
import 'package:drizzzle/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    final weatherViewModel = Provider.of<WeatherViewModel>(context);
    late Widget homeWidget;

    if (weatherViewModel.weather == null) {
      homeWidget = const HomeInitialView();
    } else if (weatherViewModel.loading) {
      homeWidget = const HomeLoadingView();
    } else {
      final result = weatherViewModel.weather;
      switch (result) {
        case null:
          homeWidget = const HomeInitialView();
        case Ok<Weather>():
          final val = result.value;
          final weatherBody = _weatherBody(val);
          homeWidget = HomeSuccessView(
            widgetList: weatherBody,
            currentTemperature: val.currentTemperature,
            locationName: val.locationName,
            currentWeatherDescription: val.currentWeatherIconDescription,
            currentWeatherIconPath: val.currentWeatherIconPath,
          );
        case Error<Weather>():
          homeWidget = const HomeErrorView();
      }
    }
    return homeWidget;
  }

  List<Widget> _weatherBody(Weather val) {
    return [
      CurrentView(
        locationName: val.locationName,
        currentTemperature: val.currentTemperature,
        currentApparentTemperature: val.currentApparentTemperature,
        currentWeatherIconPath: val.currentWeatherIconPath,
        currentWeatherDescription: val.currentWeatherIconDescription,
        dailyTemperatureMax: val.dailyModelList.first.dailyTemperatureMax,
        dailyTemperatureMin: val.dailyModelList.first.dailyTemperatureMin,
      ),
      const SizedBox(height: 8),
      HourlyView(
        hourlyModelList: val.hourlyModelList,
        dailyModelList: val.dailyModelList,
      ),
      const SizedBox(height: 8),
      DailyView(dailyModelList: val.dailyModelList),
      const SizedBox(height: 8),
      Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: UvIndexView(aqUvIndex: val.aqUvIndex)),
          const SizedBox(width: 8),
          Expanded(
            child: HumidityView(
                currentRelativeHumidity: val.currentRelativeHumidity),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: WindSpeedView(
            windSpeed_10m: val.currentWindSpeed,
            windDirection_10m: val.currentWindDirection,
          )),
          const SizedBox(width: 8),
          Expanded(
            child: CloudCoverView(currentCloudCover: val.currentCloudCover),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: PrecipitationView(
                  currentPrecipitation: val.currentPrecipitation)),
          const SizedBox(width: 8),
          Expanded(
            child: PressureView(
                currentSurfacePressure: val.currentSurfacePressure),
          ),
        ],
      ),
      const SizedBox(height: 8),
      ParticlesView(
          aqdust: val.aqdust,
          aqozone: val.aqOzone,
          aqSulphure: val.aqSulphure,
          aqNitrogen: val.aqNitrogen,
          aqCarbon: val.aqCarbon,
          aqPm2_5: val.aqPm2_5,
          aqPm10: val.aqPm10),
    ];
  }
}
