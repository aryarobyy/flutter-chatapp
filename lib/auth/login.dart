import 'package:chat_app/component/button.dart';
import 'package:chat_app/component/text_field.dart';
import 'package:chat_app/service/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  final void Function()? onTap;

  const Login({super.key, required this.onTap});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void signIn() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      await authService.signInWithEmailAndPassword(
          emailController.text, passwordController.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                //logo
                children: [
                  SizedBox(
                    height: 40,
                  ),
                  const Icon(
                    Icons.message_rounded,
                    size: 80,
                  ),
                  const Text(
                    "Selamat datang",
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
                  MyButton(
                      onPressed: signIn,
                      text: "Login"
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("dont have an account?"),
                      InkWell(onTap: widget.onTap, child: const Text("Click"))
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
