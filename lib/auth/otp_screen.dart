import 'package:car_pooling/auth/on_boarding_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../utils/utils.dart';

class OtpScreen extends StatefulWidget {
  final String verifyCode;
  const OtpScreen({Key? key, required this.verifyCode}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  bool isLoading = false;
  final _otpController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 100,),
              Text("Enter OTP", style: TextStyle(fontSize: 20),),
              Image(image: AssetImage("assets/images/otp_image.jpg")),
              SizedBox(height: 10,),
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.phone,
                maxLines: 1,
                decoration: InputDecoration(
                    hintText: "OTP", border: OutlineInputBorder()),
              ),
              const SizedBox(
                height: 30,
              ),

              // NEXT BUTTON
              InkWell(
                onTap: ()async {
                  setState(() {
                    isLoading = true;
                  });
                  final credential = PhoneAuthProvider.credential(
                      verificationId: widget.verifyCode,
                      smsCode: _otpController.text.toString());

                  try{
                    await _auth.signInWithCredential(credential);
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> OnBoardingScreen()));
                  }catch(e){
                    setState(() {
                      isLoading = false;
                    });
                    Utils().toastMessage(e.toString());
                  }
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
      ),
    );
  }
}
