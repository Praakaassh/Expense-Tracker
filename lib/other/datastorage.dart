import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserDataStorage {
  static const _usersKey = 'users';

  // Save or update user details
  static Future<void> saveUserDetails(String emailPhone, {
    String? username,
    String? password,
    String? age,
    String? dateOfBirth,
    String? gender,
    String? status,
    String? cashBalance,
    List<Map<String, dynamic>>? transactions, // Add transactions parameter
    Map<String, double>? expenses,
    List<Map<String, dynamic>>? budgets, // Add expenses parameter
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);

    List<Map<String, dynamic>> users = usersJson == null
        ? [] // Initialize an empty list if no users are found
        : List<Map<String, dynamic>>.from(json.decode(usersJson));

    final userIndex = users.indexWhere((user) => user['emailPhone'] == emailPhone);

    if (userIndex != -1) {
      // Update existing user
      if (username != null) users[userIndex]['username'] = username;
      if (password != null) users[userIndex]['password'] = password;
      if (age != null) users[userIndex]['age'] = age;
      if (dateOfBirth != null) users[userIndex]['dateOfBirth'] = dateOfBirth;
      if (gender != null) users[userIndex]['gender'] = gender;
      if (status != null) users[userIndex]['status'] = status;
      if (cashBalance != null) users[userIndex]['cashBalance'] = cashBalance;
      if (transactions != null) users[userIndex]['transactions'] = transactions;
      if (expenses != null) users[userIndex]['expenses'] = expenses;
      if (budgets != null) users[userIndex]['budgets'] = budgets; // Update expenses
    } else {
      // Add new user
      users.add({
        'emailPhone': emailPhone,
        'username': username ?? '',
        'password': password ?? '',
        'age': age ?? '',
        'dateOfBirth': dateOfBirth ?? '',
        'gender': gender ?? '',
        'status': status ?? '',
        'cashBalance': cashBalance ?? '0.0', // Initialize cash balance
        'transactions': transactions ?? [], // Initialize transactions
        'expenses': expenses ?? {},
        'budgets': budgets ?? [], // Initialize expenses
      });
    }

    await prefs.setString(_usersKey, json.encode(users));
  }

  // Save user balance
  static Future<void> saveUserBalance(String emailPhone, {required String balance}) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);

    List<Map<String, dynamic>> users = usersJson == null
        ? [] // Initialize an empty list if no users are found
        : List<Map<String, dynamic>>.from(json.decode(usersJson));

    final userIndex = users.indexWhere((user) => user['emailPhone'] == emailPhone);

    if (userIndex != -1) {
      // Update balance
      users[userIndex]['cashBalance'] = balance;
      await prefs.setString(_usersKey, json.encode(users));
    } else {
      throw Exception('User not found');
    }
  }

  // Save user transactions
 static Future<void> saveUserTransactions(String emailPhone, {required Map<String, dynamic> newTransaction}) async {
  print("Attempting to save new transaction for user: $emailPhone");
  print("New transaction details: $newTransaction");
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);

    List<Map<String, dynamic>> users = usersJson == null
        ? []
        : List<Map<String, dynamic>>.from(json.decode(usersJson));

    final userIndex = users.indexWhere((user) => user['emailPhone'] == emailPhone);

    if (userIndex != -1) {
      // Append new transaction to existing transactions
      List<Map<String, dynamic>> existingTransactions = List<Map<String, dynamic>>.from(users[userIndex]['transactions'] ?? []);
    existingTransactions.add(newTransaction);
    users[userIndex]['transactions'] = existingTransactions;
    await prefs.setString(_usersKey, json.encode(users));
    print("Transaction saved successfully. Updated transactions: ${users[userIndex]['transactions']}");
  } else {
    print("User not found when trying to save transaction");
    throw Exception('User not found');
    }
  }

  // Save or update user expenses
  static Future<void> saveUserExpenses(String emailPhone, {required Map<String, double> expenses}) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);

    List<Map<String, dynamic>> users = usersJson == null
        ? []
        : List<Map<String, dynamic>>.from(json.decode(usersJson));

    final userIndex = users.indexWhere((user) => user['emailPhone'] == emailPhone);

    if (userIndex != -1) {
      // Update expenses
      users[userIndex]['expenses'] = expenses;
      await prefs.setString(_usersKey, json.encode(users));
    } else {
      throw Exception('User not found');
    }
  }

  // Get all users
