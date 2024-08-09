import 'package:expensetracker/Pages/homepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expensetracker/Pages/accountdetails.dart';
import 'package:expensetracker/other/datastorage.dart';
import 'dart:math';

import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Future<List<Map<String, dynamic>>> _getUsers() async {
    return await UserDataStorage.getUsers();
  }

  void _showAddUserDialog() async {
    final TextEditingController _usernameController = TextEditingController();
    final TextEditingController _emailPhoneController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFFF1F1F1),
          title: Text('Add User', style: TextStyle(color: Colors.blueAccent)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(_usernameController, 'Username'),
                SizedBox(height: 20),
                _buildTextField(_emailPhoneController, 'Phone Number',
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ]),
                SizedBox(height: 20),
                _buildTextField(_passwordController, 'Password',
                    isPassword: true),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () async {
                final username = _usernameController.text;
                final emailPhone = _emailPhoneController.text;
                final password = _passwordController.text;

                if (username.isNotEmpty &&
                    emailPhone.isNotEmpty &&
                    password.isNotEmpty) {
                  if (!RegExp(r'^\d{10}$').hasMatch(emailPhone)) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            'Invalid number. Please enter a 10-digit number.')));
                    return;
                  }
                  await UserDataStorage.saveUserDetails(
                    emailPhone,
                    username: username,
                    password: password,
                  );
                  Navigator.pop(context); // Close the dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AccountDetailsPage(emailPhone: emailPhone),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('All fields are required')));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFF1F1F1),
                foregroundColor: Color.fromRGBO(4, 79, 207, 1),
              ),
              child: Text('Add User'),
            ),
          ],
        );
      },
    );
  }

  void _showPasswordDialog(String emailPhone) {
    final TextEditingController _passwordController = TextEditingController();
    final ValueNotifier<bool> _hasError = ValueNotifier<bool>(false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFFF1F1F1), // Set dialog background color
          title: Text('Enter Password',
              style: TextStyle(color: Colors.blueAccent)),
          content: ValueListenableBuilder<bool>(
            valueListenable: _hasError,
            builder: (context, hasError, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(_passwordController, 'Password',
                      isPassword: true, error: hasError),
                  if (hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Invalid credentials',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () async {
                final password = _passwordController.text;
                if (await UserDataStorage.checkCredentials(
                    emailPhone, password)) {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomePage(emailPhone: emailPhone)),
                  );
                } else {
                  _hasError.value = true;
                }
              },
              child: Text('Login'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isPassword = false,
      List<TextInputFormatter>? inputFormatters,
      bool error = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: error ? Colors.red : Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(15),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: error ? Colors.red : Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: error ? Colors.red : Colors.blue),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatar({String imagePath = ''}) {
    // List of asset image paths
    final List<String> assetImages = [
      'assets/images/avatar1.png',
      'assets/images/avatar2.png',
      'assets/images/avatar3.png',
      // Add more image paths here
    ];

    // Function to get a random image from the list
    String _getRandomImagePath() {
      final random = Random();
      return assetImages[random.nextInt(assetImages.length)];
    }

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white, // Background color of the circle
        border: Border.all(color: Colors.blueAccent, width: 2),
      ),
      child: CircleAvatar(
        radius: 40,
        backgroundColor: Colors.white, // Background color of the avatar
        backgroundImage: imagePath.isNotEmpty
            ? AssetImage(imagePath)
            : AssetImage(_getRandomImagePath()),
        child: imagePath.isEmpty
            ? Icon(Icons.add,
                color: Colors.black,
                size: 40) // Changed icon color to black for visibility
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.red)));
          } else {
            final users = snapshot.data ?? [];
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 350,
                  height: 500,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFFF1F1F1),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: users.isEmpty
                              ? SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
  'Welcome To ',
  style: GoogleFonts.dancingScript(
    textStyle: TextStyle(
      color: Color.fromARGB(255, 0, 0, 0),
      fontSize: 50,
    ),
  ),
),
                                      Text(
  '"Panapetti"',
  style: GoogleFonts.dancingScript(
    textStyle: TextStyle(
      color: Color.fromARGB(255, 196, 2, 255),
      fontSize: 40,
    ),
  ),
),
                                      SizedBox(height: 16),
                                      Image.asset(
                                        'assets/images/sign.png',
                                        fit: BoxFit.cover,
                                        width:
                                            200, // Adjust the width as needed
                                        height:
                                            100, // Adjust the height as needed
                                      ),
                                      SizedBox(
                                          height:
                                              16), // Add space between the image and the button
                                      ElevatedButton(
                                        onPressed: _showAddUserDialog,
                                        child: Text('Create Account'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 32, vertical: 12),
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      
                                    ],
                                  ),
                                )
                              : // Rest of the code for when users are not empty

                              // Rest of the code for when users are not empty

                              Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 50),
                                  Text(
  'Welcome Back,',
  style: GoogleFonts.dancingScript(
    textStyle: TextStyle(
      color: Colors.black,
      fontSize: 50,
      fontWeight: FontWeight.bold,
    ),
  ),
),SizedBox(height: 16),
                                    Expanded(
                                      child: GridView.builder(
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 10,
                                          mainAxisSpacing: 10,
                                          childAspectRatio: 0.75,
                                        ),
                                        itemCount: users.length,
                                        itemBuilder: (context, index) {
                                          final user = users[index];
                                          return GestureDetector(
                                            onTap: () => _showPasswordDialog(
                                                user['emailPhone']!),
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  _buildUserAvatar(
                                                      imagePath:
                                                          'assets/images/user_image.jpg'),
                                                  SizedBox(height: 8),
                                                  Text(user['username']!,
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                        
                        Text(
                          "'Let's make your financial life a little better'",
                          style: TextStyle(
                            color: const Color.fromARGB(255, 81, 81, 81),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "Provided by Prakash & Subin",
                          style: TextStyle(
                            color: Color.fromARGB(255, 21, 0, 0),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 90),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}