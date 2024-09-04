import 'dart:async';

import 'package:communidrive/src/homepage.dart';
import 'package:communidrive/src/loginsignup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  String? pno = await getNumber();
  runApp(MyApp(
    phoneNumber: pno,
  ));
}

getNumber() async {
  final SharedPreferences sharedPreference =
      await SharedPreferences.getInstance();
  return sharedPreference.getString('PhoneNumber');
}

class MyApp extends StatelessWidget {
  final String? phoneNumber;
  const MyApp({super.key, required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: phoneNumber == null
            ? const PhoneNo()
            : HomePage(phoneNumber: phoneNumber!));
  }
}
