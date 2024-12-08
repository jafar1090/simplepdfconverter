import 'package:flutter/material.dart';

void main() => runApp(CalculatorApp());

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final TextEditingController _controller = TextEditingController();
  String _currentInput = '';
  String _operator = '';
  double? _firstNumber;

  // Function to handle number button presses
  void _onNumberPressed(String number) {
    setState(() {
      _currentInput += number; // Add the number to the input
      _controller.text = _currentInput; // Update the display
    });
  }

  // Function to handle operator button presses
  void _onOperatorPressed(String operator) {
    if (_currentInput.isEmpty) return;
    setState(() {
      _firstNumber = double.tryParse(_currentInput); // Save the first number
      _currentInput = ''; // Clear the input for the second number
      _operator = operator; // Save the operator

    });
  }

  // Function to calculate the result
  void _onEqualsPressed() {
    if (_firstNumber == null || _currentInput.isEmpty || _operator.isEmpty) return;

    double secondNumber = double.tryParse(_currentInput) ?? 0;
    double result = 0;

    // Perform the calculation
    if (_operator == '+') result = _firstNumber! + secondNumber;
    if (_operator == '-') result = _firstNumber! - secondNumber;
    if (_operator == '*') result = _firstNumber! * secondNumber;
    if (_operator == '/' && secondNumber != 0) result = _firstNumber! / secondNumber;

    // Update the display with the result
    setState(() {
      _controller.text = result.toString();
      _currentInput = ''; // Reset for the next calculation
      _operator = '';
      _firstNumber = null;

    });
  }

  // Function to clear everything
  void _onClearPressed() {
    setState(() {
      _controller.clear(); // Clear the display
      _currentInput = ''; // Reset the input
      _operator = ''; // Reset the operator
      _firstNumber = null; // Reset the first number
    });
  }

  // Function to build buttons
  Widget _buildButton(String text, VoidCallback onPressed) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(text, style: TextStyle(fontSize: 24)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Simple Calculator')),
      body: Column(
        children: [
          TextField(
            controller: _controller,
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 32),
            readOnly: true, // User can't type directly
            decoration: InputDecoration(border: OutlineInputBorder()),
          ),
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    _buildButton('7', () => _onNumberPressed('7')),
                    _buildButton('8', () => _onNumberPressed('8')),
                    _buildButton('9', () => _onNumberPressed('9')),
                    _buildButton('/', () => _onOperatorPressed('/')),
                  ],
                ),
                Row(
                  children: [
                    _buildButton('4', () => _onNumberPressed('4')),
                    _buildButton('5', () => _onNumberPressed('5')),
                    _buildButton('6', () => _onNumberPressed('6')),
                    _buildButton('*', () => _onOperatorPressed('*')),
                  ],
                ),
                Row(
                  children: [
                    _buildButton('1', () => _onNumberPressed('1')),
                    _buildButton('2', () => _onNumberPressed('2')),
                    _buildButton('3', () => _onNumberPressed('3')),
                    _buildButton('-', () => _onOperatorPressed('-')),
                  ],
                ),
                Row(
                  children: [
                    _buildButton('0', () => _onNumberPressed('0')),
                    _buildButton('C', _onClearPressed),
                    _buildButton('=', _onEqualsPressed),
                    _buildButton('+', () => _onOperatorPressed('+')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
