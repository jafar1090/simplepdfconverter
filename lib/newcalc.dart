import 'package:flutter/material.dart';

class newcc extends StatefulWidget {
  const newcc({super.key});

  @override
  State<newcc> createState() => _newccState();
}

class _newccState extends State<newcc> {
  final ScrollController _scrollController = ScrollController();
  List<String> numbers = [];

  String currentinput = '';
  String _operator = '';
  double? firstNumber;
  String newrisult = '';

  void onpressnumber(String number) {
    setState(() {
      currentinput += number;
      numbers.add(number);

      Future.delayed(Duration(microseconds: 100),(){
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });




    });
  }
  void onpressoperato(String operator) {
    if (currentinput.isEmpty) return;

    setState(() {
      firstNumber = double.tryParse(currentinput);
      _operator = operator;
      numbers.add(_operator);
      currentinput = '';
    });
  }

  void pressEqual() {
    if (currentinput.isEmpty || firstNumber == null || _operator.isEmpty)
      return;
    double secondnumber = double.tryParse(currentinput) ?? 0;
    double result = 0;

    if (_operator == "*") result = (firstNumber! * secondnumber);
    if (_operator == "+") result = (firstNumber! + secondnumber);
    if (_operator == "-") result = (firstNumber! - secondnumber);
    if (_operator == "/" && secondnumber != 0) {
      result = (firstNumber! / secondnumber);
    }

    setState(() {
      numbers.add("=");
      numbers.add(result.toString());
      firstNumber = null;
      currentinput = '';
      _operator = '';
    });
  }
  void clear(){

    setState(() {
      numbers.clear();
    });
  }

  Widget myButton(String text, VoidCallback onPress) {
    return Expanded(
        child: ElevatedButton(
            onPressed: onPress,
            child: Text(
              text,
              style: const TextStyle(fontSize: 24),
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Calculastor"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            height: 50,
          ),
          Expanded(
            child: ListView.builder(controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: numbers.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  child: Text(
                    numbers[index],
                    style: TextStyle(fontSize: 30),
                  ),
                );
              },
            ),
          ),
          Row(
            children: [
              myButton("1", () => onpressnumber('1')),
              myButton("2", () => onpressnumber('2')),
              myButton("3", () => onpressnumber('3')),
              myButton("4", () => onpressnumber('4')),
            ],
          ),
          Row(children: [
            myButton("5", () => onpressnumber('5')),
            myButton("6", () => onpressnumber('6')),
            myButton("7", () => onpressnumber('7')),
            myButton("8", () => onpressnumber('8')),
          ]),
          Row(
            children: [
              myButton("9", () => onpressnumber('9')),
              myButton("0", () => onpressnumber('0')),
              myButton("c", clear),
              myButton("=", pressEqual),
            ],
          ),
          Row(
            children: [
              myButton("*", () => onpressoperato('*')),
              myButton("-", () => onpressoperato('-')),
              myButton("+", () => onpressoperato('+')),
              myButton("/", () => onpressoperato('/')),
            ],
          ),
        ],
      ),
    );
  }
}
