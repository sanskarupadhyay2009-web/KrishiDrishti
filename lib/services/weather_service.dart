// lib/services/weather_service.dart

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  final String _apiKey;

  WeatherService([String? apiKey])
      : _apiKey = apiKey?.isNotEmpty == true
            ? apiKey!
            : dotenv.get('OPENWEATHER_API_KEY', fallback: '');

  Future<Map<String, dynamic>> fetchCurrentWeather(double latitude, double longitude) async {
    if (_apiKey.isEmpty) {
      return {
        'temp': 30.2,
        'description': 'Partly Cloudy',
        'rain_prob': '20%',
      };
    }

    try {
      final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$_apiKey&units=metric',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        return {
          'temp': 30.2,
          'description': 'Partly Cloudy',
          'rain_prob': '20%',
        };
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final temp = (body['main']?['temp'] ?? 30.2).toDouble();
      final description = (body['weather'] is List && body['weather'].isNotEmpty)
          ? body['weather'][0]['description'] as String? ?? 'Partly Cloudy'
          : 'Partly Cloudy';
      return {
        'temp': temp,
        'description': description,
        'rain_prob': '20%',
      };
    } catch (_) {
      return {
        'temp': 30.2,
        'description': 'Partly Cloudy',
        'rain_prob': '20%',
      };
    }
  }
}
