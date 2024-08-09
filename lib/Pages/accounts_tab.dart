import 'dart:async';
import 'dart:convert';
import 'package:expensetracker/Pages/graphpage.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AccountsTab extends StatefulWidget {
  final String emailPhone;
  final double cashBalance;
  final Map<String, double> expenses;
  final Stream<Map<String, dynamic>> latestTransactionStream;
  final Function(Map<String, dynamic>) onLatestExpenseUpdate;

  const AccountsTab({
    Key? key,
    required this.emailPhone,
    required this.cashBalance,
    required this.expenses,
    required this.latestTransactionStream,
    required this.onLatestExpenseUpdate,
  }) : super(key: key);

  @override
  _AccountsTabState createState() => _AccountsTabState();
}

class _AccountsTabState extends State<AccountsTab> {
  List<ExpenseData> _cashBalanceHistory = [];
  Timer? _debounce;
  StreamController<List<ExpenseData>> _cashBalanceStreamController =
      StreamController<List<ExpenseData>>.broadcast();
  Map<String, dynamic>? _latestExpense;
  Map<String, dynamic>? _latestIncome;

  @override
  void initState() {
    super.initState();
    _loadCashBalanceHistory();
    _loadLatestTransactions();
    widget.latestTransactionStream.listen((transaction) {
      if (mounted) {
        _updateCashBalanceHistory(transaction);
        _updateLatestTransaction(transaction);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _cashBalanceStreamController.close();
    super.dispose();
  }

  Future<void> _loadCashBalanceHistory() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? jsonList = prefs.getStringList('cashBalanceHistory');

      if (jsonList != null && jsonList.isNotEmpty) {
        setState(() {
          _cashBalanceHistory = jsonList
              .map((item) => ExpenseData.fromJson(jsonDecode(item)))
              .where((data) => data != null)
              .toList();
          _cashBalanceStreamController.add(_cashBalanceHistory);
        });
      } else {
        _initializeCashBalanceHistory();
      }
    } catch (e) {
      print('Error loading cash balance history: $e');
      _initializeCashBalanceHistory();
    }
  }

  void _initializeCashBalanceHistory() {
    _cashBalanceHistory.add(ExpenseData(
      'Initial Balance',
      widget.cashBalance,
      DateTime.now(),
    ));
    _saveCashBalanceHistory();
    _cashBalanceStreamController.add(_cashBalanceHistory);
  }

  Future<void> _saveCashBalanceHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonList =
        _cashBalanceHistory.map((data) => jsonEncode(data.toJson())).toList();
    await prefs.setStringList('cashBalanceHistory', jsonList);
  }

  Future<void> _loadLatestTransactions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? latestExpenseJson = prefs.getString('latestExpense');
    String? latestIncomeJson = prefs.getString('latestIncome');
    
    if (latestExpenseJson != null) {
      _latestExpense = json.decode(latestExpenseJson);
    }
    
    if (latestIncomeJson != null) {
      _latestIncome = json.decode(latestIncomeJson);
    }

