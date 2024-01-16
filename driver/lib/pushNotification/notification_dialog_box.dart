import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:drivers/assistance/assistant_method.dart';
import 'package:drivers/global/global.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../models/user_ride_request_information.dart';
import '../screens/new_trip_screen.dart';

class NotificationDialogBox extends StatefulWidget {
  UserRideRequestInformation? userRideRequestDetails;
   NotificationDialogBox({this.userRideRequestDetails});

  @override
  State<NotificationDialogBox> createState() => _NotificationDialogBoxState();
}

class _NotificationDialogBoxState extends State<NotificationDialogBox> {
  bool rideRequestAccepted = false;
  @override
  Widget build(BuildContext context) {

    if(rideRequestAccepted == true){
      return Container();
    }

    bool dartTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        margin: EdgeInsets.all(8),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: dartTheme? Colors.black : Colors.white,

        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              onlineDriverData.car_type == "Car"? "images/car.png":"images/bike.png"

            ),
            SizedBox(height: 10,),

            Text("New Ride Request",style: TextStyle(
              fontSize: 22,fontWeight: FontWeight.bold,
              color: dartTheme?Colors.amber.shade400 : Colors.blue
            ),),
            SizedBox(
              height: 14,
            ),
            Divider(
              height: 2,
                thickness: 2,
                color: dartTheme?Colors.amber.shade400 : Colors.blue
            ),

            Padding(padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Image.asset("images/origin.png",width: 30,height: 30,),
                    SizedBox(width: 10,),
                    Expanded(child: Container(
                      child: Text(
                        widget.userRideRequestDetails!.originAddress!,
                          style: TextStyle(
                              fontSize: 16,fontWeight: FontWeight.bold,
                              color: dartTheme?Colors.amber.shade400 : Colors.blue
                          )

                      ),
                    ))
                  ],
                ),

                SizedBox(height: 20,),
                Row(
                  children: [
                    Image.asset("images/destination.png",width: 30,height: 30,),
                    SizedBox(width: 10,),
                    Expanded(child: Container(
                      child: Text(
                          widget.userRideRequestDetails!.destinationAddress!,
                          style: TextStyle(
                              fontSize: 16,fontWeight: FontWeight.bold,
                              color: dartTheme?Colors.amber.shade400 : Colors.blue
                          )

                      ),
                    ))
                  ],
                )
              ],
            ),
            ),

            Divider(
              height: 2,
              thickness: 2,
                color: dartTheme?Colors.amber.shade400 : Colors.blue

            ),
            //button for cancelling and accepting ride request

            Padding(padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: (){
                  audioPlayer.pause();
                  audioPlayer.stop();
                  audioPlayer = AssetsAudioPlayer();

                  Navigator.pop(context);

                },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red
                    ),
                    child: Text("Cancel".toUpperCase(),style: TextStyle(fontSize: 15 ,color:Colors.white),) ),

                SizedBox(width:10,),

                ElevatedButton(onPressed: (){
                  audioPlayer.pause();
                  audioPlayer.stop();
                  audioPlayer = AssetsAudioPlayer();
                  acceptRideRequest(context);



                },
                    style: ElevatedButton.styleFrom(
                        primary: Colors.green
                    ),
                    child: Text("Accept".toUpperCase(),style: TextStyle(fontSize: 15 ,color: Colors.white),) ),
              ],
            ),)


          ],
        ),
      ),
    );
  }

  acceptRideRequest(BuildContext context){
    FirebaseDatabase.instance.ref().
    child("drivers").
    child(firebaseAuth.currentUser!.uid).
    child("newRideStatus").
    once().then((snap){
      if(snap.snapshot.value == "idle"){
        FirebaseDatabase.instance.ref().
        child("drivers").
        child(firebaseAuth.currentUser!.uid).
        child("newRideStatus").set("accepted");

        AssistantMethods.pauseLiveLocationUpdate();

        setState(() {
          rideRequestAccepted = true;
        });
        
        //trip started now send driver to trip screen
        Navigator.push(context,MaterialPageRoute(builder: (c)=>NewTripScreen(
          userRideRequestDetails: widget.userRideRequestDetails,
        )));

      }
      
      else{
        Fluttertoast.showToast(msg: "This Ride Request do not exists.");
      }
    });
  }
}
