import 'package:car_pooling/view/otp_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../utils/utils.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLoading = false;
  final _phoneController = TextEditingController();
  var _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding:  EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 100,),
            Text("Share MyRide", style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),),
            SizedBox(height: 100,),
            Text("You'll receive a OTP to verify your number", style: TextStyle(fontSize: 15,),),
            // Phone Number
            const SizedBox(
              height: 20,
            ), //N
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              maxLines: 1,
              decoration: InputDecoration(
                  hintText: "Phone Number", border: OutlineInputBorder()),
            ),
            const SizedBox(
              height: 30,
            ),

            // NEXT BUTTON
            InkWell(
              onTap: (){
                setState(() {
                  isLoading = true;
                });
                _auth.verifyPhoneNumber(
                    phoneNumber: "+91${_phoneController.text}",
                    verificationCompleted: (_) {
                      setState(() {
                        isLoading = false;
                      });
                    },
                    verificationFailed: (e) {
                      setState(() {
                        isLoading = false;
                      });
                      Utils().toastMessage(e.toString());
                      print("Verification Failed");
                    },
                    codeSent: (String verificationId, int? token) {
                      setState(() {
                        isLoading = false;
                      });
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => OtpScreen(verifyCode: verificationId,)));
                    },
                    codeAutoRetrievalTimeout: (e) {
                      setState(() {
                        isLoading = false;
                      });
                      // Utils().toastMessage(e.toString());

                    });
              },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(10)
                ),
                child:  Center(child: isLoading ? CircularProgressIndicator(strokeWidth: 3, color: Colors.white,) :  Text("Continue", style: TextStyle(color: Colors.white),)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
