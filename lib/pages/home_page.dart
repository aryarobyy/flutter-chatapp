import 'package:chat_app/pages/contact_page.dart';
import 'package:chat_app/pages/dashboard.dart';
import 'package:chat_app/pages/settings_page.dart';
import 'package:chat_app/widget/saved_user_contact.dart';
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
    SavedUserContact(),
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
