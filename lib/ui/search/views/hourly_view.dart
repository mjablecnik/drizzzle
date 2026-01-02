import 'dart:io';
import 'dart:ui';

import 'package:drizzzle/domain/models/daily_model.dart';
import 'package:drizzzle/domain/models/hourly_model.dart';
import 'package:drizzzle/ui/home/view_models/daily_selection_view_model.dart';
import 'package:drizzzle/ui/home/view_models/unit_view_model.dart';
import 'package:drizzzle/ui/search/shared_widgets/custom_card.dart';
import 'package:drizzzle/ui/search/shared_widgets/shared_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../utils/converter_functions.dart';

class HourlyView extends StatefulWidget {
  const HourlyView({super.key, required this.hourlyModelList, required this.dailyModelList});
  final List<HourlyModel> hourlyModelList;
  final List<DailyModel> dailyModelList;

  @override
  State<HourlyView> createState() => _HourlyViewState();
}

class _HourlyViewState extends State<HourlyView> {
  final ScrollController _scrollController = ScrollController();
  int _lastSelectedDayIndex = -1;

  @override
  void initState() {
    super.initState();
    // Set the hourly data in the view model when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dailySelectionViewModel = Provider.of<DailySelectionViewModel>(context, listen: false);
      
      dailySelectionViewModel.setAllHourlyData(widget.hourlyModelList);
      dailySelectionViewModel.setAllDailyData(widget.dailyModelList);
      _lastSelectedDayIndex = dailySelectionViewModel.selectedDayIndex;
      
      // Initial scroll to noon after data is set
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _scrollToNoon(dailySelectionViewModel.filteredHourlyData);
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(HourlyView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update the hourly data when the widget is updated with new data
    if (oldWidget.hourlyModelList != widget.hourlyModelList || 
        oldWidget.dailyModelList != widget.dailyModelList) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final dailySelectionViewModel = Provider.of<DailySelectionViewModel>(context, listen: false);
        dailySelectionViewModel.setAllHourlyData(widget.hourlyModelList);
        dailySelectionViewModel.setAllDailyData(widget.dailyModelList);
      });
    }
  }

  void _scrollToNoon(List<HourlyModel> hourlyData) {
    if (hourlyData.isEmpty || !_scrollController.hasClients) return;
    
    int noonIndex = -1;
    int closestToNoonIndex = 0;
    int minDifferenceFromNoon = 24;
    int currentHour = DateTime.now().hour - 3;
    
    for (int i = 0; i < hourlyData.length; i++) {
      final hourlyTime = DateTime.parse(hourlyData[i].hourlyTime);
      final hour = hourlyTime.hour;
      
      if (hour == currentHour) {
        noonIndex = i;
        break;
      }
      
      final differenceFromNoon = (hour - 12).abs();
      if (differenceFromNoon < minDifferenceFromNoon) {
        minDifferenceFromNoon = differenceFromNoon;
        closestToNoonIndex = i;
      }
    }
    
    final targetIndex = noonIndex != -1 ? noonIndex : closestToNoonIndex;
    
    // Calculate scroll position
    // Each item width is approximately 80 (card width + padding)
    // We want to center the noon item, so we scroll to show it in the middle
    const double itemWidth = 88.0; // 72 (card width) + 8 (separator) + 8 (padding)
    final double screenWidth = MediaQuery.of(context).size.width;
    final double targetScrollPosition = (targetIndex * itemWidth) - (screenWidth / 2) + (itemWidth / 2);
    
    // Ensure we don't scroll beyond bounds
    final double maxScrollExtent = _scrollController.position.maxScrollExtent;
    final double clampedPosition = targetScrollPosition.clamp(0.0, maxScrollExtent);
    
    _scrollController.jumpTo(clampedPosition);
  }

  @override
  Widget build(BuildContext context) {
    return _hourlyFull();
  }

  Widget _hourlyFull() {
    final colorScheme = Theme.of(context).colorScheme;
    return Consumer<DailySelectionViewModel>(
      builder: (context, dailySelectionViewModel, child) {
        String selectedDayTitle = 'Hourly forecast';
        if (dailySelectionViewModel.dailyData.isNotEmpty && 
            dailySelectionViewModel.selectedDayIndex < dailySelectionViewModel.dailyData.length) {
          final selectedDay = dailySelectionViewModel.dailyData[dailySelectionViewModel.selectedDayIndex];
          final selectedDate = DateTime.parse(selectedDay.dailyTime);
          final today = DateTime.now();
          final yesterday = today.subtract(const Duration(days: 1));
          
          if (selectedDate.year == today.year && 
              selectedDate.month == today.month && 
              selectedDate.day == today.day) {
            selectedDayTitle = 'Today - Hourly forecast';
          } else if (selectedDate.year == yesterday.year && 
                     selectedDate.month == yesterday.month && 
                     selectedDate.day == yesterday.day) {
            selectedDayTitle = 'Yesterday - Hourly forecast';
          } else {
            final weekday = iso8601ToWeekday(selectedDay.dailyTime);
            selectedDayTitle = '$weekday - Hourly forecast';
          }
        }
        
        return CustomCard(
          color: colorScheme.surfaceContainer,
          radius: 24,
          horizontal: 12,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SharedTitle(
                title: selectedDayTitle,
                iconData: Icons.access_time_rounded,
              ),
              const SizedBox(height: 4),
              Divider(color: colorScheme.onSurfaceVariant.withAlpha(125)),
              const SizedBox(height: 4),
              CustomCard(
                radius: 16,
                color: Colors.transparent,
                horizontal: 0,
                vertical: 0,
                child: SizedBox(
                  height: 135,
                  child: _hourly(),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  //hourly list
  Widget _hourly() {
    return Consumer<DailySelectionViewModel>(
      builder: (context, dailySelectionViewModel, child) {
        final hourlyData = dailySelectionViewModel.filteredHourlyData;
        
        // Check if day selection has changed and trigger scroll to noon
        if (_lastSelectedDayIndex != dailySelectionViewModel.selectedDayIndex) {
          _lastSelectedDayIndex = dailySelectionViewModel.selectedDayIndex;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToNoon(hourlyData);
          });
        }
        
        if (hourlyData.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No hourly data available for selected day',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        
        final listView = ListView.separated(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: hourlyData.length,
          itemBuilder: (context, index) {
            final hourlyModelListItem = hourlyData[index];
            return _HourlyInformation(
              hourlyTime: hourlyModelListItem.hourlyTime,
              hourlyTemperature: hourlyModelListItem.hourlyTemperature,
              hourlyRelativeHumidity: hourlyModelListItem.hourlyRelativeHumidity,
              hourlyApparentTemperature:
                  hourlyModelListItem.hourlyApparentTemperature,
              hourlyWeatherIconPath: hourlyModelListItem.hourlyWeatherIconPath,
              hourlyPrecipitationProbablity:
                  hourlyModelListItem.hourlyPrecipitationProbablity,
              hourlyWindSpeed: hourlyModelListItem.hourlyWindSpeed,
              hourlyWindDirection: hourlyModelListItem.hourlyWindDirection,
            );
          },
          separatorBuilder: (context, index) => const SizedBox(
            width: 8,
          ),
        );
        
        if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
          return ScrollConfiguration(
              behavior: const ScrollBehavior().copyWith(
                  scrollbars: true,
                  dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch}),
              child: listView);
        } else {
          return listView;
        }
      },
    );
  }
}

class _HourlyInformation extends StatelessWidget {
  const _HourlyInformation({
    required this.hourlyTime,
    required this.hourlyTemperature,
    required this.hourlyRelativeHumidity,
    required this.hourlyApparentTemperature,
    required this.hourlyWeatherIconPath,
    required this.hourlyPrecipitationProbablity,
    required this.hourlyWindSpeed,
    required this.hourlyWindDirection,
  });
  final String hourlyTime;
  final String hourlyTemperature;
  final String hourlyRelativeHumidity;
  final String hourlyApparentTemperature;
  final String hourlyWeatherIconPath;
  final String hourlyPrecipitationProbablity;
  final String hourlyWindSpeed;
  final int hourlyWindDirection;
  @override
  Widget build(BuildContext context) {
    final time = iso8601ToTime(hourlyTime);
    final amOrPm = time.beforeMidday ? 'am' : 'pm';
    final precipitationIconData = precipitationProbablityToIconData(
        int.parse(hourlyPrecipitationProbablity));
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final UnitViewModel unitViewModel = Provider.of<UnitViewModel>(context);
    final isC = unitViewModel.isC ? 'C' : 'F';

    final String hourlyPrecipitationProbablityPadded =
        "$hourlyPrecipitationProbablity%".padRight(3, ' ');
    final String timeHourPadded = "${time.hour} $amOrPm".padRight(5, ' ');
    final String hourlyTemperaturePadded =
        "${isC == 'F' ? celsiusToFahrenheit(hourlyTemperature) : hourlyTemperature}\u00b0"
            .padRight(2, ' ');

    return CustomCard(
      color: colorScheme.surfaceContainerHighest,
      radius: 16,
      horizontal: 8,
      vertical: 12,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            timeHourPadded,
            style: textTheme.labelLarge!.copyWith(
                color: colorScheme.onSurfaceVariant, letterSpacing: -1),
          ),
          const SizedBox(height: 2),
          SvgPicture.asset(
            hourlyWeatherIconPath,
            height: 32,
            width: 32,
          ),
          const SizedBox(height: 2),
          Text(
            hourlyTemperaturePadded,
            style: textTheme.bodyLarge!.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 18),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                precipitationIconData,
                size: 16,
                color: colorScheme.onSurfaceVariant.withAlpha(75),
              ),
              const SizedBox(width: 4),
              Text(
                hourlyPrecipitationProbablityPadded,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
