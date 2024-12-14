import 'package:chat_app/pages/contact.dart';
import 'package:chat_app/pages/dashboard.dart';
import 'package:chat_app/pages/settings.dart';
import 'package:chat_app/service/auth/login_or_register.dart';
import 'package:chat_app/service/google_auth/google_auth.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedItem = 0;
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Dashboard(),
    Contact(),
    Settings()
  ];

  void _onItemTapped(int index){
    setState(() {
      _selectedItem = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedItem),
      ),
      bottomNavigationBar:
          BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              label: "Home",
              icon: Icon(Icons.home),
            ),
            BottomNavigationBarItem(
              label: "Contact",
              icon: Icon(Icons.person),
            ),
            BottomNavigationBarItem(
                label: "Setting",
                icon: Icon(Icons.settings)
            ),
          ],
          currentIndex: _selectedItem,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
          ),
        );
    }
  }
