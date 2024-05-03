import 'package:car_pooling/new/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'new/infoHandler/app_info.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await FirebaseAppCheck.configure(
  //   provider: FirebaseAuth.instance,
  // );
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyC_KFVVHiJJVFaHqHUI6_ucPneK8REA3pY",
          appId: "1:97521800144:android:da7a0eda507d46309f9fd5",
          messagingSenderId: "97521800144",
          projectId: "car-pooling-413206"),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => AppInfo(),
    child: MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    ),);
  }
}
