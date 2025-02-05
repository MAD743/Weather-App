import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      home: TabsDemo(changeTheme: changeTheme),
    );
  }
}

class TabsDemo extends StatefulWidget {
  final Function(ThemeMode) changeTheme;

  const TabsDemo({super.key, required this.changeTheme});

  @override
  _TabsDemoState createState() => _TabsDemoState();
}

class _TabsDemoState extends State<TabsDemo>
    with SingleTickerProviderStateMixin, RestorationMixin {
  late TabController _tabController;
  final RestorableInt tabIndex = RestorableInt(0);
  final TextEditingController _cityController = TextEditingController();
  String city = "Enter city";
  String temperature = "--";
  String description = "--";
  final Random _random = Random();
  List<Map<String, String>> weeklyForecast = [];

  void fetchWeather() {
    setState(() {
      city = _cityController.text.isNotEmpty
          ? _cityController.text
          : "Unknown City";
      temperature = "${15 + _random.nextInt(16)}°C";
      List<String> conditions = ["Sunny", "Cloudy", "Rainy"];
      description = conditions[_random.nextInt(conditions.length)];
    });
  }

  void fetchWeeklyForecast() {
    setState(() {
      weeklyForecast = List.generate(7, (index) {
        return {
          "day": "Day ${index + 1}",
          "temperature": "${15 + _random.nextInt(16)}°C",
          "condition": ["Sunny", "Cloudy", "Rainy"][_random.nextInt(3)],
        };
      });
    });
  }

  @override
  String get restorationId => 'tabs_demo';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(tabIndex, 'tab_index');
    _tabController.index = tabIndex.value;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      initialIndex: 0,
      length: 3, // Initial three tabs, can expand later
      vsync: this,
    );
    _tabController.addListener(() {
      setState(() {
        tabIndex.value = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    tabIndex.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = ['Current Weather', '7-Day Forecast', 'Settings'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [for (final tab in tabs) Tab(text: tab)],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Current Weather Tab
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Enter City",
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: fetchWeather,
                  child: const Text("Fetch Weather"),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text("City: $city",
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text("Temperature: $temperature",
                            style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 10),
                        Text("Condition: $description",
                            style: const TextStyle(fontSize: 18)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 7-Day Forecast Tab
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: fetchWeeklyForecast,
                  child: const Text("Fetch 7-Day Forecast"),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: weeklyForecast.length,
                    itemBuilder: (context, index) {
                      final dayForecast = weeklyForecast[index];
                      return ListTile(
                        title: Text(dayForecast["day"]!),
                        subtitle: Text(
                            "Temp: ${dayForecast["temperature"]!}, ${dayForecast["condition"]!}"),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Settings Tab Placeholder
          Center(
            child: FloatingActionButton(
              onPressed: () => widget.changeTheme(
                Theme.of(context).brightness == Brightness.dark
                    ? ThemeMode.light
                    : ThemeMode.dark,
              ),
              child: const Icon(Icons.brightness_6),
            ),
          ),
        ],
      ),
    );
  }
}
