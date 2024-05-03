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

  _verify()async{
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
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
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
                    hintText: "OTP",
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
                    prefixIcon: Icon(Icons.code,
                        color: darkTheme
                            ? Colors.amber.shade400
                            : Colors.grey)),
              ),
              const SizedBox(
                height: 30,
              ),

              // NEXT BUTTON
              ElevatedButton(
                onPressed: () {
                  _verify();
                },
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

                child: isLoading
                    ? CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                )
                    : Text("Verify", style: TextStyle(
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
