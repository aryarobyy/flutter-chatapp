import 'dart:developer';

import 'package:chat_app/component/button.dart';
import 'package:chat_app/component/snackbar.dart';
import 'package:chat_app/component/text_field.dart';
import 'package:chat_app/pages/home.dart';
import 'package:chat_app/service/auth/authentication.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class Register extends StatefulWidget {
  final void Function()? onTap;
  const Register({super.key, required this.onTap});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void register() async {
    if (emailController.text.isEmpty ||
        nameController.text.isEmpty ||
        passwordController.text.isEmpty) {
      showSnackBar(context, "Please fill in all fields");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String res = await AuthMethod().registerUser(
        email: emailController.text,
        name: nameController.text,
        password: passwordController.text,
      );

      if (res == "success") {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const Home(),
            ),
          );

        showSnackBar(context, "Account created successfully");
      } else {
        logger.d("Registration failed: $res");
        showSnackBar(context, res);
      }
    } catch (e) {
      logger.e("Unexpected error during registration: $e");
      showSnackBar(context, "An unexpected error occurred: $e");
    } finally {
        setState(() {
          isLoading = false;
        });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 40,),
                    const Icon(
                      Icons.message_rounded,
                      size: 80,
                    ),
                    const Text("Buat Akun",
                      style: TextStyle(
                        fontSize: 30,
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 26,),
                        const Text(
                          "Email",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        Center(
                          child: MyTextField(
                            controller: emailController,
                            hintText: "Example@gmail.com",
                            obscureText: false,
                          ),
                        ),
                        SizedBox(height: 26,),
                        const Text(
                          "Nama",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        Center(
                          child: MyTextField(
                            controller: nameController,
                            hintText: "Ilham",
                            obscureText: false,
                          ),
                        ),
                        SizedBox(height: 26,),
                        const Text(
                          "Password",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        Center(
                          child: MyTextField(
                              controller: passwordController,
                              hintText: "Password",
                              obscureText: true),
                        ),
                      ],
                    ),
                    SizedBox(height: 40,),
                    isLoading
                        ? CircularProgressIndicator()
                        : MyButton(
                      onPressed: register,
                      text: "Register",
                    ),
                    SizedBox(height: 20,),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("Already have an account? "),
                        InkWell(
                            onTap: widget.onTap,
                            child: const Text("Login", style: TextStyle(color: Colors.blue))
                        )
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}