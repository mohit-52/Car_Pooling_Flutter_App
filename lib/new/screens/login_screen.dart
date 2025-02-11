import 'package:car_pooling/auth/on_boarding_screen.dart';
import 'package:car_pooling/auth/splash_screen.dart';
import 'package:car_pooling/new/screens/forgot_password_screen.dart';
import 'package:car_pooling/new/screens/register_screen.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../global/global.dart';
import 'main_Screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailTextEditingController = TextEditingController();
  final passwordTextEditingController = TextEditingController();

  bool _passwordVisible = false;

  //Declare a GlobalKey
  final _formKey = GlobalKey<FormState>();

  void _submit() async {
    // Validate all the form fields
    if (_formKey.currentState!.validate()) {
      try {
        final authResult = await firebaseAuth.signInWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          password: passwordTextEditingController.text.trim(),
        );

        // Check if user authentication is successful
        if (authResult.user != null) {
          // Retrieve user data from Firebase Realtime Database
          DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users");
          DataSnapshot snapshot = (await userRef.child(authResult.user!.uid).once()) as DataSnapshot;

          // Check if user data exists
          if (snapshot.value != null) {
            currentUser = authResult.user;
            await Fluttertoast.showToast(msg: "Successfully Logged In");
            Navigator.push(context, MaterialPageRoute(builder: (c) => MainScreen()));
          } else {
            await firebaseAuth.signOut();
            await Fluttertoast.showToast(msg: "No record exists with this email");
            Navigator.push(context, MaterialPageRoute(builder: (c) => SplashScreen()));
          }
        } else {
          // Handle case where user authentication fails
          throw "User authentication failed";
        }
      } catch (error) {
        Fluttertoast.showToast(msg: "Error occurred: $error");
        print("Error occurred during sign-in: $error");
      }
    } else {
      Fluttertoast.showToast(msg: "Not all fields are valid");
    }
  }


  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery
            .of(context)
            .platformBrightness == Brightness.dark;
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          body: ListView(
            padding: EdgeInsets.all(0),
            children: [
              Column(
                children: [
                  Image.asset(darkTheme
                      ? 'assets/images/city_dark.jpg'
                      : 'assets/images/city.jpg'),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Login',
                    style: TextStyle(
                        color: darkTheme ? Colors.amber.shade400 : Colors
                            .blue,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 20, 15, 50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              //Email
                              TextFormField(
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(100)
                                ],
                                decoration: InputDecoration(
                                    hintText: "Email",
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
                                    prefixIcon: Icon(Icons.mail,
                                        color: darkTheme
                                            ? Colors.amber.shade400
                                            : Colors.grey)),
                                autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return "Email cann\'t be empty";
                                  }
                                  if (EmailValidator.validate(text) == true) {
                                    return null;
                                  }
                                  if (text.length < 2) {
                                    return "Please enter a valid Email";
                                  }
                                  if (text.length > 99) {
                                    return "Email can\'t be more than 50";
                                  }
                                },
                                onChanged: (text) =>
                                    setState(() {
                                      emailTextEditingController.text = text;
                                    }),
                              ),
                              SizedBox(
                                height: 20,
                              ),

                              //Password
                              TextFormField(
                                obscureText: !_passwordVisible,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(50)
                                ],
                                decoration: InputDecoration(
                                    hintText: "Password",
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
                                    prefixIcon: Icon(Icons.mail,
                                        color: darkTheme
                                            ? Colors.amber.shade400
                                            : Colors.grey),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _passwordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: darkTheme
                                            ? Colors.amber.shade400
                                            : Colors.grey,
                                      ),
                                      onPressed: () {
                                        // update the state i.e.e toggle the state of _passwordVisible variable
                                        setState(() {
                                          _passwordVisible =
                                          !_passwordVisible;
                                        });
                                      },
                                    )),
                                autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return "Password cann\'t be empty";
                                  }
                                  if (text.length < 6) {
                                    return "Please enter a valid Password";
                                  }
                                  if (text.length > 49) {
                                    return "Password can\'t be more than 50";
                                  }
                                  return null;
                                },
                                onChanged: (text) =>
                                    setState(() {
                                      passwordTextEditingController.text =
                                          text;
                                    }),
                              ),
                              SizedBox(
                                height: 20,
                              ),

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
                                  onPressed: () {
                                    _submit();
                                  },
                                  child: Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  )),

                              SizedBox(height: 20,),

                              GestureDetector(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (c)=>ForgotPasswordScreen()));

                                },
                                child: Text('Forgot Password,',
                                  style: TextStyle(
                                    color: darkTheme
                                        ? Colors.amber.shade400
                                        : Colors.grey,
                                  ),),
                              ),
                              SizedBox(height: 20,),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Don't Have an account?",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 15,
                                    ),),

                                  SizedBox(width: 5,),

                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (c)=>RegisterScreen()));

                                    },
                                    child: Text("Sign UP",
                                      style: TextStyle(
                                        color: darkTheme ? Colors.amber
                                            .shade400 : Colors.blue,
                                        fontSize: 15,
                                      ),),
                                  )
                                ],
                              )

                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              )
            ],
          )),
    );
  }
}
