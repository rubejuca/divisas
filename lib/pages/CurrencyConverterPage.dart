import 'package:divisaa/services/LanguageService.dart';
import 'package:flutter/material.dart';
import 'package:divisaa/services/ConnectivityService.dart';
import 'package:divisaa/services/CurrencyService.dart';
import '../main.dart';

class CurrencyConverterPage extends StatefulWidget {
  const CurrencyConverterPage({super.key});

  @override
  State<CurrencyConverterPage> createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends State<CurrencyConverterPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> currencies = ['USD', 'EUR', 'GBP'];
  Map<String, double> results = {};
  String language = 'es';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final lang = await LanguageService.getLanguage();
    setState(() {
      language = lang;
    });
  }

  Future<void> _convert() async {
    // Limpiar la entrada para asegurar el formato correcto
    final input = _controller.text.replaceAll(',', '').replaceAll(' ', '');
    final amount = double.tryParse(input);

    if (amount == null) {
      _showMessage(
        language == 'es'
            ? 'Por favor ingresa un número válido.'
            : 'Please enter a valid number.',
      );
      return;
    }

    final isConnected = await ConnectivityService.hasConnection();
    if (!isConnected) {
      setState(() {
        results = ConnectivityService.defaultRates.map(
          (key, rate) => MapEntry(key, amount * rate),
        );
      });
      _showMessage(
        language == 'es'
            ? 'Sin conexión. Se usó una tasa aproximada.'
            : 'No connection. An approximate rate was used.',
      );
      return;
    }

    try {
      final rates = await CurrencyService.getRates(currencies);

      setState(() {
        results = {
          for (var entry in rates.entries)
            entry.key: amount * entry.value, // directo desde COP
        };
      });
    } catch (_) {
      setState(() {
        results = ConnectivityService.defaultRates.map(
          (key, rate) => MapEntry(key, amount * rate),
        );
      });
      _showMessage(
        language == 'es'
            ? 'Error al consultar la API. Se usó una tasa aproximada.'
            : 'Error fetching rates. A default rate was used.',
      );
    }
  }

  Future<void> _changeLanguage(String lang) async {
    await LanguageService.setLanguage(lang); // Guardar en SharedPreferences
    setState(() {
      language = lang;
    });
    MyApp.setLocale(context, Locale(lang)); // Cambiar idioma en caliente
  }

  void _showMessage(String msg) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            content: Text(msg),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSpanish = language == 'es';
    return Scaffold(
      appBar: AppBar(
        title: Text(isSpanish ? 'Conversor de Divisas' : 'Currency Converter'),
        actions: [
          DropdownButton<String>(
            value: language,
            onChanged: (String? value) {
              if (value != null) {
                _changeLanguage(value);
              }
            },

            items: const [
              DropdownMenuItem(value: 'es', child: Text('ES')),
              DropdownMenuItem(value: 'en', child: Text('EN')),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: isSpanish ? 'Valor en COP' : 'Value in COP',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _convert,
              child: Text(isSpanish ? 'Convertir' : 'Convert'),
            ),
            const SizedBox(height: 20),
            ...results.entries.map(
              (e) => Text('${e.key}: ${e.value.toStringAsFixed(2)}'),
            ),
          ],
        ),
      ),
    );
  }
}
