import 'package:firebase_database/firebase_database.dart';

class FutureRideList {
  String? from;
   String? to;
   String? date;
   String? time;
   String? id;


  FutureRideList({
     this.from,
     this.to,
     this.date,
    this.time,
    this.id
  });

  factory FutureRideList.fromMap(Map<String, dynamic> map ,String id) {
    return FutureRideList(
      id: map["id"],
      from: map['from'],
      to: map['to'],
      date: map['date'],
      time: map['time'],
    );
  }




}