static Future<List<Map<String, dynamic>>> getUsers() async {
  final prefs = await SharedPreferences.getInstance();
  final usersJson = prefs.getString(_usersKey);
  print("Raw users data from SharedPreferences: $usersJson");

  if (usersJson == null) {
    print("No users found in SharedPreferences");
    return [];
  }

  try {
    final users = List<Map<String, dynamic>>.from(json.decode(usersJson));
    print("Decoded users: $users");
    return users;
  } catch (e) {
    print("Error decoding users: $e");
    return [];
  }
}
  // Get a specific user
 static Future<Map<String, dynamic>?> getUser(String emailPhone) async {
  print("Attempting to get user with email/phone: $emailPhone");
  final users = await getUsers();
  print("All users: $users");
  final user = users.firstWhere(
    (user) => user['emailPhone'] == emailPhone,
    orElse: () => {},
  );
  print("Found user: $user");
  return user.isEmpty ? null : user;
}
  // Check user credentials
  static Future<bool> checkCredentials(String emailPhone, String password) async {
    final users = await getUsers();
    final user = users.firstWhere(
      (user) => user['emailPhone'] == emailPhone && user['password'] == password,
      orElse: () => {}, // Return an empty map if user is not found
    );
    return user.isNotEmpty; // Return true if user is found and matches the password
  }
  static Future<void> removeUser(String emailPhone) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);

    if (usersJson != null) {
      List<Map<String, dynamic>> users = List<Map<String, dynamic>>.from(json.decode(usersJson));
      users.removeWhere((user) => user['emailPhone'] == emailPhone);
      await prefs.setString(_usersKey, json.encode(users));
    }
  }
static Future<void> saveUserBudgets(String emailPhone, List<Map<String, dynamic>> newBudgets) async {
  print("Saving budgets for email/phone: $emailPhone");
  print("New budgets to save: $newBudgets");
  final userData = await getUser(emailPhone);
  if (userData != null) {
    List<Map<String, dynamic>> existingBudgets = List<Map<String, dynamic>>.from(userData['budgets'] ?? []);
    print("Existing budgets: $existingBudgets");
    existingBudgets.addAll(newBudgets);
    print("Updated budgets: $existingBudgets");
    await saveUserDetails(emailPhone, budgets: existingBudgets);
    print("Budgets saved successfully");
  } else {
    print("User not found when trying to save budgets");
    throw Exception('User not found');
  }
}
// Add this method to the UserDataStorage class in datastorage.dart
static Future<void> clearLatestTransactions() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('latestExpense');
  await prefs.remove('latestIncome');
}
 // Add this method to the UserDataStorage class in datastorage.dart
static Future<void> clearCashBalanceHistory() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('cashBalanceHistory');
}
static Future<Map<String, dynamic>> getBudgetPageData(String emailPhone) async {
  final user = await getUser(emailPhone);
  if (user != null) {
    return {
      'budgets': List<Map<String, dynamic>>.from(user['budgets'] ?? []),
      'transactions': List<Map<String, dynamic>>.from(user['transactions'] ?? []),
    };
  }
  return {'budgets': [], 'transactions': []};
}
static Future<List<String>> getCustomCategories(String emailPhone) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('${emailPhone}_custom_categories') ?? [];
  }
    static Future<void> saveCustomCategory(String emailPhone, String category) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> customCategories = await getCustomCategories(emailPhone);
    if (!customCategories.contains(category)) {
      customCategories.add(category);
      await prefs.setStringList('${emailPhone}_custom_categories', customCategories);
    }
  }

}
