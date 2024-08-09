import 'dart:async';
import 'dart:convert';
import 'package:expensetracker/Pages/ViewBudgetsPage.dart';
import 'package:expensetracker/Pages/settings.dart';
import 'package:flutter/material.dart';
import 'package:expensetracker/Pages/calculatorpage.dart';
import 'package:expensetracker/Pages/loginpage.dart';
import 'package:expensetracker/Pages/transactionpage.dart';
import 'package:expensetracker/other/datastorage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'accounts_tab.dart';
import 'budgets_goals_tab.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final String emailPhone;
  final int selectedIndex;

  const HomePage({Key? key, required this.emailPhone, this.selectedIndex = 0})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  double _cashBalance = 0.0;
  Map<String, double> _expenses = {};
  late TabController _tabController;
  final _latestTransactionController =
      StreamController<Map<String, dynamic>>.broadcast();
  Map<String, dynamic>? _latestExpense;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 2, vsync: this, initialIndex: widget.selectedIndex);
    _tabController.addListener(_handleTabChange);
    _loadData();
    _loadLatestExpense();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _latestTransactionController.close();
    super.dispose();
  }

  Future<void> _loadData() async {
    final user = await UserDataStorage.getUser(widget.emailPhone);
    if (user != null) {
      setState(() {
        _cashBalance = double.tryParse(user['cashBalance'] ?? '0') ?? 0.0;
        _expenses = _parseExpenses(user['expenses']);
      });
    }
  }

  Future<void> _loadLatestExpense() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? latestExpenseJson = prefs.getString('latestExpense');
    if (latestExpenseJson != null) {
      setState(() {
        _latestExpense = json.decode(latestExpenseJson);
      });
    }
  }

  Map<String, double> _parseExpenses(dynamic expenseData) {
    return expenseData != null ? Map<String, double>.from(expenseData) : {};
  }

  void _updateCashBalance(double newBalance) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('cashBalance', newBalance);
    setState(() {
      _cashBalance = newBalance;
    });
  }

  void _openCalculator() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CalculatorPage(
          onUpdateBalance: (amount, category, isExpense) {
            setState(() {
              _cashBalance += isExpense ? -amount : amount;
              _updateCashBalance(_cashBalance);

              if (isExpense) {
                _expenses[category] = (_expenses[category] ?? 0) + amount;
              }
            });

            final newTransaction = {
              'amount': amount,
              'type': category,
              'date': DateTime.now().toIso8601String(),
              'isExpense': isExpense,
            };

            _latestTransactionController.add(newTransaction);

            if (isExpense) {
              _latestExpense = newTransaction;
              SharedPreferences.getInstance().then((prefs) {
                prefs.setString('latestExpense', json.encode(newTransaction));
              });
            }

            UserDataStorage.saveUserBalance(widget.emailPhone,
                balance: _cashBalance.toString());
            UserDataStorage.saveUserTransactions(widget.emailPhone,
                newTransaction: newTransaction);
            UserDataStorage.saveUserExpenses(widget.emailPhone,
                expenses: _expenses);
          },
        ),
      ),
    );

    _loadData();
    _loadLatestExpense();
  }

  void _openTransactionsPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionsPage(emailPhone: widget.emailPhone),
      ),
    );

    _loadData();
    _loadLatestExpense();
  }

  void _openBudgetsPage() async {
    final user = await UserDataStorage.getUser(widget.emailPhone);
    final budgets = user?['budgets'] as List<dynamic>? ?? [];

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewBudgetsPage(
      
          emailPhone: widget.emailPhone,
        ),
      ),
    );

    if (result != null && result is int) {
      setState(() {
        _tabController.index = result;
      });

      _loadData();
      _loadLatestExpense();
    }
  }

  void _openAboutPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AboutPage(),
      ),
    );
  }

  void _handleTabChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.home, color: Colors.black),
            SizedBox(width: 8),
            Text(
              'Home',
              style: GoogleFonts.gupter(
                textStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
        backgroundColor: Color(0xFF87DCFB),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(Icons.menu, color: Color.fromARGB(255, 17, 0, 0)),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Accounts'),
            Tab(text: 'Budgets/Goals'),
          ],
          labelStyle: GoogleFonts.gupter(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          unselectedLabelStyle: GoogleFonts.gupter(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          labelColor: const Color.fromARGB(255, 2, 0, 0),
          unselectedLabelColor: const Color.fromARGB(255, 0, 0, 0),
        ),
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF87DCFB), Color.fromARGB(255, 239, 65, 252)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Row(
                  children: [
                    Icon(Icons.menu, color: Colors.black),
                    SizedBox(width: 8),
                    Text(
                      'Menu',
                      style: GoogleFonts.gupter(
                        textStyle: TextStyle(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontSize: 24,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.history, color: Colors.black),
                title: Text('Transactions', style: TextStyle(color: Colors.black)),
                onTap: _openTransactionsPage,
              ),
              ListTile(
                leading: Icon(Icons.settings, color: Colors.black),
                title: Text('Settings', style: TextStyle(color: Colors.black)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SettingsPage(emailPhone: widget.emailPhone),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.black),
                title: Text('Logout', style: TextStyle(color: Colors.black)),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.info, color: Colors.black),
                title: Text('About', style: TextStyle(color: Colors.black)),
                onTap: _openAboutPage,
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          AccountsTab(
            emailPhone: widget.emailPhone,
            cashBalance: _cashBalance,
            expenses: _expenses,
            latestTransactionStream: _latestTransactionController.stream,
            onLatestExpenseUpdate: (expense) {
              setState(() {
                _latestExpense = expense;
              });
            },
          ),
          BudgetsGoalsTab(
            emailPhone: widget.emailPhone,
            cashBalance: _cashBalance,
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: _openCalculator,
              child: Icon(Icons.add),
              backgroundColor: Colors.blue,
            )
          : null,
      backgroundColor: Colors.black,
    );
  }
}

// Define the AboutPage


class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF87DCFB),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF87DCFB), Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 
                         AppBar().preferredSize.height - 
                         MediaQuery.of(context).padding.top,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    Icon(
                      Icons.account_balance_wallet,
                      size: 100,
                      color: Colors.white,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Pana Petti',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 30),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Created by',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Prakash & Subin',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF87DCFB),
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              'A Flutter project designed to help you manage your expenses efficiently.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildFeatureItem(Icons.track_changes, 'Track Expenses'),
                                _buildFeatureItem(Icons.pie_chart, 'Visualize Data'),
                                _buildFeatureItem(Icons.savings, 'Set Budgets'),
                              ],
                            ),
                            Spacer(),
                            Text(
                              '© 2024 Expense Tracker. All rights reserved.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Color(0xFF87DCFB).withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 40,
            color: Color(0xFF87DCFB),
          ),
        ),
        SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
