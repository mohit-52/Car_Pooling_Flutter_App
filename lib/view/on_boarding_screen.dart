import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../utils/utils.dart';
import 'home_screen.dart';

class OnBoardingScreen extends StatefulWidget {
  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  bool isLoading = false;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String? _selectedDepartment;
  String? _selectedYear;
  String? _ownVehicle;
  List<String> _departments = ['SET', 'BBA', 'LAW',];
  List<String> _year = ['1', '2', '3', '4'];

  //Firestore Db
  final usersRef = FirebaseFirestore.instance.collection('users');
  final _auth = FirebaseAuth.instance;



  @override
  void dispose() {
    // Dispose of the TextEditingController when the widget is disposed

    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_outlined),
          onPressed: () {
            // Add your search functionality here
            print('Search button pressed!');
          },
        ),
        centerTitle: true,
        title: Text('Car Pooling'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Center(
                child: Image.asset(
                  'assets/images/home_img.png',
                  // Replace this with your image path
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),



              TextFormField(
                controller: _nameController,
                maxLines: 1,
                decoration: const InputDecoration(
                    hintText: "Name", border: OutlineInputBorder()),
              ),
              SizedBox(
                height: 15,
              ), //UPI ID
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.emailAddress,
                maxLines: 1,
                decoration: const InputDecoration(
                    hintText: "Phone Number", border: OutlineInputBorder()),
              ),
              SizedBox(
                height: 15,
              ),

              TextFormField(
                controller: _addressController,
                keyboardType: TextInputType.text,
                maxLines: 1,
                decoration: const InputDecoration(
                    hintText: "Address", border: OutlineInputBorder()),
              ),
              SizedBox(
                height: 15,
              ),

              //BRANCH
              Row(
                children: [
                  Text("Branch:"),
                  SizedBox(
                    width: 15,
                  ),
                  DropdownButton(
                    value: _selectedDepartment,
                    items: _departments.map((String department) {
                      return DropdownMenuItem(
                        value: department,
                        child: Text(department),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedDepartment = newValue!;
                      });
                    },
                    hint: Text('Select Department'),
                  ),
                  SizedBox(height: 20),
                  // Text(
                  //   'Selected Department: ${_selectedDepartment ?? 'None'}',
                  //   style: TextStyle(fontSize: 20),
                  // ),
                ],
              ),

              // YEAR
              Row(
                children: [
                  Text("Year:"),
                  SizedBox(
                    width: 15,
                  ),
                  DropdownButton(
                    value: _selectedYear,
                    items: _year.map((String department) {
                      return DropdownMenuItem(
                        value: department,
                        child: Text(department),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedYear = newValue!;
                      });
                    },
                    hint: Text('Select Year'),
                  ),
                  SizedBox(height: 20),
                  // Text(
                  //   'Selected Department: ${_selectedDepartment ?? 'None'}',
                  //   style: TextStyle(fontSize: 20),
                  // ),
                ],
              ),

              //DO YOU HAVE VEHICLE
              Text('Do you have a vehicle?'),
              SizedBox(width: 20),
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

              SizedBox(
                height: 15,
              ),
              // NEXT BUTTON
              InkWell(
                onTap: (){
                  setState(() {
                    isLoading = true;
                  });
                  // print(_nameController.text.toString());
                  // print(_upiController.text.toString());
                  // print(_selectedYear?.toString());
                  // print(_selectedDepartment.toString());
                  // print(_ownVehicle.toString());
                  // String id = DateTime.now().millisecondsSinceEpoch.toString();
                  String uid = _auth.currentUser!.uid;
                  String uID = DateTime.now().millisecond.toString();
                  usersRef.doc(uID).set({
                    'id' : uID,
                    'name' : _nameController.text.toString(),
                    'phone' : _phoneController.text.toString(),
                    'address' : _addressController.text.toString(),
                    'department' : _selectedDepartment.toString(),
                    'year' : _selectedYear.toString(),
                    'ownVehicle' : _ownVehicle.toString(),
                  }).then((value) {
                    setState(() {
                      isLoading = false;
                    });
                    Utils().toastMessage("User Added Successfully!");
                  }).onError((error, stackTrace) {
                    setState(() {
                      isLoading = false;
                    });
                    print(error.toString());
                    Utils().toastMessage(error.toString());
                  }).then((value) {
                    setState(() {
                      isLoading = false;
                    });
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> MainHomePage()));
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
      ),
    );
  }
}
