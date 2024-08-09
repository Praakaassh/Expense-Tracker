import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewGoalsPage extends StatefulWidget {
  final double cashBalance;

  const ViewGoalsPage({Key? key, required this.cashBalance}) : super(key: key);

  @override
  _ViewGoalsPageState createState() => _ViewGoalsPageState();
}

class _ViewGoalsPageState extends State<ViewGoalsPage> {
  List<String> goals = [];

  final Map<String, IconData> _categoryIcons = {
    'Vehicle': Icons.directions_car,
    'House': Icons.house,
    'Vacation': Icons.beach_access,
    'Education': Icons.school,
    'Health Care': Icons.health_and_safety,
    'Electronics': Icons.electrical_services,
    'Emergency Fund': Icons.alarm,
    'None': Icons.help_outline,
  };

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  void _loadGoals() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? loadedGoals = prefs.getStringList('goals');
    print('Loaded Goals: $loadedGoals'); // Debug print
    setState(() {
      goals = (loadedGoals ?? []).reversed.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cashBalance = widget.cashBalance;

    return Scaffold(
      backgroundColor: Colors.white,
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
              'View Goals',
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: goals.isEmpty
            ? Center(
                child: Text(
                  'No goals available',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              )
            : ListView.builder(
                itemCount: goals.length,
                itemBuilder: (context, index) {
                  final goal = goals[index];
                  final parts = goal.split(' - ');
                  final amountStr = parts[0];
                  final category = parts.length > 1 ? parts[1] : 'None';
                  final goalAmount = double.tryParse(
                          amountStr.replaceAll('₹', '').trim()) ??
                      0;

                  final progress = cashBalance / goalAmount;

                  final progressColor =
                      progress >= 1.0 ? Colors.green : Colors.blue;
                  final showTick = progress >= 1.0;

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 255, 255, 255),
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  _categoryIcons[category] ?? Icons.help_outline,
                                  color: Colors.black,
                                  size: 24,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(
                              '₹$amountStr',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black),
                            ),
                            SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: progress.clamp(0.0, 1.0),
                              backgroundColor: Colors.grey[300],
                              color: progressColor,
                            ),
                            SizedBox(height: 8),
                            Text(
                              '₹${cashBalance.toStringAsFixed(2)} / ₹${goalAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black),
                            ),
                          ],
                        ),
                        if (showTick)
                          Positioned(
                            right: 12.0,
                            bottom: 50.0,
                            child: CircleAvatar(
                              backgroundColor: Colors.green,
                              radius: 12.0,
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16.0,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
