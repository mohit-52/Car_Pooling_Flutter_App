import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../utils/utils.dart';



class FindRideScreen extends StatefulWidget {
  @override
  State<FindRideScreen> createState() => _FindRideScreenState();
}

class _FindRideScreenState extends State<FindRideScreen> {
  final searchFilterController = TextEditingController();

  final _auth = FirebaseAuth.instance;

  final firestore = FirebaseFirestore.instance.collection('users').snapshots();

  final ref = FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text(
            'Search Ride',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: TextFormField(
                  controller: searchFilterController,
                  decoration: InputDecoration(
                      hintText: "Search", border: OutlineInputBorder()),
                  onChanged: (String value) {
                    setState(() {});
                  },
                ),
              ),
              SizedBox(height: 10,),
              StreamBuilder(
                  stream: firestore,
                  builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot){
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return Shimmer.fromColors(
                          baseColor: Colors.grey.shade700,
                          highlightColor: Colors.grey.shade100,
                          child: Column(
                            children: [
                              ListTile(
                                leading: Container(
                                  height: 50,
                                  width: 50,
                                  color: Colors.white,
                                ),
                                title: Container(
                                  height: 10,
                                  width: 89,
                                  color: Colors.white,
                                ),
                                subtitle: Container(
                                  height: 10,
                                  width: 89,
                                  color: Colors.white,
                                ),
                              )
                            ],
                          ));                }
                    else if (snapshot.hasError){
                      Utils().toastMessage("Some Error");
                    }

                    return    Expanded(
                      flex: 1,
                      child: ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index){
                            String title = snapshot.data!.docs[index]['name'].toString();
                            String phone = snapshot.data!.docs[index]['phone'].toString();
                            String address = snapshot.data!.docs[index]['address'].toString();
                            if(searchFilterController.text.isEmpty){
                              return Column(
                                children: [
                                  ListTile(
                                    title: Text(title),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Phone: "+phone),
                                        Text("Address: "+address),
                                      ],
                                    ),
                                  ),
                                  Divider()
                                ],
                              );
                            }else if(address.toLowerCase().contains(searchFilterController.text.toLowerCase())||title.toLowerCase().contains(searchFilterController.text.toLowerCase())){
                              return ListTile(
                                title: Text(title),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Phone: "+phone),
                                    Text("Address: "+address),
                                  ],
                                ),
                              );
                            }else {
                              return Container();
                            }
                          }),
                    );

                  }),

            ],
          ),
        ),
      );
  }

  Widget _buildRideOption(
      String driverName,
      String contactNumber,
      String vehicleNumber,
      int fare,
      ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.blueAccent, // Border color
          width: 2.0, // Border width
        ),
        borderRadius: BorderRadius.circular(8.0), // Optional: Add rounded corners
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    driverName,
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    '$contactNumber ',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    '$vehicleNumber',
                    style: TextStyle(fontSize: 30),
                  ),
                  Divider(),

                ],
              ),


              Text(
                '₹$fare',
                style: TextStyle(fontSize: 50),
              ),
            ],
          ),
          Divider(),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(

                onPressed: () {
                  // Handle confirming the ride and payment
                },
                child: Text('Call'),
              ),
              ElevatedButton(

                onPressed: () {
                  // Handle confirming the ride and payment
                },
                child: Text('PAY AND CONFIRM'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
