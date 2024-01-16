import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';

import '../models/Future_Ride_List.dart';

class DriverRideList extends StatefulWidget {
   String sourceLocation;
   DriverRideList({ required String this.sourceLocation});

  @override
  State<DriverRideList> createState() => _DriverRideListState();
}

class _DriverRideListState extends State<DriverRideList> {
  
  Query databaseRef = FirebaseDatabase.instance.ref().child("Future Rides");






  Widget listItem({required Map RideList}){
    return GestureDetector(
      onTap: (){
        print(RideList["booked"]);

      },
      child: Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(10),
        height: 135,
        color: Colors.lightBlue,
        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("from: ${RideList["from"]}",
              style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5,),
            Text("to: ${RideList["to"]}",
              style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5,),
            Text("date: ${RideList["date"]}",
              style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5,),
            Text("time: ${RideList["time"]}",
              style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
            ),

          ],
        ),
      ),
    );
  }

  Future<List<Map>> getDrivesFrom(String source) async {
    List<Map> drivesList = [];

    try {
      DataSnapshot snapshot = (await databaseRef
          .orderByChild("from")
          .equalTo(source)
          .once()).snapshot;



      if (snapshot.value != null) {
        Map<dynamic, dynamic> values = snapshot.value as Map;
        values.forEach((key, value) {
          Map rideList = value;
          rideList["key"] = key;
          drivesList.add(rideList);
        });
      }
    } catch (error) {
      print("...........Error retrieving drives: $error");
    }

    return drivesList;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Driver Ride List",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),),
      body: Container(
        height: double.infinity,
        child: FutureBuilder<List<Map>>(
          future: getDrivesFrom(widget.sourceLocation),
          builder: (context,snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text("Error: ${snapshot.error}"),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text("No drives found from the specified location."),
              );
            } else {
              List<Map> drivesList = snapshot.data!;
              print("...............................");
              print(drivesList);
              return ListView.builder(
                itemCount: drivesList.length,
                itemBuilder: (context, index) {
                  return listItem(RideList: drivesList[index]);
                },
              );
            }

          }
        ),
      ),

    );
  }
}
