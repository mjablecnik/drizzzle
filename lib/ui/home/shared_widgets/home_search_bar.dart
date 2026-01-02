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
    return Row(
      children: [
        const SizedBox(width: 4),
        const Expanded(child: SearchView()),
        const SizedBox(width: 8),
        // Temporary refresh button for testing
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () async {
            final weatherViewModel = Provider.of<WeatherViewModel>(context, listen: false);
            // Force refresh by getting local weather (which should trigger new API call if needed)
            await weatherViewModel.getLocalWeather();
          },
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
