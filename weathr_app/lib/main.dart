import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(WeatherApp());

class WeatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.deepPurple[900],
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.deepPurple[400],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          labelStyle: TextStyle(color: Colors.white),
        ),
      ),
      home: WeatherHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WeatherHome extends StatefulWidget {
  @override
  _WeatherHomeState createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> {
  final _cityController = TextEditingController();
  String _selectedUnit = 'metric'; // default: Celsius
  String? _temperature;
  String? _description;
  String? _iconUrl;
  String? _error;

  final Map<String, String> _unitSymbols = {
    'metric': '°C',
    'imperial': '°F',
    'standard': 'K',
  };

  void _fetchWeather() async {
    final city = _cityController.text.trim();
    if (city.isEmpty) return;

    try {
      final data = await WeatherService.getWeather(city, _selectedUnit);
      setState(() {
        _temperature = '${data['temp']}${_unitSymbols[_selectedUnit]}';
        _description = data['description'];
        _iconUrl = data['iconUrl'];
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Could not fetch weather.';
        _temperature = null;
        _description = null;
        _iconUrl = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('☁️ Weather App'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _cityController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Enter city name',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search, color: Colors.white),
                  onPressed: _fetchWeather,
                ),
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text('Unit:', style: TextStyle(color: Colors.white)),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: _selectedUnit,
                  dropdownColor: Colors.deepPurple[400],
                  style: TextStyle(color: Colors.white),
                  items: [
                    DropdownMenuItem(
                      value: 'metric',
                      child: Text('Celsius'),
                    ),
                    DropdownMenuItem(
                      value: 'imperial',
                      child: Text('Fahrenheit'),
                    ),
                    DropdownMenuItem(
                      value: 'standard',
                      child: Text('Kelvin'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedUnit = value!;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 30),
            if (_temperature != null && _description != null && _iconUrl != null)
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                color: Colors.deepPurple[300],
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Image.network(_iconUrl!, width: 100),
                      SizedBox(height: 10),
                      Text(
                        _temperature!,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _description!.toUpperCase(),
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  _error!,
                  style: TextStyle(color: Colors.redAccent, fontSize: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class WeatherService {
  static const _apiKey = '331edb107ed6705f437040a5ac6450c9';
  static const _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  static Future<Map<String, dynamic>> getWeather(String city, String unit) async {
    final url = Uri.parse('$_baseUrl?q=$city&appid=$_apiKey&units=$unit');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'temp': data['main']['temp'].toString(),
        'description': data['weather'][0]['description'],
        'iconUrl': 'https://openweathermap.org/img/wn/${data['weather'][0]['icon']}@2x.png',
      };
    } else {
      throw Exception('Failed to fetch weather');
    }
  }
}
