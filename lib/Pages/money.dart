import 'package:flutter/material.dart';
import 'package:expensetracker/Pages/homepage.dart';
import 'package:expensetracker/other/datastorage.dart';

class MoneyPage extends StatefulWidget {
  final String emailPhone;

  const MoneyPage({super.key, required this.emailPhone});

  @override
  _MoneyPageState createState() => _MoneyPageState();
}

class _MoneyPageState extends State<MoneyPage> {
  final TextEditingController _balanceController = TextEditingController();

  void _saveBalance() async {
    final balance = _balanceController.text;

    try {
      await UserDataStorage.saveUserBalance(widget.emailPhone,
          balance: balance);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(emailPhone: widget.emailPhone),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error saving balance: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the back button
        backgroundColor: Colors.white, // Set background color of the app bar
      ),
      backgroundColor: Colors.white, // Set background color of the scaffold
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          constraints: BoxConstraints(maxWidth: 400), // Limit container width
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3), // Shadow position
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Container size fits content
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(_balanceController, 'Enter Current Balance'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveBalance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF1F1F1), // Button color #f1f1f1
                  foregroundColor: Colors.blue, // Text color blue
                  shadowColor:
                      const Color.fromARGB(0, 165, 165, 165), // Remove shadow
                ),
                child: Text('Save Balance'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Focus(
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.grey[200],
          ),
          style: TextStyle(color: Colors.black),
        ),
        onFocusChange: (hasFocus) {
          setState(() {
            if (hasFocus) {
              controller.selection = TextSelection(
                baseOffset: 0,
                extentOffset: controller.text.length,
              );
            }
          });
        },
      ),
    );
  }
}
