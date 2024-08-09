import 'package:flutter/material.dart';
import 'package:expensetracker/other/datastorage.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TransactionsPage extends StatefulWidget {
  final String emailPhone;

  const TransactionsPage({super.key, required this.emailPhone});

  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  List<Map<String, dynamic>> _transactions = [];
  Map<String, dynamic>? _latestExpense;
  String _lastProcessedExpenseDate = '';

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _loadLatestExpense();
  }

  Future<void> _loadTransactions() async {
  try {
    final user = await UserDataStorage.getUser(widget.emailPhone);
    if (user != null) {
      setState(() {
        _transactions = List<Map<String, dynamic>>.from(user['transactions'] ?? []);
      });
      await _saveTransactionsToSharedPreferences(_transactions);
      print('Loaded transactions in TransactionsPage: $_transactions');
    }
  } catch (e) {
    print('Error loading transactions: $e');
  }
}
  Future<void> _loadLatestExpense() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? latestExpenseJson = prefs.getString('latestExpense');
      if (latestExpenseJson != null) {
        Map<String, dynamic> latestExpense = json.decode(latestExpenseJson);

        // Check if this expense has already been processed
        if (latestExpense['currentDate'] != _lastProcessedExpenseDate) {
          setState(() {
            _latestExpense = latestExpense;
          });
          print('Loaded latest expense: $_latestExpense');

          // Automatically add the expense
          //await _addTransaction('Expense', latestExpense['amount'],
              //isExpense: true);

          // Update the last processed expense date
          _lastProcessedExpenseDate = latestExpense['currentDate'];
          await prefs.setString(
              'lastProcessedExpenseDate', _lastProcessedExpenseDate);
        }
      }
    } catch (e) {
      print('Error loading latest expense: $e');
    }
  }

  Future<void> _saveTransactionsToSharedPreferences(
      List<Map<String, dynamic>> transactions) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('transactions', json.encode(transactions));
      print('Saved transactions to SharedPreferences: $transactions');
    } catch (e) {
      print('Error saving transactions to SharedPreferences: $e');
    }
  }

  Future<void> _addTransaction(String type, double amount,
      {bool isExpense = false}) async {
    try {
      final newTransaction = {
        'type': type,
        'amount': amount,
        'date': DateTime.now().toIso8601String(),
        'isExpense': isExpense,
      };

      setState(() {
        _transactions.add(newTransaction);
      });

      await UserDataStorage.saveUserTransactions(widget.emailPhone,
          newTransaction: newTransaction);
      await _saveTransactionsToSharedPreferences(_transactions);

      print('Added new transaction: $newTransaction');
    } catch (e) {
      print('Error adding transaction: $e');
    }
  }

  @override
  @override
Widget build(BuildContext context) {
  final reversedTransactions = _transactions.reversed.toList();

  return Scaffold(
   appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF87dcfb),Color(0xFF87dcfb)], // Gradient colors
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            title: Text('Transaction History'),
            backgroundColor: Colors.transparent, // Make background transparent to show gradient
            elevation: 0, // Remove shadow for cleaner look
            foregroundColor: Colors.black,
          ),
        ),
      ),
    body: Column(
      children: [
        // Latest Expense Box
        /*if (_latestExpense != null)
          Container(
            padding: EdgeInsets.all(16.0),
            margin: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Latest Expense (Automatically Added)',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Amount: ₹${_latestExpense!['amount'].toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                Text(
                  'Date: ${_latestExpense!['date']}',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                Text(
                  'Date & Time (With Seconds): ${_latestExpense!['currentDate']}',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
            ),
          ),*/
        Expanded(
          child: reversedTransactions.isEmpty
              ? Center(
                  child: Text(
                    'No transactions found',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: reversedTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = reversedTransactions[index];
                    final DateTime transactionDateTime =
                        DateTime.parse(transaction['date']);
                    final String formattedDateTime =
                        DateFormat('yyyy-MM-dd – kk:mm:ss')
                            .format(transactionDateTime);

                    final bool isExpense = transaction['isExpense'] ?? false;
                    final Color tileColor = isExpense
                        ? Colors.red[200]!
                        : Colors.green[200]!;
                    final String transactionType = isExpense ? 'Expense' : 'Income';

                    return ListTile(
                      title: Text(
                        '$transactionType - ₹${transaction['amount'].toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Category: ${transaction['type']}',
                            style: TextStyle(color: Colors.black54),
                          ),
                          Text(
                            'Date: $formattedDateTime',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                      tileColor: tileColor,
                    );
                  },
                ),
        ),
        // Comment out or remove this Padding widget to hide the buttons
        // Padding(
        //   padding: const EdgeInsets.all(16.0),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       ElevatedButton(
        //         onPressed: () => _showAddTransactionDialog('Income'),
        //         child: Text('Add Income'),
        //         style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        //       ),
        //       ElevatedButton(
        //         onPressed: () => _showAddTransactionDialog('Expense'),
        //         child: Text('Add Expense'),
        //         style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    ),
    backgroundColor: Colors.white,
  );
}


  void _showAddTransactionDialog(String type) {
    TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add $type'),
          content: TextField(
            controller: amountController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: 'Amount'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                if (amountController.text.isNotEmpty) {
                  double amount = double.parse(amountController.text);
                  _addTransaction(type, amount, isExpense: type == 'Expense');
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}