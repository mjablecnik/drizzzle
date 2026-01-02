import 'package:drizzzle/domain/models/daily_model.dart';
import 'package:drizzzle/domain/models/hourly_model.dart';
import 'package:flutter/material.dart';

class DailySelectionViewModel extends ChangeNotifier {
  int _selectedDayIndex = 1; // Default to "Today" (index 1)
  int get selectedDayIndex => _selectedDayIndex;

  List<HourlyModel> _allHourlyData = [];
  List<DailyModel> _allDailyData = [];
  
  List<HourlyModel> get filteredHourlyData => _getHourlyDataForSelectedDay();
  List<DailyModel> get dailyData => _allDailyData;

  void setAllHourlyData(List<HourlyModel> hourlyData) {
    _allHourlyData = hourlyData;
    notifyListeners();
  }

  void setAllDailyData(List<DailyModel> dailyData) {
    _allDailyData = dailyData;
  }

  void selectDay(int dayIndex) {
    _selectedDayIndex = dayIndex;
    notifyListeners();
  }

  List<HourlyModel> _getHourlyDataForSelectedDay() {
    if (_allHourlyData.isEmpty || _allDailyData.isEmpty) return [];
    
    // Get the selected day's date
    if (_selectedDayIndex >= _allDailyData.length) return [];
    
    final selectedDayDate = DateTime.parse(_allDailyData[_selectedDayIndex].dailyTime);
    
    // Filter hourly data for the selected day
    final filteredData = _allHourlyData.where((hourlyModel) {
      final hourlyDate = DateTime.parse(hourlyModel.hourlyTime);
      return hourlyDate.year == selectedDayDate.year &&
             hourlyDate.month == selectedDayDate.month &&
             hourlyDate.day == selectedDayDate.day;
    }).toList();
    
    return filteredData;
  }
}