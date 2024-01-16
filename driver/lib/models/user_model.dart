
import 'package:firebase_database/firebase_database.dart';

class UserModel{

  String? name;
  String? email;
  String? phone;
  String? address;
  String? id;

  UserModel({
    this.name,
    this.email,
    this.address,
    this.id,
    this.phone

  });


  UserModel.fromSnapShot(DataSnapshot snap){
    phone = (snap.value as dynamic)["phone"];
    name = (snap.value as dynamic)["name"];
    email = (snap.value as dynamic)["email"];
    address = (snap.value as dynamic)["address"];
    id =snap.key;
  }
}