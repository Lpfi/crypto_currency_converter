import 'package:crypto_swap_flutter/const/items.dart';
import 'package:crypto_swap_flutter/model/userwallet_model.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crypto_swap_flutter/controller/currency_controller.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CurrencyScreenState createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  final controller = Get.put(CurrencyController());
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();
  late Map<String, num> conversionRate;
  String? fromdropdownValue;
  String? todropdownValue;
  String? imgSelected;
  String? imgSelected2;
  int? fromselectedindex;
  int? toselectedindex;
  String? nameSelected;
  String? codeSelected;
  double? availableSelected;
  double? savevalue = 0;
  double? total = 0;
  bool isnotselect = true;
  bool _isButtonDisabled = true;

  late List<Currency> currencies = [];

  @override
  void initState() {
    super.initState();
    loadData();
    imgSelected = "assets/images/${imglist.first}";
    imgSelected2 = "assets/images/${imglist.first}";
    fromdropdownValue = fromlist.first;
    fromselectedindex = 0;
    todropdownValue = tolist.first;
    toselectedindex = 0;
    fromdropdownUpdate(fromdropdownValue);
    todropdownUpdate(todropdownValue);
  }

  showAlertDialog(BuildContext context) {
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Confirm"),
      onPressed: () async {
        Navigator.of(context).pop();
        await senddata();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Convert to $todropdownValue ?"),
      content: Row(
        children: [
          Text(
              "From : $fromdropdownValue \n${availableSelected!.toStringAsFixed(6)} -> ${(availableSelected! - savevalue!).toStringAsFixed(6)}\nTo : $todropdownValue \n${total!.toStringAsFixed(6)} -> ${(total! + savevalue!).toStringAsFixed(6)} \nRate: 1 $fromdropdownValue / ${conversionRate[todropdownValue]} $todropdownValue"),
        ],
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  senddata() {
    double? newavailable = total! + currencies[toselectedindex!].available;
    double? newfromavailable = currencies[fromselectedindex!].available - savevalue!;
    setState(() {
      controller.updateCryptoCurrency(todropdownValue!, newavailable);
      controller.updateCryptoCurrency(fromdropdownValue!, newfromavailable);
    });
    availableSelected = currencies[fromselectedindex!].available - savevalue!;
    currencies[toselectedindex!].available = newavailable;
  }

  loadData() {
    setState(() {
      currencies.addAll(controller.mywallet);
    });
  }

  calculateCovertion(double value) {
    setState(() {
      num? convertRate = conversionRate[todropdownValue];

      if (availableSelected != 0 && todropdownValue != " - ") {
        savevalue = value;
        total = (value * convertRate!);
        if (savevalue! != 0 && savevalue! <= availableSelected! && fromdropdownValue != todropdownValue) {
          _isButtonDisabled = false;
        } else {
          _isButtonDisabled = true;
        }
      } else {
        _isButtonDisabled = true;
        total = 0.0;
      }
    });
  }

  swapDropdown() {
    String? tempvalue = "";
    int? tempindex = 0;
    tempvalue = fromdropdownValue;
    tempindex = fromselectedindex;
    fromdropdownValue = todropdownValue;
    fromselectedindex = toselectedindex;
    todropdownValue = tempvalue;
    toselectedindex = tempindex;
    tempvalue = "";
    tempindex = 0;
    setState(() {
      fromdropdownUpdate(fromdropdownValue);
      todropdownUpdate(todropdownValue);
      calculateCovertion(savevalue!);
    });
  }

  selectedUpdate(int imgindex, int index) async {
    loadData();
    setState(() {
      imgSelected = "assets/images/${imglist[imgindex]}";
      if (currencies.isNotEmpty) {
        nameSelected = currencies[index].cryptoName;
        conversionRate = currencies[index].conversionRate;
        availableSelected = currencies[index].available as double?;
      }
    });
  }

  toselectedUpdate(int index) async {
    setState(() {
      imgSelected2 = "assets/images/${imglist[index]}";
    });
  }

  fromdropdownUpdate(String? value) {
    setState(() {
      fromdropdownValue = value!;
      switch (fromdropdownValue) {
        case 'BTC':
          fromselectedindex = 0;
          selectedUpdate(1, fromselectedindex!);

          break;
        case 'BNB':
          fromselectedindex = 2;
          selectedUpdate(3, fromselectedindex!);

          break;
        case 'ETH':
          fromselectedindex = 1;
          selectedUpdate(2, fromselectedindex!);

          break;
        case ' - ':
          imgSelected = "assets/images/${imglist[0]}";
          fromdropdownValue = fromlist.first;

          break;
      }
    });
  }

  todropdownUpdate(String? value) {
    setState(() {
      todropdownValue = value!;
      switch (todropdownValue) {
        case 'BTC':
          toselectedindex = 0;
          toselectedUpdate(1);
          break;
        case 'BNB':
          toselectedindex = 2;
          toselectedUpdate(3);
          break;
        case 'ETH':
          toselectedindex = 1;
          toselectedUpdate(2);
          break;
        default:
          toselectedUpdate(0);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(225, 245, 245, 245),
      appBar: AppBar(
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20),
        iconTheme: const IconThemeData(color: Colors.black, size: 28),
        backgroundColor: Colors.white70,
        title: const Text('Swap'),
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.account_circle),
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Obx(() => Text(
                'Update in ${controller.countdown}s,  Please Wait...',
                style: const TextStyle(color: Colors.black26),
              )),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "From ",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  fromdropdownValue != ' - '
                      ? "Available:  $availableSelected ${nameSelected != ' - ' ? nameSelected : '-'}"
                      : "Select",
                  style: const TextStyle(color: Colors.black26),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: TextFormField(
                      controller: fromController,
                      style: const TextStyle(color: Colors.deepPurple, fontSize: 20),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: "0",
                        hintStyle: TextStyle(color: Colors.deepPurple, fontSize: 20),
                      ),
                      onChanged: (value) {
                        savevalue = double.parse(value);
                        calculateCovertion(savevalue!);
                      },
                    )),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.06,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: Colors.black12),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Image.asset(
                        imgSelected!,
                        width: 30,
                        height: 30,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      DropdownButton<String>(
                        value: fromdropdownValue,
                        onChanged: (String? value) {
                          fromdropdownUpdate(value);
                          calculateCovertion(savevalue!);
                        },
                        items: fromlist.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                width: 5,
              )
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                  ), //25
                  onPressed: () {
                    setState(() {
                      if (fromdropdownValue != ' - ') {
                        fromController.text = (availableSelected! * 0.25).toString();
                        calculateCovertion(double.parse(fromController.text));
                      }
                    });
                  },
                  child: const Text("25%")),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                  ), //50
                  onPressed: () {
                    setState(() {
                      if (fromdropdownValue != ' - ') {
                        fromController.text = (availableSelected! * 0.5).toString();
                        calculateCovertion(double.parse(fromController.text));
                      }
                    });
                  },
                  child: const Text("50%")),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                  ), //75
                  onPressed: () {
                    setState(() {
                      if (fromdropdownValue != ' - ') {
                        fromController.text = (availableSelected! * 0.75).toString();
                        calculateCovertion(double.parse(fromController.text));
                      }
                    });
                  },
                  child: const Text("75%")),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                  ), //100
                  onPressed: () {
                    setState(() {
                      if (fromdropdownValue != ' - ') {
                        fromController.text = availableSelected!.toString();
                        calculateCovertion(double.parse(fromController.text));
                      }
                    });
                  },
                  child: const Text("100%"))
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100), color: const Color.fromARGB(190, 187, 187, 187)),
            child: IconButton(
              color: Colors.deepPurple,
              iconSize: 40,
              onPressed: () {
                swapDropdown();
              },
              icon: const Icon(Icons.swap_vert),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "To",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                )
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: Text(
                    maxLines: 1,
                    total.toString(),
                    style: const TextStyle(color: Colors.deepPurple, fontSize: 20),
                  ),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.06,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: Colors.black12),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Image.asset(
                        imgSelected2!,
                        width: 30,
                        height: 30,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      DropdownButton<String>(
                        value: todropdownValue,
                        onChanged: (String? value) {
                          todropdownUpdate(value);
                          calculateCovertion(savevalue!);
                        },
                        items: tolist.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                width: 5,
              )
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              onPressed: _isButtonDisabled
                  ? null
                  : () {
                      showAlertDialog(context);
                    },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Swap",
                    style: TextStyle(fontSize: 20),
                  ),
                  Icon(
                    _isButtonDisabled ? Icons.cancel_outlined : Icons.check,
                    size: 30,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
