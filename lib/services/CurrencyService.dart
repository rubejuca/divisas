import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  static const String _apiKey = 'b4c4a39240a86e12ca2db066';
  static const String _baseUrl =
      'https://v6.exchangerate-api.com/v6/$_apiKey/latest/COP';

  static Future<Map<String, double>> getRates(List<String> symbols) async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final allRates = Map<String, dynamic>.from(data['conversion_rates']);
      final filtered = {
        for (var symbol in symbols)
          symbol:
              (allRates[symbol] is num)
                  ? (allRates[symbol] as num).toDouble()
                  : 0.0,
      };

      return filtered;
    } else {
      throw Exception('Error fetching exchange rates');
    }
  }
}
