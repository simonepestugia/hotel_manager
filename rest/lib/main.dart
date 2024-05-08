import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'dart:convert'; // for the utf8.encode method

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Account Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AccountManagementPage(),
    );
  }
}

class AccountManagementPage extends StatefulWidget {
  @override
  _AccountManagementPageState createState() => _AccountManagementPageState();
}

class _AccountManagementPageState extends State<AccountManagementPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController surnameController = TextEditingController();
  TextEditingController newEmailController = TextEditingController();
  List<Account> accounts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAccounts();
  }

  Future<void> loadAccounts() async {
    final response = await http.get(Uri.parse('http://localhost/server/Server.php'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      print('Server response: $jsonData'); // Per debug
      if (jsonData is List) {
        setState(() {
          accounts = jsonData.map((data) => Account.fromJson(data)).toList();
          isLoading = false;
        });
      } else {
        print('Invalid JSON format received: $jsonData');
        setState(() {
          isLoading = false;
        });
      }
    } else {
      print('Failed to load accounts: ${response.statusCode}');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteAccount(int accountId) async {
    final response = await http.delete(
      Uri.parse('http://localhost/server/Server.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{'ID_account': accountId}),
    );

    if (response.statusCode == 200) {
      loadAccounts();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Account deleted')));
    } else {
      print('Failed to delete account: ${response.statusCode}');
    }
  }

  Future<void> addAccount(
      String email, String password, String name, String surname) async {
    // Hash della password
    String hashedPassword = hashPassword(password);

    // Controlla se tutti i campi sono riempiti
    if ([email, hashedPassword, name, surname]
        .any((element) => element.isEmpty)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('All fields are required')));
      return;
    }

    // Controlla la validità dell'email
    if (!validateEmail(email)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Invalid Email')));
      return;
    }

    final response = await http.post(
      Uri.parse('http://localhost/server/Server.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': hashedPassword,
        'nome': name,
        'cognome': surname,
      }),
    );

    if (response.statusCode == 200) {
      loadAccounts();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Account added')));
    } else {
      print('Failed to add account: ${response.statusCode}');
    }
  }

  Future<void> modifyAccount(int accountId, String newEmail) async {
    if (newEmail.isEmpty || !validateEmail(newEmail)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Invalid or empty email')));
      return;
    }

    final response = await http.put(
      Uri.parse('http://localhost/server/Server.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'ID_account': accountId,
        'new_email': newEmail,
      }),
    );

    if (response.statusCode == 200) {
      loadAccounts();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Account updated')));
    } else {
      print('Failed to update account: ${response.statusCode}');
    }
  }

  String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  bool validateEmail(String email) {
    String emailPattern =
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regExp = RegExp(emailPattern);
    return regExp.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Enter Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Enter Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 10),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Enter Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: surnameController,
              decoration: InputDecoration(
                labelText: 'Enter Surname',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                addAccount(
                  emailController.text,
                  passwordController.text,
                  nameController.text,
                  surnameController.text,
                );
                emailController.clear();
                passwordController.clear();
                nameController.clear();
                surnameController.clear();
              },
              child: Text('Add Account'),
            ),
            SizedBox(height: 20),
            Text(
              'All Accounts',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : accounts.isEmpty
                      ? Center(child: Text('No accounts available'))
                      : ListView.builder(
                          itemCount: accounts.length,
                          itemBuilder: (context, index) {
                            return Card(
                              child: ListTile(
                                title: Text(accounts[index].email),
                                subtitle: Text(accounts[index].nome),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        newEmailController.text = '';
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Modify Account Email'),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  TextField(
                                                    controller:
                                                        newEmailController,
                                                    decoration: InputDecoration(
                                                      labelText:
                                                          'Enter New Email',
                                                      border:
                                                          OutlineInputBorder(),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('Cancel'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    modifyAccount(
                                                        accounts[index].id,
                                                        newEmailController.text);
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('Save'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        deleteAccount(accounts[index].id);
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
    );
  }
}

class Account {
  final int id;
  final String email;
  final String password;
  final String nome;
  final String cognome;

  Account({
    required this.id,
    required this.email,
    required this.password,
    required this.nome,
    required this.cognome,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['ID_account'] as int,
      email: json['email'] as String,
      password: json['password'] as String,
      nome: json['nome'] as String,
      cognome: json['cognome'] as String,
    );
  }
}
