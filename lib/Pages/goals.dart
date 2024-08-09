import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoalsPage extends StatefulWidget {
  @override
  _GoalsPageState createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final TextEditingController _goalAmountController = TextEditingController();
  String _category = 'None'; // Default category
  final List<String> _categories = [
    'Vehicle',
    'House',
    'Vacation',
    'Education',
    'Health Care',
    'Electronics',
    'Emergency Fund',
    'Custom' // Option to create a custom category
  ];

  final Map<String, IconData> _categoryIcons = {
    'Vehicle': Icons.directions_car,
    'House': Icons.home,
    'Vacation': Icons.beach_access,
    'Education': Icons.school,
    'Health Care': Icons.health_and_safety,
    'Electronics': Icons.devices,
    'Emergency Fund': Icons.alarm,
    'Custom': Icons.add_circle_outline,
  };

  void _showCategoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          color: Colors.white, // Set background color to white
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _categories.map((String category) {
                return ListTile(
                  leading: CircleAvatar(
                    child: Icon(_categoryIcons[category], color: Colors.white),
                    backgroundColor: Colors.blue,
                  ),
                  title: Text(category),
                  onTap: () {
                    if (category == 'Custom') {
                      _showCustomCategoryDialog();
                    } else {
                      setState(() {
                        _category = category;
                      });
                      Navigator.pop(context); // Close the bottom sheet
                    }
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _showCustomCategoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController _customCategoryController =
            TextEditingController();
        return AlertDialog(
          title: Text('Create Custom Category'),
          content: TextField(
            controller: _customCategoryController,
            decoration: InputDecoration(
              hintText: 'Enter custom category name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_customCategoryController.text.isNotEmpty) {
                  setState(() {
                    _category = _customCategoryController.text;
                  });
                  Navigator.pop(context); // Close the dialog
                  Navigator.pop(context); // Close the bottom sheet
                }
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _createGoal() async {
    String goalAmount = _goalAmountController.text;
    if (goalAmount.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> goals = prefs.getStringList('goals') ?? [];
      String newGoal = '$goalAmount - $_category';
      goals.add(newGoal);
      await prefs.setStringList('goals', goals);

      print('Saved Goals: $goals'); // Debug print

      Navigator.pop(context); // Navigate back to BudgetsGoalsTab
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a goal amount.')),
      );
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
            title: Text(
              'New Goal',
              style: TextStyle(color: Colors.black),
            ),
          
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: Container(
        color: Colors.white, // Set body background color to white
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'What are you saving for?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Amount',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _goalAmountController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter goal amount',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            Text(
              'Category: $_category',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _showCategoryBottomSheet,
              child: Text('Select Category'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _createGoal,
              child: Text('Create Goal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(
                    255, 244, 244, 244), // Set background color of the button
                foregroundColor: Colors.blue, // Set text color of the button
                elevation: 0, // Optionally remove button shadow
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(8.0), // Optional button shape
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
