import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert' as convert;
import 'expense.dart';
import 'login.dart';

class Expenses extends StatefulWidget {
  String name;

  Expenses({required this.name});

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  List<Expense> e = [];
  int totalSum = 0;


  @override
  void initState() {
    super.initState();
    loadExpenses();
  }

  void loadExpenses() async {
    var url = "https://baraamarchoudd.000webhostapp.com/api/list_expenses.php";
    var response = await post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: convert.jsonEncode(<String, String>{
          'name': widget.name,
        }));

    if (response.statusCode == 200) {
      setState(() {
        e.clear();
        String data = response.body;
        totalSum = 0;
        for (var row in convert.jsonDecode(data)) {
          var p = Expense(row["name"], int.parse(row["price"]));
          e.add(p);
          totalSum += p.price;
        }
      });
    }
  }

  Future<void> addExpense() async {
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Expense'),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Expense Name'),
                keyboardType: TextInputType.text,
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final name = nameController.text;
                final price = priceController.text;

                var url = "https://baraamarchoudd.000webhostapp.com/api/add_expenses.php";

                final response = await post(
                  Uri.parse(url),
                  headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                  },
                  body: convert.jsonEncode(
                    <String, String>{
                      'name': name,
                      'price': price,
                      'user_name': widget.name,
                    },
                  ),
                );
                if (response.statusCode == 200) {
                  var jsonResponse = convert.jsonDecode(response.body);
                  if (jsonResponse['exist'] == true) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Expense already exists. Please enter another expense.'),
                        duration: Duration(seconds: 5),
                      ),
                    );
                  }
                  else {
                    loadExpenses();
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Expense added successfully.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                } else {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to add expense. Please try again.'),
                      duration: Duration(seconds: 5),
                    ),
                  );
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
  Future<void> editExpense(int index) async {
    final nameController = TextEditingController(text: e[index].name);
    final priceController = TextEditingController(text: e[index].price.toString());

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Expense Name'),
                keyboardType: TextInputType.text,
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final newName = nameController.text;
                final newPrice = priceController.text;

                var url = "https://baraamarchoudd.000webhostapp.com/api/edit.php";
                final response = await post(
                  Uri.parse(url),
                  headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                  },
                  body: convert.jsonEncode(
                    <String, String>{
                      'user_name': widget.name,
                      'current_name': e[index].name,
                      'current_price': e[index].price.toString(),
                      'new_name': newName,
                      'new_price': newPrice,
                    },
                  ),
                );

                if (response.statusCode == 200) {
                  var jsonResponse = convert.jsonDecode(response.body);
                  if (jsonResponse['Edit'] == true) {
                    setState(() {
                      e[index].name = newName;
                      e[index].price = int.parse(newPrice);
                    });
                    Navigator.of(context).pop();
                    loadExpenses();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Expense edited successfully.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                } else {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to edit expense. Please try again.'),
                      duration: Duration(seconds: 5),
                    ),
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteExpense(int index) async {
    var url = "https://baraamarchoudd.000webhostapp.com/api/delete.php";
    var response = await post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: convert.jsonEncode(
        <String, String>{
          'user_name': widget.name,
          'name': e[index].name,
          'price': e[index].price.toString(),
        },
      ),
    );

    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      if (jsonResponse['deleted'] == true) {
        setState(() {
          e.removeAt(index);
          loadExpenses();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Expense deleted successfully.'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete expense. Please try again.'),
            duration: Duration(seconds: 5),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete expense. Please try again.'),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Expenses Tracker',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 35,
          ),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
          onPressed: () {
    Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => Login()),
    );
    },
      icon: Icon(Icons.logout),
    ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Colors.purple],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Total Sum: $totalSum\$',
                style: TextStyle(fontSize: 30, color: Colors.white),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: e.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(
                        e[index].name,
                        style: TextStyle(fontSize: 25, color: Colors.black),
                      ),
                      subtitle: Text(
                        '${e[index].price}',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            color: Colors.black,
                            onPressed: () {
                              editExpense(index);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () {
                              deleteExpense(index);
                            },
                          ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addExpense();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.black,
        tooltip: 'Add Expense',
      ),
    );
  }
}