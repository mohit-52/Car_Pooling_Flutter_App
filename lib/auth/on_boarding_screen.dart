import 'package:car_pooling/new/screens/forgot_password_screen.dart';
import 'package:car_pooling/new/screens/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../new/global/global.dart';
import '../new/screens/main_Screen.dart';
import '../utils/utils.dart';

enum UserType { student, faculty }

class OnBoardingScreen extends StatefulWidget {
  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  bool isLoading = false;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addressController = TextEditingController();
  final _postalCodeController = TextEditingController();

  String? _selectedDepartment;
  List<String> _departments = ['SET', 'BBA', 'LAW'];

  final _blockController = TextEditingController();


  UserType? _userType; // Newly added

  String? _selectedYear;
  List<String> _year = ['1', '2', '3', '4'];

  String? _ownVehicle;

  bool _passwordVisible = false;

  //Declare a GlobalKey
  final _formKey = GlobalKey<FormState>();

  void _submit() async {
    //validate all the form fields
    if (_formKey.currentState!.validate()) {
      await firebaseAuth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim()
      ).then((auth) async {
        currentUser = auth.user;

        if(currentUser!=null){
          Map userMap = {
            'id': currentUser!.uid,
            'name': _firstNameController.text.trim() + ' ' + _lastNameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'email': _emailController.text.trim(),
            'address': _addressController.text.trim(),
            'postal_code': _postalCodeController.text.trim(),
            'department': _selectedYear,
            'block': _blockController.text.trim(),
            'year': _selectedYear,
            'ownVehicle': _ownVehicle,
          };

          DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users");
          userRef.child(currentUser!.uid).set(userMap);

        }

        await Fluttertoast.showToast(msg: "Successfully Registered");
        Navigator.push(context, MaterialPageRoute(builder: (c)=>MainScreen()));
      }).catchError((errorMessage){
        Fluttertoast.showToast(msg: "Error occured: \n $errorMessage");
      });
    }
    else{
      Fluttertoast.showToast(msg: "Not all fields are valid");
    }
  }
  // _register(){
  //   if (_validateInputs()) {
  //     setState(() {
  //       isLoading = true;
  //     });
  //     // String id =  DateTime.now().millisecondsSinceEpoch.toString();
  //     String uid = _auth.currentUser!.uid;
  //     usersRef.doc(uid).set({
  //       'id': uid,
  //       'name': _firstNameController.text.trim() +
  //           ' ' +
  //           _lastNameController.text.trim(),
  //       'phone': _phoneController.text.trim(),
  //       'email': _emailController.text.trim(),
  //       'address': _addressController.text.trim(),
  //       'postal_code':
  //       _postalCodeController.text.trim(),
  //       'department': _selectedDepartment,
  //       'year': _selectedYear,
  //       'ownVehicle': _ownVehicle,
  //     }).then((_) {
  //       setState(() {
  //         isLoading = false;
  //       });
  //       Utils()
  //           .toastMessage("User Added Successfully!");
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(
  //             builder: (context) => MainHomePage()),
  //       );
  //     }).catchError((error) {
  //       setState(() {
  //         isLoading = false;
  //       });
  //       print(error.toString());
  //       Utils().toastMessage(error.toString());
  //     });
  //   }
  // }

  @override
  void dispose() {
    // Dispose of the TextEditingController when the widget is disposed
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Image
                Center(
                  child: Image.asset(
                    'assets/images/home_img.png',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),

                Text(
                  'Register',
                  style: TextStyle(
                      color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 20,
                ),

                Column(
                  children: [
                    Form(
                        key: _formKey,
                        child: Column(
                      children: [
                        // First Name and Last Name
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                maxLines: 1,
                                decoration: InputDecoration(
                                    hintText: "First Name",
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
                                    return "First Name cann\'t be empty";
                                  }
                                  if (text.length < 2) {
                                    return "Please enter a valid first name";
                                  }
                                  if (text.length > 49) {
                                    return "Name can\'t be more than 50";
                                  }
                                },
                                onChanged: (text) =>
                                    setState(() {
                                      _firstNameController.text = text;
                                    }),
                              ),
                            ),
                            SizedBox(width: 10),

                            Expanded(
                              child: TextFormField(
                                maxLines: 1,
                                decoration: InputDecoration(
                                    hintText: "Last Name",
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
                                    return "Last Name cann\'t be empty";
                                  }
                                  if (text.length < 2) {
                                    return "Please enter a valid last name";
                                  }
                                  if (text.length > 49) {
                                    return "Last Name can\'t be more than 50";
                                  }
                                },
                                onChanged: (text) =>
                                    setState(() {
                                      _lastNameController.text = text;
                                    }),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),

                        // Phone Number
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
                                _phoneController.text =
                                    text.completeNumber;
                              }),
                        ),
                        SizedBox(height: 15),

                        // Email Address
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
                                _emailController.text = text;
                              }),
                        ),
                        SizedBox(height: 20),

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
                                _passwordController.text =
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
                            if (text != _passwordController.text.trim()) {
                              return "Passwords do not match";
                            }
                            if (text.length > 49) {
                              return "Confirm Password can\'t be more than 50";
                            }
                            return null;
                          },
                          onChanged: (text) =>
                              setState(() {
                                _confirmPasswordController.text =
                                    text;
                              }),
                        ),
                        SizedBox(
                          height: 20,
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
                              prefixIcon: Icon(Icons.location_city,
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
                                _addressController.text =
                                    text;
                              }),
                        ),
                        SizedBox(
                          height: 20,
                        ),

                        // Postal Code
                        TextFormField(
                          controller: _postalCodeController,
                          keyboardType: TextInputType.number,
                          maxLines: 1,
                          decoration: InputDecoration(
                              hintText: "PIN Code",
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
                              prefixIcon: Icon(Icons.location_on_outlined,
                                  color: darkTheme
                                      ? Colors.amber.shade400
                                      : Colors.grey)),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your postal code';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15),

                        // Department
                        Row(
                          children: [
                            Text("Department:"),
                            SizedBox(width: 15),
                            DropdownButton<String>(
                              borderRadius: BorderRadius.circular(30),

                              value: _selectedDepartment,
                              items: _departments.map((department) {
                                return DropdownMenuItem<String>(
                                  value: department,
                                  child: Text(department),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedDepartment = newValue;
                                });
                              },
                              hint: Text('Select Department'),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),

                        //Block
                        TextFormField(
                          controller: _blockController,
                          keyboardType: TextInputType.text,
                          maxLines: 1,
                          maxLength: 1,
                          decoration: InputDecoration(
                              hintText: "Block",
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
                              prefixIcon: Icon(Icons.location_on_outlined,
                                  color: darkTheme
                                      ? Colors.amber.shade400
                                      : Colors.grey)),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your block';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),

                        // User Type
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("User Type"),
                            Row(
                              children: [
                                Radio<UserType>(
                                  value: UserType.student,
                                  groupValue: _userType,
                                  onChanged: (UserType? value) {
                                    setState(() {
                                      _userType = value;
                                    });
                                  },
                                ),
                                Text("Student"),
                                SizedBox(width: 20),
                                Radio<UserType>(
                                  value: UserType.faculty,
                                  groupValue: _userType,
                                  onChanged: (UserType? value) {
                                    setState(() {
                                      _userType = value;
                                    });
                                  },
                                ),
                                Text("Faculty"),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 20),

                        // Year
                        Row(
                          children: [
                            Text("Year:"),
                            SizedBox(width: 15),
                            DropdownButton<String>(
                              borderRadius: BorderRadius.circular(30),
                              value: _selectedYear,
                              items: _year.map((year) {
                                return DropdownMenuItem<String>(
                                  value: year,
                                  child: Text(year),
                                );
                              }).toList(),
                              onChanged: (_userType == UserType.faculty)
                                  ? null
                                  : (newValue) {
                                      setState(() {
                                        _selectedYear = newValue;
                                      });
                                    },
                              hint: Text('Select Year'),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),

                        // Do you have a vehicle?
                        Text('Do you have a vehicle?'),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Radio<String>(
                              value: 'Yes',
                              groupValue: _ownVehicle,
                              onChanged: (value) {
                                setState(() {
                                  _ownVehicle = value;
                                });
                              },
                            ),
                            Text('Yes'),
                            SizedBox(width: 20),
                            Radio<String>(
                              value: 'No',
                              groupValue: _ownVehicle,
                              onChanged: (value) {
                                setState(() {
                                  _ownVehicle = value;
                                });
                              },
                            ),
                            Text('No'),
                          ],
                        ),
                        SizedBox(height: 15),

                        // Next Button
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
                          child: isLoading
                              ? CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                )
                              : Text("Register", style: TextStyle(
                            fontSize: 20,
                          ),),
                        ),

                        SizedBox(height: 20,),

                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (c)=> ForgotPasswordScreen()));
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
                                Navigator.push(context, MaterialPageRoute(builder: (c)=> LoginScreen()));
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
                    ))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _validateInputs() {
    if (_firstNameController.text.isEmpty) {
      Utils().toastMessage("Please enter your first name");
      return false;
    }
    if (_firstNameController.text.contains(" ")) {
      Utils().toastMessage("Please enter your first name only");
      return false;
    }
    if (_lastNameController.text.isEmpty) {
      Utils().toastMessage("Please enter your last name");
      return false;
    }
    if (_lastNameController.text.contains(" ")) {
      Utils().toastMessage("Please enter your first name only");
      return false;
    }
    if (_phoneController.text.isEmpty) {
      Utils().toastMessage("Please enter your phone number");
      return false;
    }
    if (!RegExp(r'^[0-9]{10}$').hasMatch(_phoneController.text)) {
      Utils().toastMessage("Please enter a valid phone number");
      return false;
    }
    if (_emailController.text.isEmpty) {
      Utils().toastMessage("Please enter your email address");
      return false;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(_emailController.text)) {
      Utils().toastMessage("Please enter a valid email address");
      return false;
    }
    if (_addressController.text.isEmpty) {
      Utils().toastMessage("Please enter your address line 1");
      return false;
    }
    if (_postalCodeController.text.isEmpty) {
      Utils().toastMessage("Please enter your postal code");
      return false;
    }
    if (_selectedDepartment == null) {
      Utils().toastMessage("Please select your department");
      return false;
    }

    if (_userType == null) {
      Utils().toastMessage("Please enter your year");
      return false;
    }
    if (_ownVehicle == null) {
      Utils().toastMessage("Do you have a vehicle? Please Select!!");
      return false;
    }

    return true;
  }
}
