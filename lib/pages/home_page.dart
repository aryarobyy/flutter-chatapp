import 'package:chat_app/pages/contact_page.dart';
import 'package:chat_app/pages/saved_user_contact.dart';
import 'package:chat_app/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

class Home extends StatefulWidget {
  final int initialTab;
  const Home({Key? key, this.initialTab = 0}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedItem = 0;
  late final LocalStorage localStorage;
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.initialTab;
  }
  static const List<Widget> _widgetOptions = <Widget>[
    SavedUserContact(),
    Contact(),
    Settings()
  ];


  void _onItemTapped(int index) {
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
              icon: Icon(Icons.person_add_alt_1),
            ),
            BottomNavigationBarItem(
                label: "Profile",
                icon: Icon(Icons.person)
            ),
          ],
          currentIndex: _selectedItem,
          selectedItemColor: Colors.lightBlue,
          onTap: _onItemTapped,
          ),
        );
    }
  }
