/*

[Catindig-Cruz-Rada-Yncierto] 
UPLBeat: A Health Monitoring App
CMSC 23 Final Project 2S AY 22-23
[Section B-5L Sir Aldrin Hao] 

*/

import 'package:flutter/material.dart';

class UserDetailsPage extends StatefulWidget {
  const UserDetailsPage({super.key});
  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Details"),
      ),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.only(left: 40.0, right: 40.0),
          children: const <Widget>[
            Text(
              "Details",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25),
            ),
          ],
        ),
      ),
    );
  }
}
