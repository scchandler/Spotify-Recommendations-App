import 'dart:convert';

import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final Map<String, dynamic> userData; // Replace with your user data

  HomePage({Key? key, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    JsonEncoder encoder = JsonEncoder.withIndent('  '); // Create a JSON encoder with indentation

    return Scaffold(
      appBar: AppBar(
        title: Text('Spotify Recommendations'),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.lightGreen[300], // Set the background color to pale green
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'User Profile Data',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                encoder.convert(userData), // Display pretty-printed JSON data
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
