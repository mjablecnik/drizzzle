import 'package:drizzzle/services/startup/startup_data_loader.dart';
import 'package:drizzzle/ui/home/view_models/home_view_model.dart';
import 'package:drizzzle/ui/home/views/home_view.dart';
import 'package:drizzzle/ui/startup/startup_loading_indicator.dart';
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

    // Initialize startup data loader
    final startupDataLoader = context.read<StartupDataLoader>();
    Future.microtask(() async {
      await startupDataLoader.initializeApp();
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeViewModel = Provider.of<HomeViewModel>(context);
    final startupDataLoader = Provider.of<StartupDataLoader>(context);
    
    TextTheme textTheme = GoogleFonts.interTextTheme();
    final colorScheme = homeViewModel.colorScheme;

    return MaterialApp(
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
      home: _buildContent(startupDataLoader),
    );
  }
  
  Widget _buildContent(StartupDataLoader startupDataLoader) {
    if (startupDataLoader.isInitializing) {
      return StartupLoadingIndicator(
        state: startupDataLoader.loadingState,
        errorMessage: startupDataLoader.errorMessage,
        onRetry: startupDataLoader.retry,
      );
    }
    
    return const HomeView();
  }
}
