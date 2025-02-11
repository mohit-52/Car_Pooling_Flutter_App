import 'package:car_pooling/new/global/global.dart';
import 'package:car_pooling/new/screens/forgot_password_screen.dart';
import 'package:car_pooling/new/screens/login_screen.dart';
import 'package:car_pooling/new/screens/main_Screen.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameTextEditingController = TextEditingController();
  final emailTextEditingController = TextEditingController();
  final phoneTextEditingController = TextEditingController();
  final addressTextEditingController = TextEditingController();
  final passwordTextEditingController = TextEditingController();
  final confirmTextEditingController = TextEditingController();

  bool _passwordVisible = false;

  //Declare a GlobalKey
  final _formKey = GlobalKey<FormState>();

  void _submit() async {
    //validate all the form fields
    if (_formKey.currentState!.validate()) {
      print("Form Validated");
      try {
        final authResult = await firebaseAuth.createUserWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          password: passwordTextEditingController.text.trim(),
        );

        currentUser = authResult.user;
        print("User Created Successfully!!");

        if(currentUser != null){
          Map<String, dynamic> userMap = {
            "id" : currentUser!.uid,
            "name" : nameTextEditingController.text.trim(),
            "email" : emailTextEditingController.text.trim(),
            "address" : addressTextEditingController.text.trim(),
            "phone" : phoneTextEditingController.text.trim(),
          };

          DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users");
          await userRef.child(currentUser!.uid).set(userMap).then((snap) {});
          print("User Added to DB");
        }

        Fluttertoast.showToast(msg: "Successfully Registered");
        Navigator.push(context, MaterialPageRoute(builder: (c)=>MainScreen()));
      } catch (error) {
        Fluttertoast.showToast(msg: "Error occurred: $error");
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
        onTap: () {
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
                      'Register',
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
                                //Name
                                TextFormField(
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(50)
                                  ],
                                  decoration: InputDecoration(
                                      hintText: "Name",
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
                                      prefixIcon: Icon(Icons.person,
                                          color: darkTheme
                                              ? Colors.amber.shade400
                                              : Colors.grey)),
                                  autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                                  validator: (text) {
                                    if (text == null || text.isEmpty) {
                                      return "Name cann\'t be empty";
                                    }
                                    if (text.length < 2) {
                                      return "Please enter a valid name";
                                    }
                                    if (text.length > 49) {
                                      return "Name can\'t be more than 50";
                                    }
                                  },
                                  onChanged: (text) =>
                                      setState(() {
                                        nameTextEditingController.text = text;
                                      }),
                                ),
                                SizedBox(
                                  height: 20,
                                ),

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

                                //Phone
                                IntlPhoneField(
                                  showCountryFlag: true,
                                  dropdownIcon: Icon(Icons.arrow_drop_down,
                                      color: darkTheme
                                          ? Colors.amber.shade400
                                          : Colors.grey),
                                  decoration: InputDecoration(
                                    hintText: "Phone",
                                    hintStyle: TextStyle(color: Colors.grey),
                                    filled: true,
                                    fillColor: darkTheme
                                        ? Colors.black45
                                        : Colors.grey.shade200,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(40),
                                        borderSide: BorderSide(
                                            width: 0, style: BorderStyle.none)),
                                  ),
                                  initialCountryCode: 'IN',
                                  onChanged: (text) =>
                                      setState(() {
                                        phoneTextEditingController.text =
                                            text.completeNumber;
                                      }),
                                ),
                                SizedBox(
                                  height: 10,
                                ),

                                //Address
                                TextFormField(
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(100)
                                  ],
                                  decoration: InputDecoration(
                                      hintText: "Address",
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
                                      return "Address cann\'t be empty";
                                    }
                                    if (text.length < 2) {
                                      return "Please enter a valid Address";
                                    }
                                    if (text.length > 99) {
                                      return "Address can\'t be more than 50";
                                    }
                                  },
                                  onChanged: (text) =>
                                      setState(() {
                                        addressTextEditingController.text =
                                            text;
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

                                // Confirm Password
                                TextFormField(
                                  obscureText: !_passwordVisible,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(50)
                                  ],
                                  decoration: InputDecoration(
                                      hintText: "Confirm Password",
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
                                      return "Confirm Password cann\'t be empty";
                                    }
                                    if (text.length < 6) {
                                      return "Please enter a valid Confirm Password";
                                    }
                                    if (text != passwordTextEditingController.text.trim()) {
                                      return "Passwords do not match";
                                    }
                                    if (text.length > 49) {
                                      return "Confirm Password can\'t be more than 50";
                                    }
                                    return null;
                                  },
                                  onChanged: (text) =>
                                      setState(() {
                                        confirmTextEditingController.text =
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
                                      'Register',
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
                                    Text("Have an account?",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 15,
                                      ),),

                                    SizedBox(width: 5,),

                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (c)=>LoginScreen()));

                                      },
                                      child: Text("Sign In",
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
            )));
  }
}
