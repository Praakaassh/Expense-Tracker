import 'package:expensetracker/Pages/budgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expensetracker/other/datastorage.dart';

class ViewBudgetsPage extends StatefulWidget {
  final String emailPhone;

  ViewBudgetsPage({Key? key, required this.emailPhone}) : super(key: key) {
    print("ViewBudgetsPage created with emailPhone: $emailPhone");
  }

  @override
  _ViewBudgetsPageState createState() => _ViewBudgetsPageState();
}

class _ViewBudgetsPageState extends State<ViewBudgetsPage> {
  List<Map<String, dynamic>> _budgets = [];
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBudgetData();
  }

  void _printTransactionDetails() {
    print("All Transactions:");
    for (var transaction in _transactions) {
      print("Date: ${transaction['date']}, Type: ${transaction['type']}, Amount: ${transaction['amount']}, IsExpense: ${transaction['isExpense']}");
    }
  }

  Future<void> _loadBudgetData() async {
    setState(() => _isLoading = true);
    try {
      print("Loading user data for email/phone: ${widget.emailPhone}");
      final userData = await UserDataStorage.getUser(widget.emailPhone);
      if (userData != null) {
        print("User data loaded: $userData");
        print("Loaded budgets:");
        for (var budget in _budgets) {
          print("  Name: ${budget['name']}, Amount: ${budget['amount']}, Created: ${budget['createdDate']}");
        }

        print("\nLoaded transactions:");
        for (var transaction in _transactions) {
          print("  Type: ${transaction['type']}, Amount: ${transaction['amount']}, Date: ${transaction['date']}, IsExpense: ${transaction['isExpense']}");
        }
        setState(() {
          _budgets = List<Map<String, dynamic>>.from(userData['budgets'] ?? []);
          _transactions = List<Map<String, dynamic>>.from(userData['transactions'] ?? []);
          _isLoading = false;
        });
        _printTransactionDetails();
        print("All loaded transactions: $_transactions");
        print("Budgets loaded: $_budgets");
        print("Transactions loaded: $_transactions");
      } else {
        print("User data is null");
        throw Exception('User not found');
      }
    } catch (e) {
      print('Error loading budget data: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load budgets. Please try again.')),
      );
    }
  }

  double _calculateTotalSpent(String budgetName, DateTime creationDate) {
    print("\nCalculating total spent for budget: $budgetName, created on: $creationDate");
    double total = 0.0;
    int matchingTransactions = 0;
    
    for (var transaction in _transactions) {
      print("\nProcessing transaction:");
      print("  Type: ${transaction['type']}");
      print("  Amount: ${transaction['amount']}");
      print("  Date: ${transaction['date']}");
      print("  Is Expense: ${transaction['isExpense']}");
      
      DateTime transactionDate = DateTime.parse(transaction['date']);
      bool isAfterCreation = transactionDate.isAfter(creationDate) || transactionDate.isAtSameMomentAs(creationDate);
      bool matchesCategory = _categoryMatches(transaction['type'], budgetName);
      bool isExpense = transaction['isExpense'] == true;
      
      print("  After creation date: $isAfterCreation");
      print("  Matches category: $matchesCategory");
      print("  Is Expense: $isExpense");
      
      if (isExpense && isAfterCreation && matchesCategory) {
        double amount = (transaction['amount'] as num).toDouble();
        total += amount;
        matchingTransactions++;
        print("  MATCH - Amount added: $amount, New total: $total");
      } else {
        print("  NOT MATCHING because:");
        if (!isExpense) print("    - Not an expense");
        if (!isAfterCreation) print("    - Before budget creation date");
        if (!matchesCategory) print("    - Category doesn't match budget name");
      }
    }
    
    print("Total spent for $budgetName: $total (from $matchingTransactions matching transactions)");
    return total;
  }

  bool _categoryMatches(String transactionType, String budgetName) {
    String lowercaseType = transactionType.toLowerCase();
    String lowercaseBudget = budgetName.toLowerCase();
    
    bool exactMatch = lowercaseType == lowercaseBudget;
    bool partialMatch = lowercaseType.contains(lowercaseBudget) || lowercaseBudget.contains(lowercaseType);
    
    print("  Comparing transaction type '$transactionType' with budget name '$budgetName':");
    print("    Exact match: $exactMatch");
    print("    Partial match: $partialMatch");
    
    return exactMatch || partialMatch;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Budgets Overview'),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF87dcfb), Color(0xFF87dcfb)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _budgets.isEmpty
              ? Center(child: Text('No budgets available'))
              : ListView.builder(
                  itemCount: _budgets.length,
                  itemBuilder: (context, index) {
                    final budget = _budgets[index];
                    print("Processing budget: $budget");
                    final budgetAmount = budget['amount'] as double;
                    final creationDate = DateTime.parse(budget['createdDate']);
                    print("Processing budget: ${budget['name']}, Created on: $creationDate");
                    final totalSpent = _calculateTotalSpent(budget['name'], creationDate);
                    print("Total spent for ${budget['name']}: $totalSpent");
                    final progress = budgetAmount > 0 ? totalSpent / budgetAmount : 0.0;

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              budget['name'],
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text('Amount: ₹${budgetAmount.toStringAsFixed(2)}'),
                            Text('Period: ${budget['period']}'),
                            Text('Created On: ${DateFormat('yyyy-MM-dd').format(creationDate)}'),
                            Text('Total Spent: ₹${totalSpent.toStringAsFixed(2)}'),
                            SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                progress > 1 ? Colors.red : Colors.green,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${(progress * 100).toStringAsFixed(2)}%',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: progress > 1 ? Colors.red : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}