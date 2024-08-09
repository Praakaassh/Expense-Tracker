import 'package:flutter/material.dart';
import 'package:expensetracker/Pages/money.dart'; // Import MoneyPage
import 'package:expensetracker/other/datastorage.dart';

class AccountDetailsPage extends StatefulWidget {
  final String emailPhone;

  const AccountDetailsPage({super.key, required this.emailPhone});

  @override
  _AccountDetailsPageState createState() => _AccountDetailsPageState();
}

class _AccountDetailsPageState extends State<AccountDetailsPage> {
  final TextEditingController _dateOfBirthController = TextEditingController();
  String? _selectedGender;
  String? _selectedStatus;
  bool _finalAgreementAccepted = false;
  bool _showErrors = false; // To control error message display

  bool get _isFormComplete {
    return _dateOfBirthController.text.isNotEmpty &&
        _selectedGender != null &&
        _selectedStatus != null &&
        _finalAgreementAccepted;
  }

  void _createAccount() async {
    if (!_finalAgreementAccepted) {
      // Do nothing if agreement is not accepted
      return;
    }

    setState(() {
      _showErrors = true; // Trigger error message display
    });

    if (_isFormComplete) {
      final dateOfBirth = _dateOfBirthController.text;
      final gender = _selectedGender ?? 'Not Specified';
      final status = _selectedStatus ?? 'Not Specified';

      try {
        // Save the account details in data storage
        await UserDataStorage.saveUserDetails(
          widget.emailPhone,
          dateOfBirth: dateOfBirth,
          gender: gender,
          status: status,
        );

        // Navigate to MoneyPage to enter current balance
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MoneyPage(emailPhone: widget.emailPhone),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error saving details: $e')));
      }
    }
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _dateOfBirthController.text =
            "${pickedDate.toLocal()}".split(' ')[0]; // Format to yyyy-mm-dd
      });
    }
  }

  void _showTermsAndConditions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateModal) {
            return DraggableScrollableSheet(
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20.0)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Terms and Conditions',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Text(
                            'Terms and Conditions\nLast Updated: 02/08/2024\n\n'
                            '1. Introduction\n\n'
                            'Welcome to ("Panappetti"), operated by ("PASS," "we," "us," or "our"). By accessing or using our App, you agree to be bound by these Terms and Conditions ("Terms"). If you do not agree to these Terms, please do not use our App.\n\n'
                            '2. Use of the App\n\n'
                            'Eligibility: You must be at least 18 years old or have the consent of a parent or guardian to use our App.\n'
                            'Account Registration: To use certain features, you may need to register and create an account. You agree to provide accurate, complete, and current information during registration and to update such information to keep it accurate, complete, and current.\n'
                            'User Responsibilities: You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account. Notify us immediately of any unauthorized use of your account.\n\n'
                            '3. Privacy Policy\n\n'
                            'Your use of the App is also governed by our Privacy Policy, which can be found [here]. By using our App, you consent to the collection and use of your information as described in the Privacy Policy.\n\n'
                            '4. Intellectual Property\n\n'
                            'Ownership: All content, features, and functionality on the App are owned by us or our licensors and are protected by intellectual property laws. You may not use any content from the App without our express written permission.\n'
                            'License: We grant you a limited, non-exclusive, non-transferable license to access and use the App for personal, non-commercial purposes.\n\n'
                            '5. User Content\n\n'
                            'Responsibility: You are solely responsible for any data, information, or content you submit through the App.\n'
                            'Grant of License: By submitting content, you grant us a worldwide, royalty-free, non-exclusive license to use, reproduce, modify, and display such content in connection with the App.\n\n'
                            '6. Prohibited Conduct\n\n'
                            'You agree not to:\n'
                            'Use the App for any illegal or unauthorized purpose.\n'
                            'Interfere with or disrupt the App or servers.\n'
                            'Engage in any form of automated data collection (e.g., scraping, harvesting).\n\n'
                            '7. Disclaimers\n\n'
                            'No Financial Advice: The App provides tools for budgeting and expense tracking but does not offer financial, investment, or professional advice.\n'
                            'As-Is Basis: The App is provided "as is" and "as available" without any warranties of any kind, either express or implied.\n\n'
                            '8. Limitation of Liability\n\n'
                            'To the fullest extent permitted by law, we shall not be liable for any indirect, incidental, special, consequential, or punitive damages arising out of or in connection with your use of the App.\n\n'
                            '9. Changes to Terms\n\n'
                            'We may update these Terms from time to time. We will notify you of any changes by posting the new Terms on the App. Your continued use of the App after any changes signifies your acceptance of the new Terms.\n\n'
                            '10. Termination\n\n'
                            'We reserve the right to terminate or suspend your access to the App at our sole discretion, without prior notice, for any reason, including for violation of these Terms.\n\n'
                            '11. Governing Law\n\n'
                            'These Terms are governed by and construed in accordance with the laws of Indian government, without regard to its conflict of law principles.\n\n'
                            '12. Contact Us\n\n'
                            'If you have any questions about these Terms, please contact us at:\n'
                            'panappetti@gmail.com',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Checkbox(
                            value: _finalAgreementAccepted,
                            onChanged: (bool? value) {
                              setState(() {
                                _finalAgreementAccepted = value ?? false;
                              });
                              setStateModal(() {}); // Update the modal state
                            },
                          ),
                          Expanded(
                            child: Text(
                              'I agree to all terms and conditions',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: Text('Account Details',
            style: TextStyle(color: Color.fromARGB(159, 0, 0, 0))),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Color(0xFFF1F1F1), // Changed color to #f1f1f1
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3), // Changes position of shadow
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTextField(
                  _dateOfBirthController,
                  'Date of Birth',
                  readOnly: true,
                  suffixIcon: GestureDetector(
                    onTap: () => _selectDateOfBirth(context),
                    child: Icon(Icons.calendar_today,
                        color: const Color.fromARGB(255, 0, 0, 0)),
                  ),
                  errorText: _showErrors && _dateOfBirthController.text.isEmpty
                      ? 'Date of Birth is required'
                      : null,
                ),
                SizedBox(height: 20),
                _buildDropdownField(
                  'Gender',
                  ['Male', 'Female', 'Prefer not to say'],
                  (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                  _selectedGender,
                  errorText: _showErrors &&
                          (_selectedGender == 'Select...' ||
                              _selectedGender == null)
                      ? 'Gender is required'
                      : null,
                ),
                SizedBox(height: 20),
                _buildDropdownField(
                  'Current Status',
                  ['Student', 'Working', 'Retired'],
                  (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                  _selectedStatus,
                  errorText: _showErrors &&
                          (_selectedStatus == 'Select...' ||
                              _selectedStatus == null)
                      ? 'Current Status is required'
                      : null,
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: _showTermsAndConditions,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        ' Go To Terms and Conditions',
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline),
                      ),
                      SizedBox(width: 5),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _finalAgreementAccepted ? _createAccount : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Button color when clickable
                    foregroundColor: Colors.white, // Text color when clickable
                    shadowColor: Colors.transparent, // Remove shadow
                  ),
                  child: Text('Create Account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool readOnly = false, Widget? suffixIcon, String? errorText}) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3), // Transparent white
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.black),
          border: OutlineInputBorder(),
          suffixIcon: suffixIcon,
          errorText: errorText, // Show error text if present
        ),
        readOnly: readOnly,
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> options,
      ValueChanged<String?> onChanged, String? currentValue,
      {String? errorText}) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3), // Transparent white
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: DropdownButtonFormField<String>(
        value: currentValue,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.black),
          border: OutlineInputBorder(),
          errorText: errorText, // Show error text if present
        ),
        onChanged: onChanged,
        items: options.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: TextStyle(color: Colors.black)),
          );
        }).toList(),
      ),
    );
  }
}
