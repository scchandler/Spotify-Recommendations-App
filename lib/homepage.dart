import 'dart:convert';

import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final Map<String, dynamic> userData; // Replace with your user data

  const HomePage({Key? key, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    JsonEncoder encoder = const JsonEncoder.withIndent('  '); // Create a JSON encoder with indentation

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spotify Recommendations'),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.lightGreen[300], // Set the background color to pale green
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'User Profile Data',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50.0),
                    child: Image.network('${userData['images'][0]['url']}'),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${userData['display_name']}', // Display pretty-printed JSON data
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text('Followers: ${userData['followers']['total']}'),
                    ],
                  ),
                ],
              )
            ],
          )
        ),
      ),
    );
  }
}
