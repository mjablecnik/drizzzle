import 'package:drizzzle/ui/home/view_models/home_view_model.dart';
import 'package:drizzzle/ui/home/views/home_view.dart';
import 'package:drizzzle/ui/search/view_models/weather_view_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();

    final WeatherViewModel weatherViewModel = context.read<WeatherViewModel>();
    Future.microtask(() async {
      // For testing purposes, let's try to fetch fresh data
      // You can comment this out and use getLocalWeather() for production
      try {
        // Try to get local weather first, but if we want fresh data, we need location
        await weatherViewModel.getLocalWeather();
      } catch (e) {
        // Error loading local weather - this is expected on first run
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeViewModel = Provider.of<HomeViewModel>(context);
    TextTheme textTheme = GoogleFonts.interTextTheme();
    final colorScheme = homeViewModel.colorScheme;

    return MaterialApp(
      //debugShowMaterialGrid: true,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: colorScheme.brightness,
        colorScheme: colorScheme,
        textTheme: textTheme.apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        ),
        scaffoldBackgroundColor: colorScheme.surface,
        canvasColor: colorScheme.surface,
      ),
      home: const HomeView(),
    );
  }
}
