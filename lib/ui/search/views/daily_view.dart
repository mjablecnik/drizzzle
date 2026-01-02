import 'package:drizzzle/domain/models/daily_model.dart';
import 'package:drizzzle/ui/home/view_models/daily_selection_view_model.dart';
import 'package:drizzzle/ui/home/view_models/unit_view_model.dart';
import 'package:drizzzle/ui/search/shared_widgets/custom_card.dart';
import 'package:drizzzle/utils/converter_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../shared_widgets/shared_title.dart';

class DailyView extends StatefulWidget {
  const DailyView({
    super.key,
    required this.dailyModelList,
  });
  final List<DailyModel> dailyModelList;
  @override
  State<DailyView> createState() => _DailyViewState();
}

class _DailyViewState extends State<DailyView> {
  @override
  Widget build(BuildContext context) {
    return _dailyFull();
  }

  Widget _dailyFull() {
    final colorScheme = Theme.of(context).colorScheme;
    return CustomCard(
      color: colorScheme.surfaceContainer,
      radius: 24,
      horizontal: 12,
      vertical: 12,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SharedTitle(
            title: 'Daily forecast',
            iconData: Icons.calendar_today_outlined,
          ),
          const SizedBox(height: 4),
          Divider(color: colorScheme.onSurfaceVariant.withAlpha(125)),
          const SizedBox(height: 4),
          SizedBox(
            //height: 1000,
            child: Column(
              children: widget.dailyModelList.asMap().entries.map((entry) {
                int index = entry.key;
                final dailyModelListItem = entry.value;
                return _DailyInformation(
                  dailyTime: dailyModelListItem.dailyTime,
                  dailyWeatherIconPath: dailyModelListItem.dailyWeatherIconPath,
                  dailyTemperatureMax: dailyModelListItem.dailyTemperatureMax,
                  dailyTemperatureMin: dailyModelListItem.dailyTemperatureMin,
                  dailyPrecipitationProbablity:
                      dailyModelListItem.dailyPrecipitationProbablity,
                  index: index,
                  top: index == 0
                      ? true
                      : index == widget.dailyModelList.length - 1
                          ? false
                          : null,
                  onTap: () {
                    final dailySelectionViewModel = Provider.of<DailySelectionViewModel>(context, listen: false);
                    dailySelectionViewModel.selectDay(index);
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyInformation extends StatelessWidget {
  const _DailyInformation({
    required this.dailyTime,
    required this.dailyTemperatureMin,
    required this.dailyTemperatureMax,
    required this.dailyPrecipitationProbablity,
    required this.dailyWeatherIconPath,
    required this.index,
    this.top,
    this.onTap,
  });
  final String dailyTime;
  final String dailyTemperatureMin;
  final String dailyTemperatureMax;
  final String dailyPrecipitationProbablity;
  final String dailyWeatherIconPath;
  final bool? top;
  final int index;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dailySelectionViewModel = Provider.of<DailySelectionViewModel>(context);
    String weekday = iso8601ToWeekday(dailyTime);

    if (index == 0) {
      weekday = 'Yesterday';
    } else if (index == 1) {
      weekday = 'Today';
    }
    late BorderRadiusGeometry borderRadius;
    const radius = Radius.circular(16);
    const commonRadius = Radius.circular(4);
    switch (top) {
      case null:
        borderRadius = const BorderRadius.all(commonRadius);
      case true:
        borderRadius = const BorderRadius.only(
          topLeft: radius,
          topRight: radius,
          bottomLeft: commonRadius,
          bottomRight: commonRadius,
        );
      case false:
        borderRadius = const BorderRadius.only(
          topLeft: commonRadius,
          topRight: commonRadius,
          bottomRight: radius,
          bottomLeft: radius,
        );
    }

    int len = dailyPrecipitationProbablity.length;
    String dailyPrecipitationProbablityPadded =
        "$dailyPrecipitationProbablity%";
    if (len < 3) {
      if (len == 1) {
        dailyPrecipitationProbablityPadded = "  $dailyPrecipitationProbablity%";
      } else if (len == 2) {
        dailyPrecipitationProbablityPadded = " $dailyPrecipitationProbablity%";
      }
    }

    final UnitViewModel unitViewModel = Provider.of<UnitViewModel>(context);
    final isC = unitViewModel.isC ? 'C' : 'F';
    final isSelected = dailySelectionViewModel.selectedDayIndex == index;
    
    return GestureDetector(
      onTap: onTap,
      child: Card.filled(
        color: isSelected
            ? colorScheme.secondaryContainer
            : colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        margin: EdgeInsets.only(bottom: (top == null || top == true) ? 2 : 0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  weekday,
                  style: textTheme.bodyLarge!.copyWith(
                      color: isSelected
                          ? colorScheme.onSecondaryContainer
                          : colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                precipitationProbablityToIconData(
                    int.parse(dailyPrecipitationProbablity)),
                color: isSelected
                    ? colorScheme.onSecondaryContainer.withAlpha(75)
                    : colorScheme.onSurfaceVariant.withAlpha(75),
                size: 20,
              ),
              const SizedBox(width: 2),
              Text(
                dailyPrecipitationProbablityPadded,
                style: textTheme.bodySmall!.copyWith(
                    color: isSelected
                        ? colorScheme.onSecondaryContainer
                        : colorScheme.onSurfaceVariant),
              ),
              const SizedBox(width: 24),
              SvgPicture.asset(
                dailyWeatherIconPath,
                height: 42,
                width: 42,
              ),
              const SizedBox(width: 12),
              Text(
                '${isC == 'F' ? celsiusToFahrenheit(dailyTemperatureMax) : dailyTemperatureMax}\u00b0',
                style: textTheme.bodyLarge!.copyWith(
                    color: isSelected
                        ? colorScheme.onSecondaryContainer
                        : colorScheme.secondary,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 4),
              Text(
                '${isC == 'F' ? celsiusToFahrenheit(dailyTemperatureMin) : dailyTemperatureMin}\u00b0',
                style: textTheme.bodyLarge!.copyWith(
                    color: isSelected
                        ? colorScheme.onSecondaryContainer.withAlpha(125)
                        : colorScheme.onSurfaceVariant.withAlpha(125)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
