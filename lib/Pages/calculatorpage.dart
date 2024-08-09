// CalculatorPage.dart

import 'package:flutter/material.dart';
import 'package:expressions/expressions.dart';
import 'package:expensetracker/Pages/categoriespage.dart';

class CalculatorPage extends StatefulWidget {
  final void Function(double, String, bool) onUpdateBalance;

  const CalculatorPage({Key? key, required this.onUpdateBalance})
      : super(key: key);

  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _displayText = '';
  String _result = '';

  void _onPressed(String text) {
    setState(() {
      _displayText += text;
    });
  }

  void _clear() {
    setState(() {
      _displayText = '';
      _result = '';
    });
  }

  void _calculate() {
    try {
      final result = _evaluateExpression(_displayText);
      setState(() {
        _result = result.toStringAsFixed(2);
      });
    } catch (e) {
      setState(() {
        _result = 'Error';
      });
    }
  }

  double _evaluateExpression(String expression) {
    final cleanedExpression = expression
        .replaceAll('x', '*')
        .replaceAll('÷', '/')
        .replaceAll(' ', '');

    try {
      final expressionParser = Expression.parse(cleanedExpression);
      final evaluator = const ExpressionEvaluator();
      final result = evaluator.eval(expressionParser, {});
      return result.toDouble();
    } catch (e) {
      throw Exception('Invalid expression');
    }
  }

  void _onIncome() {
  if (_result.isNotEmpty) {
    double amount = double.tryParse(_result) ?? 0;
    widget.onUpdateBalance(amount, 'Income', false);
    Navigator.pop(context);
  }
}

void _onExpense() async {
  if (_result.isNotEmpty) {
    double amount = double.tryParse(_result) ?? 0;
    String? category = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CategoriesPage()),
    );
    if (category != null) {
      widget.onUpdateBalance(amount, category, true);
      Navigator.pop(context);
    }
  }
}

  void _backspace() {
    setState(() {
      if (_displayText.isNotEmpty) {
        _displayText = _displayText.substring(0, _displayText.length - 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculator'),
        backgroundColor: Color(0xFF87dcfb),
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Container(
        color: Color(0xFFF1F1F1),
        child: Column(
          children: [
            SizedBox(height: 17),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _onIncome,
                    child: Text(
                      'Income',
                      style: TextStyle(fontSize: 20.0),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(30.0),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 5),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _onExpense,
                    child: Text(
                      'Expense',
                      style: TextStyle(fontSize: 20.0),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(30.0),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              _displayText,
                              style: TextStyle(color: Colors.black, fontSize: 28.0),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: 10),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              'INR $_result',
                              style: TextStyle(color: Colors.black, fontSize: 36.0),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    color: Color(0xFFF1F1F1),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _buildButton('7'),
                            _buildButton('8'),
                            _buildButton('9'),
                            _buildButton('÷'),
                          ],
                        ),
                        Row(
                          children: [
                            _buildButton('4'),
                            _buildButton('5'),
                            _buildButton('6'),
                            _buildButton('x'),
                          ],
                        ),
                        Row(
                          children: [
                            _buildButton('1'),
                            _buildButton('2'),
                            _buildButton('3'),
                            _buildButton('-'),
                          ],
                        ),
                        Row(
                          children: [
                            _buildButton('AC'),
                            _buildButton('0'),
                            _buildButton('+'),
                            _buildButton('<'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {
            if (text == 'AC') {
              _clear();
            } else if (text == '+') {
              _onPressed(text);
            } else if (text == '<') {
              _backspace();
            } else {
              _onPressed(text);
              if (text == '0' ||
                  text == '1' ||
                  text == '2' ||
                  text == '3' ||
                  text == '4' ||
                  text == '5' ||
                  text == '6' ||
                  text == '7' ||
                  text == '8' ||
                  text == '9') {
                _calculate();
              }
            }
          },
          child: text == '<'
              ? Icon(Icons.backspace, color: Colors.white)
              : Text(text, style: TextStyle(color: Colors.white, fontSize: 22.0)),
          style: ElevatedButton.styleFrom(
            shape: CircleBorder(),
            padding: EdgeInsets.all(16.0),
            backgroundColor: text == '<' ? Colors.orange : Colors.grey[800],
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}