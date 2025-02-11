import 'dart:async';
import 'package:car_pooling/new/assistants/assistant_methods.dart';
import 'package:car_pooling/new/global/global.dart';
import 'package:car_pooling/new/screens/login_screen.dart';
import 'package:car_pooling/new/screens/main_Screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  startTimer(){
    Timer(Duration(seconds: 3), () async{
      if(await firebaseAuth.currentUser!=null){
        firebaseAuth.currentUser !=null? AssistantMethods.readCurrentOnlineUserInfo():null;
        Navigator.push(context, MaterialPageRoute(builder: (c)=> MainScreen()));
      }else{
        Navigator.push(context, MaterialPageRoute(builder: (c)=> LoginScreen()));

      }
    });
  }


  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Trippy Ride",
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold
        ),),
      ),
    );
  }
}
