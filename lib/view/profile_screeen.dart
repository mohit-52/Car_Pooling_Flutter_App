import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth/authentication_screen.dart';
import '../utils/utils.dart';


class ProfileScreen extends StatelessWidget {
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;
    final String uid = user!.uid;

    return Scaffold(
      appBar: AppBar(
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
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Text("Some Error Occurred!");
          } else {
            if (snapshot.data!.exists) {
              Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    // You can replace this with the user's image from Firestore if available
                    backgroundImage: AssetImage('assets/images/user.png'),
                  ),
                  SizedBox(height: 16),
                  Text(
                    data['name'] ?? 'Name not available',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    data['department'] ?? 'Course not available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  // SizedBox(height: 16),
                  // Text(
                  //   'Phone: ${data['phone'] ?? 'Phone number not available'}',
                  //   style: TextStyle(
                  //     fontSize: 16,
                  //     color: Colors.blue,
                  //   ),
                  // ),
                  SizedBox(height: 32),
                  // Illustration
                  Image.asset('assets/images/home_img.png', height: 200),
                  SizedBox(height: 32),
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
              );
            } else {
              return Text('No data available');
            }
          }
        },
      ),
    );
  }
}