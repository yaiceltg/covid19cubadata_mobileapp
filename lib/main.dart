import 'package:covid19_cuba/src/routes/routes.dart';
import 'package:flutter/material.dart';

void main() => runApp(Covid19CubaApp());

class Covid19CubaApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Covid19 Cuba Info',
      theme: ThemeData(
        // primaryColor: Color(0xFF2c3e50),
        primarySwatch: Colors.blue
        
      ),
      routes: getApplicationRoutes(),
      initialRoute: 'dashboard',
    );
  }
}