    setState(() {});
  }

  void _updateLatestTransaction(Map<String, dynamic> transaction) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    setState(() {
      if (transaction['isExpense']) {
        _latestExpense = transaction;
        prefs.setString('latestExpense', json.encode(transaction));
        widget.onLatestExpenseUpdate(transaction);
      } else {
        _latestIncome = transaction;
        prefs.setString('latestIncome', json.encode(transaction));
      }
    });
  }

  void _updateCashBalanceHistory(Map<String, dynamic> transaction) {
    double amount = transaction['amount'];
    bool isExpense = transaction['isExpense'];
    
    double newBalance = _cashBalanceHistory.isNotEmpty
        ? (isExpense 
            ? _cashBalanceHistory.last.amount - amount
            : _cashBalanceHistory.last.amount + amount)
        : (isExpense ? -amount : amount);

    _cashBalanceHistory.add(ExpenseData(
      isExpense ? 'Expense' : 'Income',
      newBalance,
      DateTime.now(),
    ));

    _saveCashBalanceHistory();
    _cashBalanceStreamController.add(_cashBalanceHistory);
  }

  @override
  Widget build(BuildContext context) {
    final totalExpense =
        widget.expenses.values.fold(0.0, (sum, amount) => sum + amount);

    String formatAmount(dynamic amount) {
      if (amount == null) return '0.00';
      if (amount is num) return amount.toStringAsFixed(2);
      if (amount is String) {
        try {
          return double.parse(amount).toStringAsFixed(2);
        } catch (e) {
          print('Error parsing amount: $amount');
        }
      }
      return '0.00';
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF87DCFB), const Color.fromARGB(255, 204, 123, 218), Colors.white, Colors.white],
          stops: [0.0, 0.5, 0.5, 1.0],
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Your Wallet',
                    style: GoogleFonts.gupter(
                      textStyle: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '₹',
                          style: TextStyle(fontSize: 70, color: Colors.black),
                        ),
                        TextSpan(
                          text: '${widget.cashBalance.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 60, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.0),
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              decoration: BoxDecoration(
                color: Color(0xFFF1F1F1),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 2.5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '     Latest Expense',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.arrow_downward,
                                color: Color.fromARGB(255, 180, 0, 0),
                                size: 40,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '₹',
                                          style: TextStyle(fontSize: 30, color: Colors.black),
                                        ),
                                        TextSpan(
                                          text: _latestExpense != null
                                              ? formatAmount(_latestExpense!['amount'])
                                              : '0.00',
                                          style: TextStyle(fontSize: 30, color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 2.5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
  Text(
    'Latest Income',
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
  ),
  SizedBox(height: 8),
  Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Expanded(
        child: Container(
          alignment: Alignment.centerRight,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '₹',
                    style: TextStyle(fontSize: 30, color: Colors.black),
                  ),
                  TextSpan(
                    text: _latestIncome != null
                        ? formatAmount(_latestIncome!['amount'])
                        : '0.00',
                    style: TextStyle(fontSize: 30, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      SizedBox(width: 8),
      Icon(
        Icons.arrow_upward,
        color: Color.fromARGB(255, 5, 138, 0),
        size: 40,
      ),
    ],
  ),
],
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            DefaultTabController(
              length: 2,
              child: Container(
                padding: EdgeInsets.all(16.0),
                margin: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Color(0xFFF1F1F1),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expense Structure',
                      style: GoogleFonts.gupter(
                        textStyle: TextStyle(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        constraints: BoxConstraints(maxWidth: 150),
                        child: TabBar(
                          tabs: [
                            Tab(icon: Icon(Icons.circle, color: Colors.blue, size: 5)),
                            Tab(icon: Icon(Icons.circle, color: Colors.blue, size: 5)),
                          ],
                          labelColor: const Color.fromARGB(255, 0, 0, 0),
                          unselectedLabelColor: Color(0xFFF1F1F1),
                          indicator: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue,
                          ),
                          indicatorSize: TabBarIndicatorSize.label,
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 0.0, right: 16.0),
                      child: Container(
                        height: MediaQuery.of(context).size.width * 0.6,
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: TabBarView(
                          children: [
                            _buildPieChart(totalExpense),
                            _buildColumnChart(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Container(
              margin: EdgeInsets.all(16.0),
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Color(0xFFF1F1F1),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Income And Expense Chart',
                    style: GoogleFonts.gupter(
                      textStyle: TextStyle(
                        color: const Color.fromARGB(255, 0, 0, 0),
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    height: 300,
                    color: Colors.white,
                    child: _buildLineChart(),
                  ),
                  SizedBox(height: 16),
                  Row(
                    // Empty row, you can add buttons or other widgets here if needed
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart() {
    return StreamBuilder<List<ExpenseData>>(
      stream: _cashBalanceStreamController.stream,
      initialData: _cashBalanceHistory,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        return SfCartesianChart(
          backgroundColor: const Color(0xFFF1F1F1),
          plotAreaBackgroundColor: Colors.transparent,
          primaryXAxis: DateTimeAxis(
            intervalType: DateTimeIntervalType.months,
            dateFormat: DateFormat('MMM'),
            labelStyle: TextStyle(color: Colors.black),
            majorGridLines: MajorGridLines(color: Colors.grey[300]),
            edgeLabelPlacement: EdgeLabelPlacement.shift,
          ),
          primaryYAxis: NumericAxis(
            labelStyle: TextStyle(color: Colors.black),
            majorGridLines: MajorGridLines(color: Colors.grey[300]),
            axisLine: AxisLine(width: 0),
          ),
          series: <CartesianSeries>[
           LineSeries<ExpenseData, DateTime>(
              dataSource: snapshot.data!,
              xValueMapper: (ExpenseData data, _) => data.date ?? DateTime.now(),
              yValueMapper: (ExpenseData data, _) => data.amount,
              color: Colors.blueAccent,
              dataLabelSettings: DataLabelSettings(
                isVisible: true,
                textStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                labelAlignment: ChartDataLabelAlignment.top,
                builder: (dynamic data, ChartPoint<dynamic> point, ChartSeries<dynamic, dynamic> series, int pointIndex, int seriesIndex) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    color: Colors.white,
                    child: Text('${data.amount}', style: TextStyle(color: Colors.black)),
                  );
                },
              ),
              enableTooltip: true,
              markerSettings: MarkerSettings(
                isVisible: true,
                shape: DataMarkerType.circle,
                borderWidth: 3,
                borderColor: Colors.blueAccent,
                color: Colors.white,
              ),
              width: 3,
              animationDuration: 1500,
            ),
          ],
        );
      },
    );
  }

  Widget _buildPieChart(double totalExpense) {
    final hasExpenses = widget.expenses.isNotEmpty;

    final categories = hasExpenses
        ? widget.expenses.entries.map((entry) {
            final categoryColor = _getCategoryColor(entry.key);
            return PieChartSectionData(
              color: categoryColor,
              value: entry.value,
              radius: 35,
              showTitle: true,
              titleStyle: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              badgeWidget: Icon(Icons.circle, color: categoryColor, size: 16),
              badgePositionPercentageOffset: 1.2,
            );
          }).toList()
        : [PieChartSectionData(
            color: Colors.grey.withOpacity(0.4),
            value: 1,
            title: '',
            radius: 60,
            showTitle: false,
          ),
        ];

    return Row(
      children: [
        if (hasExpenses) ...[
          Container(
            width: MediaQuery.of(context).size.width / 3.5,
            padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Color(0xFFF1F1F1),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.expenses.entries.map((entry) {
                return _buildLegendItem(
                    entry.key, _getCategoryColor(entry.key));
              }).toList(),
            ),
          ),
          SizedBox(width: 8),
        ],
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sections: categories,
                  centerSpaceRadius: 50,
                  sectionsSpace: 4,
                  borderData: FlBorderData(show: false),
                ),
              ),
              if (hasExpenses) ...[
                Text(
                  '₹${totalExpense.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColumnChart() {
  List<ExpenseData> data = widget.expenses.entries
    .map((e) => ExpenseData(e.key, e.value, DateTime.now()))
    .toList();

  final TooltipBehavior _tooltipBehavior = TooltipBehavior(
    enable: true,
    header: '',
    format: 'point.x: ₹point.y',
    textStyle: TextStyle(color: Colors.white),
    color: Colors.black.withOpacity(0.8),
  );

  return SfCartesianChart(
    plotAreaBorderWidth: 0,
    title: ChartTitle(
      text: 'Expenses by Category',
      textStyle: TextStyle(
        color: const Color.fromARGB(255, 0, 0, 0),
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
    primaryXAxis: CategoryAxis(
      isVisible: true,
      majorGridLines: MajorGridLines(width: 0),
      axisLine: AxisLine(width: 0),
      labelStyle: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
    ),
    primaryYAxis: NumericAxis(
      labelStyle: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
      axisLine: AxisLine(width: 0),
      majorTickLines: MajorTickLines(size: 0),
      numberFormat: NumberFormat.currency(
        symbol: '₹',
        decimalDigits: 0,
      ),
    ),
    tooltipBehavior: _tooltipBehavior,
    series: <CartesianSeries>[
      ColumnSeries<ExpenseData, String>(
        dataSource: data,
        xValueMapper: (ExpenseData data, _) => data.category,
        yValueMapper: (ExpenseData data, _) => data.amount,
        pointColorMapper: (ExpenseData data, _) => _getCategoryColor(data.category),
        dataLabelSettings: DataLabelSettings(
          isVisible: true,
          textStyle: TextStyle(
            color: const Color.fromARGB(255, 0, 0, 0),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          labelAlignment: ChartDataLabelAlignment.top,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        width: 0.8,
        spacing: 0.2,
      ),
    ],
    legend: Legend(
      isVisible: false,
    ),
  );
}

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food & Drinks':
        return Colors.orange;
      case 'Transport':
        return Colors.blue;
      case 'Entertainment':
        return Colors.purple;
      case 'Investment':
        return Colors.green;
      case 'Shopping':
        return Colors.red;
      case 'Housing':
        return Colors.brown;
      case 'Vehicle':
        return Colors.pink;
      case 'Communication':
        return Color.fromARGB(255, 37, 35, 98);
      case 'Electricity':
        return Colors.yellow;
      case 'Others':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  DateTime _parseDate(String dateString) {
    try {
      return DateFormat('yyyy-MM-dd').parse(dateString);
    } catch (e) {
      print('Error parsing date: $dateString');
      return DateTime.now();
    }
  }

  Widget _buildLegendItem(String category, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            color: color,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              category.length > 8 ? '${category.substring(0, 8)}...' : category,
              style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class ExpenseData {
  final String category;
  final double amount;
  final DateTime? date;

  ExpenseData(this.category, this.amount, [this.date]);

  Map<String, dynamic> toJson() => {
        'category': category,
        'amount': amount,
        'date': date?.toIso8601String(),
      };

  factory ExpenseData.fromJson(Map<String, dynamic> json) {
    return ExpenseData(
      json['category'],
      json['amount'],
      json['date'] != null ? DateTime.parse(json['date']) : null,
    );
  }
}