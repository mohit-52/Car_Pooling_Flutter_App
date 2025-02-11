import 'package:firebase_database/firebase_database.dart';

class UserModel{
  String? phone;
  String? name;
  String? id;
  String? email;
  String? address;
  String? postalCode;
  String? department;
  String? block;
  String? year;
  String? ownVehicle;

  UserModel({
   this.phone,
   this.name,
   this.id,
   this.email,
   this.address,
    this.postalCode,
    this.department,
    this.block,
    this.year,
    this.ownVehicle
});

  UserModel.fromSnapshot(DataSnapshot snap){
    phone = (snap.value as dynamic)["phone"];
    name = (snap.value as dynamic)["name"];
    id = snap.key;
    email = (snap.value as dynamic)["email"];
    address = (snap.value as dynamic)["address"];
    postalCode = (snap.value as dynamic)["postal_code"];
    department = (snap.value as dynamic)["department"];
    block = (snap.value as dynamic)["block"];
    year = (snap.value as dynamic)["year"];
    ownVehicle = (snap.value as dynamic)["ownVehicle"];

  }
}