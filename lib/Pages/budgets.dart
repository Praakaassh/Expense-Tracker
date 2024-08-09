import 'package:flutter/material.dart';
import 'package:expensetracker/other/datastorage.dart';

class BudgetsPage extends StatefulWidget {
  final String emailPhone;

  const BudgetsPage({Key? key, required this.emailPhone}) : super(key: key);

  @override
  _BudgetsPageState createState() => _BudgetsPageState();
}

class _BudgetsPageState extends State<BudgetsPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _customCategoryController = TextEditingController();
  String _selectedPeriod = 'Monthly';

  final List<String> _categories = [
    'Food & Drinks',
    'Transport',
    'Entertainment',
    'Investment',
    'Shopping',
    'Housing',
    'Vehicle',
    'Communication',
    'Electricity',
    'Custom',
  ];

  String _selectedCategory = 'Food & Drinks';
  bool _isCustomCategory = false;

  Future<void> _saveBudget() async {
    if (_formKey.currentState!.validate()) {
      try {
        String budgetName = _isCustomCategory ? _customCategoryController.text : _selectedCategory;
        Map<String, dynamic> newBudget = {
          'name': budgetName,
          'amount': double.parse(_amountController.text),
          'period': _selectedPeriod,
          'createdDate': DateTime.now().toIso8601String(),
        };

        print("Creating new budget: Name: ${newBudget['name']}, Amount: ${newBudget['amount']}, Date: ${newBudget['createdDate']}");

        await UserDataStorage.saveUserBudgets(widget.emailPhone, [newBudget]);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Budget saved successfully')),
        );

        Navigator.pop(context, true);
      } catch (e) {
        print('Error saving budget: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save budget. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF87dcfb), Color(0xFF87dcfb).withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            title: Text('Add Budget'),
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  fillColor: Colors.white,
                  filled: true,
                ),
                items: _categories.map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                    _isCustomCategory = value == 'Custom';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              if (_isCustomCategory) ...[
                SizedBox(height: 16),
                TextFormField(
                  controller: _customCategoryController,
                  decoration: InputDecoration(
                    labelText: 'Custom Category Name',
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a custom category name';
                    }
                    return null;
                  },
                ),
              ],
              SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  fillColor: Colors.white,
                  filled: true,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedPeriod,
                decoration: InputDecoration(
                  labelText: 'Period',
                  fillColor: Colors.white,
                  filled: true,
                ),
                items: ['Daily', 'Weekly', 'Monthly', 'Yearly']
                    .map((period) => DropdownMenuItem(
                          value: period,
                          child: Text(period),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPeriod = value!;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveBudget,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 246, 246, 246),
                  foregroundColor: Colors.blue,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text('Save Budget'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}