import 'package:flutter/material.dart';
import 'package:expensetracker/other/datastorage.dart';
import 'package:expensetracker/Pages/loginpage.dart';

class SettingsPage extends StatefulWidget {
  final String emailPhone;

  const SettingsPage({Key? key, required this.emailPhone}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Map<String, dynamic> _userData = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await UserDataStorage.getUser(widget.emailPhone);
    if (user != null) {
      setState(() {
        _userData = user;
      });
    }
  }

  // In SettingsPage class (settings_page.dart)
// In SettingsPage class (settings_page.dart)
void _removeUser() async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirm Removal'),
        content: Text(
            'Are you sure you want to remove this user? This action cannot be undone.'),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Remove'),
            onPressed: () async {
              // Remove user data
              await UserDataStorage.removeUser(widget.emailPhone);
              
              // Clear latest transactions
              await UserDataStorage.clearLatestTransactions();

              // Clear cash balance history
              await UserDataStorage.clearCashBalanceHistory();

              // Navigate back to login page
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginPage()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      );
    },
  );
}
  int _calculateAge(String dateOfBirth) {
    DateTime dob = DateTime.parse(dateOfBirth);
    DateTime today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  @override
  @override
@override
Widget build(BuildContext context) {
  String age = _userData['dateOfBirth'] != null
      ? _calculateAge(_userData['dateOfBirth']).toString()
      : 'N/A';

  return Scaffold(
    appBar: AppBar(
      title: Text('Settings', style: TextStyle(color: Colors.white)),
      backgroundColor: Color(0xFF87dcfb),
      elevation: 0,
    ),
    body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF87dcfb), const Color.fromARGB(255, 204, 123, 218)],
        ),
      ),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.top,
          ),
          child: IntrinsicHeight(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('User Information',
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF87dcfb))),
                          SizedBox(height: 24),
                          _buildInfoRow('Username', _userData['username'] ?? 'N/A'),
                          _buildInfoRow('Phone no', _userData['emailPhone'] ?? 'N/A'),
                          _buildInfoRow('Age', age),
                          _buildInfoRow('Gender', _userData['gender'] ?? 'N/A'),
                          _buildInfoRow('Status', _userData['status'] ?? 'N/A'),
                          Spacer(),
                          Center(
                            child: ElevatedButton(
                              onPressed: _removeUser,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                                textStyle: TextStyle(fontSize: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Text('Remove User'),
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

Widget _buildInfoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[600])),
        Text(value, style: TextStyle(fontSize: 16, color: Colors.black87)),
      ],
    ),
  );
}
}