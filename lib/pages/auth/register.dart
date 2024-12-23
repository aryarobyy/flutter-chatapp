
import 'package:chat_app/services/auth/authentication.dart';
import 'package:chat_app/services/navigation_service.dart';
import 'package:chat_app/widget/button.dart';
import 'package:chat_app/component/snackbar.dart';
import 'package:chat_app/widget/text_field.dart';
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
  late double _deviceHeight;
  late double _deviceWidth;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  late NavigationService _navigation = NavigationService(); // Declare _navigation
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

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(emailController.text)) {
      showSnackBar(context, "Invalid email format");
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
        img_url: "",
        last_active: "",
      );

      setState(() {
        isLoading = false;
      });

      if (res == "success") {
        Navigator.of(context).pushNamed('/home');
        showSnackBar(context, "Account created successfully");
        print("Response $res");
      } else {
        logger.d("Registration failed: $res");
        showSnackBar(context, res);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      logger.e("Unexpected error during registration: $e");
      showSnackBar(context, "An unexpected error occurred: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

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
                    SizedBox(
                      height: 40,
                    ),
                    const Icon(
                      Icons.message_rounded,
                      size: 80,
                    ),
                    const Text(
                      "Buat Akun",
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
                        SizedBox(
                          height: 26,
                        ),
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
                        SizedBox(
                          height: 26,
                        ),
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
                        SizedBox(
                          height: 26,
                        ),
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
                    SizedBox(
                      height: 40,
                    ),
                    isLoading
                        ? CircularProgressIndicator()
                        : MyButton(
                            onPressed: register,
                            text: "Register",
                          ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("Already have an account? "),
                        InkWell(
                            onTap: widget.onTap,
                            child: const Text("Login",
                                style: TextStyle(color: Colors.blue)))
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
