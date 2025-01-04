import 'package:chat_app/services/auth/authentication.dart';
import 'package:chat_app/services/google_auth.dart';
import 'package:chat_app/services/navigation_service.dart';
import 'package:chat_app/widget/button.dart';
import 'package:chat_app/component/snackbar.dart';
import 'package:chat_app/widget/text_field.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';


class Login extends StatefulWidget {
  final void Function()? onTap;

  const Login({super.key, required this.onTap});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  late NavigationService _navigation;
  bool isLoading = false;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  void signIn() async {
    setState(() {
      isLoading = true;
    });

    String res = await AuthMethod().loginUser(
      email: emailController.text,
      password: passwordController.text,
    );

    setState(() {
      isLoading = false;
    });

    if (res.toLowerCase() == "success") {
      showSnackBar(context, "Login Successful!");
      _navigation.navigateToRoute('/home');
    } else {
      showSnackBar(context, "Wrong password or email");
    }
  }

  @override
  Widget build(BuildContext context) {
    _navigation = GetIt.instance.get<NavigationService>();
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
                  MyButton(onPressed: signIn, text: "Login"),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("dont have an account?"),
                      InkWell(onTap: widget.onTap, child: const Text("Click")),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 10),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey),
                      onPressed: () async {
                        bool isSignedIn = await FirebaseServices().signInWithGoogle();
                        if (isSignedIn) {
                          _navigation.navigateToRoute('/home');
                        } else {
                          showSnackBar(context,"Sign-In failed. Navigation to home page aborted.");
                        }
                      },
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Image.network(
                              "https://ouch-cdn2.icons8.com/VGHyfDgzIiyEwg3RIll1nYupfj653vnEPRLr0AeoJ8g/rs:fit:456:456/czM6Ly9pY29uczgu/b3VjaC1wcm9kLmFz/c2V0cy9wbmcvODg2/LzRjNzU2YThjLTQx/MjgtNGZlZS04MDNl/LTAwMTM0YzEwOTMy/Ny5wbmc.png",
                              height: 35,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Continue with Google",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
