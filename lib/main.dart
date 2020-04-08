import 'package:flutter/material.dart';
import 'package:flutterfirebase/pages/cloudFirestorePage.dart';
import 'pages/homePage.dart';
import 'pages/createUser.dart';
import 'pages/loginUser.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
 
final  String title="Firebase Auth";
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.purple,
      textTheme: TextTheme(bodyText1: TextStyle(fontSize:20))),
      initialRoute: "/",
      routes: {

    "/": (context) => CloudFirestorePage(title),

    //    "/": (context) => LoginUser(title),

        "/createUser": (context) => CreateUser(title),
        "/homePage": (context) => HomePage(title),
        "/loginUser": (context) => LoginUser(title),



      },
    );
  }
}
