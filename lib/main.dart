import 'package:flutter/material.dart';

import 'log_in.dart';
import 'dart:developer' as devLog;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // The root of the application.
  @override
  Widget build(BuildContext context) {
    devLog.log('Log is working');
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}
class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('Spotify Recommendation App'),
        backgroundColor: Colors.green,
      ),
      body: Center(

        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.all(20), backgroundColor: Colors.green,
            ),
            child: const Text('Log in', style: TextStyle(fontSize:20)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LogIn()),
              );
            }
        ),
      ), // This trailing comma makes auto-formatting nicer f
    );
  }

}

