import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class GraphPage extends StatefulWidget {
  final Map<String, double> expenses;
  double cashBalance;

  GraphPage({
    Key? key,
    required this.expenses,
    required this.cashBalance,
  }) : super(key: key);

  @override
  _GraphPageState createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  List<ExpenseData> _cashBalanceHistory = [];
  String _selectedChartType = 'Column';

  @override
  void initState() {
    super.initState();
    _loadCashBalanceHistory();
  }

  void _initializeCashBalanceHistory() {
    _cashBalanceHistory.add(ExpenseData(
      'Initial Balance',
      widget.cashBalance,
      DateTime.now(),
    ));
    _saveCashBalanceHistory();
  }

  void _updateCashBalance(double newBalance) {
    setState(() {
      widget.cashBalance = newBalance;
      _cashBalanceHistory.add(ExpenseData(
        'Updated Balance',
        newBalance,
        DateTime.now(),
      ));
      _saveCashBalanceHistory();
    });
  }

  Future<void> _saveCashBalanceHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonList = _cashBalanceHistory.map((data) => jsonEncode(data.toJson())).toList();
    await prefs.setStringList('cashBalanceHistory', jsonList);
  }

  Future<void> _loadCashBalanceHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? jsonList = prefs.getStringList('cashBalanceHistory');

    if (jsonList != null) {
      setState(() {
        _cashBalanceHistory = jsonList.map((item) => ExpenseData.fromJson(jsonDecode(item))).toList();
      });
    } else {
      _initializeCashBalanceHistory();
    }
  }

  void _onCashBalanceChanged(double newBalance) {
    _updateCashBalance(newBalance);
  }

  @override
  Widget build(BuildContext context) {
    // Automatically update the cash balance
    _onCashBalanceChanged(widget.cashBalance);

    return Scaffold(
      appBar: AppBar(
        title: Text('Graphs'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              value: _selectedChartType,
              items: <String>['Column', 'Line', 'Pie'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedChartType = newValue!;
                });
              },
            ),
            SizedBox(height: 16),
            Container(
              height: 250,
              child: _buildChart(),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshData,
              child: Text('Refresh Data'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    switch (_selectedChartType) {
      case 'Line':
        return _buildLineChart();
      case 'Pie':
        return _buildPieChart();
      default:
        return _buildColumnChart();
    }
  }

  Widget _buildColumnChart() {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(),
      series: <CartesianSeries>[
        ColumnSeries<ExpenseData, String>(
          dataSource: _getGraphData(),
          xValueMapper: (ExpenseData data, _) => data.category,
          yValueMapper: (ExpenseData data, _) => data.amount,
          color: Colors.blue,
          dataLabelSettings: DataLabelSettings(isVisible: true),
          enableTooltip: true,
        ),
      ],
    );
  }

  Widget _buildLineChart() {
    return SfCartesianChart(
      primaryXAxis: DateTimeAxis(
        intervalType: DateTimeIntervalType.months,
        dateFormat: DateFormat('MMM'),
      ),
      primaryYAxis: NumericAxis(),
      series: <CartesianSeries>[
        LineSeries<ExpenseData, DateTime>(
          dataSource: _cashBalanceHistory,
          xValueMapper: (ExpenseData data, _) => data.date,
          yValueMapper: (ExpenseData data, _) => data.amount,
          color: Colors.green,
          dataLabelSettings: DataLabelSettings(isVisible: true),
          enableTooltip: true,
        ),
      ],
    );
  }

  Widget _buildPieChart() {
    return SfCircularChart(
      legend: Legend(isVisible: true),
      series: <CircularSeries>[
        PieSeries<ExpenseData, String>(
          dataSource: _getGraphData(),
          xValueMapper: (ExpenseData data, _) => data.category,
          yValueMapper: (ExpenseData data, _) => data.amount,
          dataLabelSettings: DataLabelSettings(isVisible: true),
          enableTooltip: true,
        ),
      ],
    );
  }

  List<ExpenseData> _getGraphData() {
    return widget.expenses.entries.map((entry) {
      return ExpenseData(entry.key, entry.value, DateTime.now());
    }).toList();
  }

  void _refreshData() {
    // Reload or refresh the data as needed
    _loadCashBalanceHistory();
  }
}

class ExpenseData {
  final String category;
  final double amount;
  final DateTime date;

  ExpenseData(this.category, this.amount, this.date);

  Map<String, dynamic> toJson() => {
        'category': category,
        'amount': amount,
        'date': date.toIso8601String(),
      };

  factory ExpenseData.fromJson(Map<String, dynamic> json) {
    return ExpenseData(
      json['category'],
      json['amount'],
      DateTime.parse(json['date']),
    );
  }
}
