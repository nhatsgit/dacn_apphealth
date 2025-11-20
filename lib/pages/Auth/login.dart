import 'package:dacn_app/pages/Auth/register.dart';
import 'package:dacn_app/pages/main_page.dart';
import 'package:dacn_app/routes/routes.dart';
import 'package:dacn_app/services/AuthServices.dart';
import 'package:dacn_app/services/HttpRequest.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
//eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJjNjI2YjI1NC1jZjRhLTRmOGEtYWJjMy1mODNiOGQzYWY4MTkiLCJlbWFpbCI6InRlc3RAZ21haWwuY29tIiwidXNlcklkIjoiNzExNTUwZWMtYmFlYi00ZGJiLWE2NTEtZGIzYTI0YmRjMDliIiwiZXhwIjoxNzY0MDAwNzU3LCJpc3MiOiJkYWNuX2FwaSIsImF1ZCI6ImRhY25fYXBpX3VzZXJzIn0.Pipr8UV-6Rkv9rZEAbjVHTOlXqbDyV8SUee1CdftWQg

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _txtUserName = TextEditingController();
  final TextEditingController _txtPassword = TextEditingController();
  void login() async {
    String username = _txtUserName.text.trim();
    String password = _txtPassword.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Tên đăng nhập và mật khẩu không được để trống')),
      );
    } else {
      try {
        String jwtToken = await AuthServices(HttpRequest(http.Client()))
            .login(username, password);

        SharedPreferences prefs = await SharedPreferences.getInstance();

        await prefs.setString('jwt', jwtToken);
        Navigator.pushNamed(context, AppRoutes.home);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi đăng nhập: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.blue, title: Text("Đăng nhập")),
      body: Center(
        child: Container(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icons/logo.png',
                  width: 100,
                  height: 60,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                  child: TextField(
                    controller: _txtUserName,
                    decoration: const InputDecoration(labelText: "Email"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                  child: TextField(
                    controller: _txtPassword,
                    decoration: const InputDecoration(labelText: "Mật khẩu"),
                    obscureText: true,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                  child: Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: login,
                      child: Text("Đăng nhập"),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                  child: Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterPage()),
                        );
                      },
                      child: Text(
                        "Đăng kí tài khoản",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
