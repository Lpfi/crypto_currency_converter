import 'package:crypto_swap_flutter/const/api.dart';
import 'package:crypto_swap_flutter/model/userwallet_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class CurrencyController extends GetxController {
  final mywallet = <Currency>[].obs;
  final countdown = 10.obs;
  final isLoading = true.obs;

  late Timer _timer;

  @override
  void onInit() {
    super.onInit();
    fetchCurrencies();
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      countdown.value--;
      if (countdown.value == 0) {
        countdown.value = 10;
        fetchCurrencies();
      }
    });
  }

  Future<void> updateCryptoCurrency(String cryptoName, double newAvailable) async {
    final response = await http.get(Uri.parse(api));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> currencies = data['urwallet'];
      final int index = currencies.indexWhere((currency) => currency['cryptoName'] == cryptoName);
      if (index >= 0) {
        currencies[index]['available'] = newAvailable;
        final updatedData = {'urwallet': currencies};
        final putResponse = await http.put(Uri.parse(api),
            headers: {'Content-Type': 'application/json'}, body: json.encode(updatedData));
        if (putResponse.statusCode == 200) {
          // print('Data updated successfully');
        } else {
          throw Exception('Failed to update data');
        }
      } else {
        throw Exception('Currency not found');
      }
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  Future<void> fetchCurrencies() async {
    try {
      isLoading.value = true;
      final response = await http.get(Uri.parse(api));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<Currency> loadedCurrencies = [];
        data['urwallet'].forEach((currency) {
          loadedCurrencies.add(Currency.fromJson(currency));
        });
        mywallet.value = loadedCurrencies;
      } else {
        throw Exception('Failed to fetch currencies');
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    super.onClose();
    _timer.cancel();
  }
}
