import 'package:flutter/material.dart';
import 'package:car_pooling/auth/authentication_screen.dart';
import 'package:car_pooling/splash_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'on_boarding_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  SplashServices splashServices = SplashServices();
  bool _logoVisible = false;

  @override
  void initState() {
    super.initState();
    _triggerLogoTransition();
    splashServices.isLogin(context);
  }

  void _triggerLogoTransition() {
    // Simulating a delay before showing the logo
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _logoVisible = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedOpacity(
              opacity: _logoVisible ? 1.0 : 0.0,
              duration: Duration(seconds: 1), // Duration of the transition
              child: Image.asset(
                'assets/images/car.jpg', // Replace this with your image path

                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Your Ride, Your Choice',
              style: TextStyle(
                color: Colors.black,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
