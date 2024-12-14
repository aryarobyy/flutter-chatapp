import 'package:chat_app/component/button.dart';
import 'package:chat_app/component/text_field.dart';
import 'package:flutter/material.dart';

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
                  MyButton(
                    onPressed: () {},
                      text: "Register",
                  ),
                  SizedBox(height: 20,),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("dont have an account?"),
                      InkWell(
                          onTap: widget.onTap,
                          child: const Text("Click")
                      )
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
