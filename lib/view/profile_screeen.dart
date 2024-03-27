import 'package:car_pooling/auth/authentication_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/utils.dart';


class ProfileScreen extends StatelessWidget {
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;
    final String uid = user!.uid;

    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Handle back button press
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white10, Colors.white10], // Add your desired colors here
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 1.5],
            tileMode: TileMode.mirror,
          ),
        ),
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting){
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text("Some Error Occurred!"));
            } else {
              if (snapshot.data!.exists) {
                Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                return Center(

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        child: CircleAvatar(
                          radius: 60,
                          // You can replace this with the user's image from Firestore if available
                          backgroundImage: AssetImage('assets/images/user.png',),
                          backgroundColor: Colors.redAccent,

                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        data['name'] ?? 'Name not available',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Phone: ${data['phone'] ?? 'Phone number not available'}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        data['department'] ?? 'Course not available',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),

                      // Illustration
                      Image.asset('assets/images/home_img.png', height: 200),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          _auth.signOut().then((value) {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => AuthScreen()));
                          }).onError((error, stackTrace) {
                            Utils().toastMessage(error.toString());
                          });
                        },
                        child: Text('Logout'),
                      ),
                    ],
                  ),
                );
              } else {
                return Text('No data available');
              }
            }
          },
        ),
      ),
    );
  }
}
