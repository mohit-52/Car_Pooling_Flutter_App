import 'package:car_pooling/auth/otp_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  _sendOtp(){
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
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding:  EdgeInsets.symmetric(horizontal: 15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 100,),
              Text("Share MyRide", style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),),
              Image(image: AssetImage("assets/images/auth_image.jpg"),),
              SizedBox(height: 20,),
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
                    hintText: "Phone Number",
                    hintStyle: TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: darkTheme
                        ? Colors.black45
                        : Colors.grey.shade200,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            40),
                        borderSide: BorderSide(
                            width: 0,
                            style: BorderStyle.none)),
                    prefixIcon: Icon(Icons.phone,
                        color: darkTheme
                            ? Colors.amber.shade400
                            : Colors.grey)),
              ),
              const SizedBox(
                height: 30,
              ),

              // NEXT BUTTON
              // InkWell(
              //
              //   child: Container(
              //     height: 50,
              //     decoration: BoxDecoration(
              //         color: Colors.redAccent,
              //         borderRadius: BorderRadius.circular(10)
              //     ),
              //     child:  Center(child: isLoading ? CircularProgressIndicator(strokeWidth: 3, color: Colors.white,) :  Text("Continue", style: TextStyle(color: Colors.white),)),
              //   ),
              // ),

              ElevatedButton(

                style: ElevatedButton.styleFrom(
                    foregroundColor: darkTheme ? Colors.black : Colors.white, backgroundColor: darkTheme
                        ? Colors.amber.shade400
                        : Colors.blue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          32),
                    ),
                    minimumSize: Size(double.infinity, 50)
                ),
                onPressed: (){
                  _sendOtp();
                },
                child: isLoading
                    ? CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                )
                    : Text("Send OTP", style: TextStyle(
                  fontSize: 20,
                ),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
