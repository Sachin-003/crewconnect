import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:proddyfi/addproject.dart';
import 'projectpage.dart';
import 'homescreen.dart';
import 'Notifications.dart';

class home extends StatefulWidget {
  const home({super.key});


  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  int select_index = 0;
  final List<Widget> _widgetlist = <Widget>[
    const HomeScreen(),
    const ProjectPage(),
    const addProject(),
    const Notifications(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SafeArea(
        child: _widgetlist[select_index],

      ),

      bottomNavigationBar: GNav(

        selectedIndex: select_index,
        activeColor: Colors.black,
        onTabChange: (index){
          setState(() {
            select_index = index;
          });
        },
        tabs: [
          GButton(
            icon: Icons.home,
            iconColor: Colors.yellow,
            iconSize: 30,

          ),


          GButton(
            icon: Icons.code,
            iconColor: Colors.yellow,
            iconSize: 30,
          ),
          GButton(
            icon: Icons.add_circle,
            iconColor: Colors.yellow,
            iconSize: 30,
          ),

          GButton(
            icon: Icons.notifications,
            iconColor: Colors.yellow,
            iconSize: 30,
          )
        ],
      ),

    );
  }
}
