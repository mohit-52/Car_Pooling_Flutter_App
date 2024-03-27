import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'auth/authentication_screen.dart';
import 'view/home_screen.dart';

class SplashServices {
  void isLogin(BuildContext context) {
   final _auth = FirebaseAuth.instance;
   final user = _auth.currentUser;

   if(user != null){
     Timer(Duration(seconds: 3), () =>
         Navigator.push(context,
             MaterialPageRoute(
                 builder: (context) => MainHomePage()))
     );
   }else{
     Timer(Duration(seconds: 3), () =>
         Navigator.push(context,
             MaterialPageRoute(builder: (context) => const AuthScreen()))
     );
   }
  }
}