import 'package:flutter/material.dart';
import 'package:expensetracker/Pages/budgets.dart';
import 'package:expensetracker/Pages/goals.dart';
import 'package:expensetracker/Pages/ViewBudgetsPage.dart';
import 'package:expensetracker/Pages/ViewGoalsPage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BudgetsGoalsTab extends StatefulWidget {
  final String emailPhone;
  final double cashBalance;

  const BudgetsGoalsTab({
    Key? key,
    required this.emailPhone,
    required this.cashBalance,
  }) : super(key: key);

  @override
  _BudgetsGoalsTabState createState() => _BudgetsGoalsTabState();
}

class _BudgetsGoalsTabState extends State<BudgetsGoalsTab> {
  List<dynamic> _budgetsList = [];

  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }

  Future<void> _loadBudgets() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? budgetsJson = prefs.getString('budgets');
    if (budgetsJson != null) {
      setState(() {
        _budgetsList = json.decode(budgetsJson);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Top half container for Budget
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Color(0xFFF1F1F1),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8.0),
                  bottomRight: Radius.circular(8.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 3,
                    child: Container(
                      padding: EdgeInsets.only(right: 16.0),
                      child: Image.asset(
                        'assets/images/budget.png',
                        fit: BoxFit.cover,

                        width: 300, // Adjust the width as needed
                        height: 300,
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 70),
Text(
  'Budget',
  style: GoogleFonts.gupter(
    fontSize: 24,
    color: Colors.black,
    fontWeight: FontWeight.bold,
  ),
),

                        SizedBox(height: 8),
                        Text(
                          '"Track your income and expenses to manage your finances effectively."',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BudgetsPage(
                                      emailPhone: widget.emailPhone,
                                    ),
                                  ),
                                ).then((result) {
                                  if (result != null) {
                                    setState(() {
                                      _budgetsList = result;
                                    });
                                  }
                                });
                              },
                              child: Text('Create'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8),
                          ElevatedButton(
  onPressed: () {
    print("Navigating to ViewBudgetsPage with emailPhone: ${widget.emailPhone}");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewBudgetsPage(
          emailPhone: widget.emailPhone,
        ),
      ),
    );
  },
  child: Text('View'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Color.fromARGB(255, 239, 65, 252),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          // Bottom half container for Goals
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Color(0xFFF1F1F1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 3,
                    child: Container(
                      padding: EdgeInsets.only(right: 16.0),
                      child: Image.asset(
                        'assets/images/goal.png',
                        fit: BoxFit.cover,
                        width: 300, // Adjust the width as needed
                        height: 300,
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 70),
                        Text(
                          'Goals',
                          style: GoogleFonts.gupter(
    fontSize: 24,
    color: Colors.black,
    fontWeight: FontWeight.bold,
  ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '"Set and track your financial goals to achieve them effectively."',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GoalsPage(),
                                  ),
                                );
                              },
                              child: Text('Create'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewGoalsPage(
                                      cashBalance: widget.cashBalance,
                                    ),
                                  ),
                                );
                              },
                              child: Text('View'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Color.fromARGB(255, 239, 65, 252),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}