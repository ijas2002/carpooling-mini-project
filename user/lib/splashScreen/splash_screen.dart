import 'dart:async';

import 'package:flutter/material.dart';
import 'package:users/assistance/assistant_method.dart';
import 'package:users/global/global.dart';
import 'package:users/screens/login_screens.dart';
import 'package:users/screens/main_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  startTimer(){
    Timer(Duration(seconds: 3),() async{
      if(await firebaseAuth.currentUser != null){
        firebaseAuth.currentUser != null ? AssistantMethods.readCurrentOnlineUserInfo() : null;
        Navigator.push(context,MaterialPageRoute(builder: (c)=>MainScreen()));
      }
      else{
        Navigator.push(context,MaterialPageRoute(builder: (c)=>LoginScreen()));

      }

    });
  }
  @override
  void initState(){
    super.initState();
    startTimer();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: const Text('Trippo Pooling',style: TextStyle(
            fontSize: 20,fontWeight: FontWeight.bold,color: Colors.lightBlue
        ),

        ),
      ),
    );
  }
}
