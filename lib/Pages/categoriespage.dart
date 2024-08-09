import 'package:flutter/material.dart';

class CategoriesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Category'),
        backgroundColor: const Color(0xFF87dcfb),
      ),
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          ListTile(
            title: _buildCategoryRow('Food & Drinks', Colors.orange),
            onTap: () => _selectCategory(context, 'Food & Drinks'),
          ),
          ListTile(
            title: _buildCategoryRow('Transport', Colors.blue),
            onTap: () => _selectCategory(context, 'Transport'),
          ),
          ListTile(
            title: _buildCategoryRow('Entertainment', Colors.purple),
            onTap: () => _selectCategory(context, 'Entertainment'),
          ),
          ListTile(
            title: _buildCategoryRow('Investment', Colors.green),
            onTap: () => _selectCategory(context, 'Investment'),
          ),
          ListTile(
            title: _buildCategoryRow('Shopping', Colors.red),
            onTap: () => _selectCategory(context, 'Shopping'),
          ),
          ListTile(
            title: _buildCategoryRow('Housing', Colors.brown),
            onTap: () => _selectCategory(context, 'Housing'),
          ),
          ListTile(
            title: _buildCategoryRow('Vehicle', Colors.pink),
            onTap: () => _selectCategory(context, 'Vehicle'),
          ),
          ListTile(
            title: _buildCategoryRow('Communication', Color.fromARGB(255, 37, 35, 98)),
            onTap: () => _selectCategory(context, 'Communication'),
          ),
          ListTile(
            title: _buildCategoryRow('Electricity', Colors.yellow),
            onTap: () => _selectCategory(context, 'Electricity'),
          ),
          /*ListTile(
            title: _buildCategoryRow('Others', Colors.grey[600]!),
            onTap: () => _selectCategory(context, 'Others'),
          ),*/
          ListTile(
            title: _buildCategoryRow('Add Custom Category', Colors.grey),
            onTap: () => _addCustomCategory(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(String category, Color color) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          color: color,
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text(category),
        ),
      ],
    );
  }

  void _selectCategory(BuildContext context, String category) {
    Navigator.pop(context, category);
  }

  void _addCustomCategory(BuildContext context) async {
    String? customCategory = await showDialog<String>(
      context: context,
      builder: (context) {
        String categoryName = '';
        return AlertDialog(
          title: Text('Add Custom Category'),
          content: TextField(
            onChanged: (value) {
              categoryName = value;
            },
            decoration: InputDecoration(hintText: "Category Name"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                Navigator.of(context).pop(categoryName);
              },
            ),
          ],
        );
      },
    );

    if (customCategory != null && customCategory.isNotEmpty) {
      _selectCategory(context, customCategory);
    }
  }
}
