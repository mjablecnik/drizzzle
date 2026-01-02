import 'package:drizzzle/ui/search/view_models/weather_view_model.dart';
import 'package:drizzzle/ui/search/views/search_view.dart';
import 'package:drizzzle/ui/search/views/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeSearchBar extends StatefulWidget {
  const HomeSearchBar({super.key});

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  @override
  Widget build(BuildContext context) {
    final weatherViewModel = context.watch<WeatherViewModel>();
    
    return Row(
      children: [
        const SizedBox(width: 4),
        const Expanded(child: SearchView()),
        const SizedBox(width: 8),
        // Refresh button - enabled only when location is stored
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: weatherViewModel.hasStoredLocation() 
            ? () async {
                final weatherViewModel = Provider.of<WeatherViewModel>(context, listen: false);
                await weatherViewModel.refreshWeatherFromStoredLocation();
                
                // Show error message if refresh failed
                if (weatherViewModel.weather != null && weatherViewModel.weather is Error) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to refresh weather. Please try again.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
              }
            : null, // Disable button when no location is stored
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () {
            final settingsRoute =
                MaterialPageRoute(builder: (context) => const SettingsView());
            Navigator.push(context, settingsRoute);
          },
        ),
      ],
    );
  }
}
