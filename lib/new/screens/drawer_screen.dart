import 'package:car_pooling/new/screens/splash_screen.dart';
import 'package:car_pooling/new/global/global.dart';
import 'package:car_pooling/new/screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DrawerScreen extends StatefulWidget {
  const DrawerScreen({Key? key}) : super(key: key);

  @override
  State<DrawerScreen> createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser!;
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      child: Drawer(
        child: Padding(
          padding: EdgeInsets.fromLTRB(30, 50, 0, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.lightBlue,
                      shape: BoxShape.circle
                    ),
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20,),
                  Text(
                      "${userModelCurrentInfo!.name!}",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                      )
                  ),
                  SizedBox(height: 10,),

                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (c)=>ProfileScreen()));
                    },
                    child: Text(
                      "Edit Profile",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        color: Colors.blue
                      ),
                    ),
                  ),

                  SizedBox(height: 30,),

                  Text(
                    "Your Trips",
                    style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15
                    ),
                  ),
                  SizedBox(height: 15,),
                  Text(
                    "Payments",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15
                    ),
                  ),
                  SizedBox(height: 15,),

                  Text(
                    "Notifications",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15
                    ),
                  ),
                  SizedBox(height: 15,),

                  Text(
                    "Promos",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15
                    ),
                  ),
                  SizedBox(height: 15,),

                  Text(
                    "Help",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15
                    ),
                  ),
                  SizedBox(height: 15,),

                  Text(
                    "Free Trips",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15
                    ),
                  ),
                  SizedBox(height: 15,),

                ],
              ),

              GestureDetector(
                onTap: (){
                  firebaseAuth.signOut();
                  Navigator.push(context, MaterialPageRoute(builder: (c)=>SplashScreen()));
                },
                child: Text(
                  "Logout",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
