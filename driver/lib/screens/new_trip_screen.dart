import 'dart:async';

import 'package:drivers/assistance/assistant_method.dart';
import 'package:drivers/global/global.dart';
import 'package:drivers/models/user_ride_request_information.dart';
import 'package:drivers/splashScreen/splash_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../widgets/far_amount_collection_dialog.dart';
import '../widgets/progress_dialog.dart';


class NewTripScreen extends StatefulWidget {

  UserRideRequestInformation? userRideRequestDetails;

  NewTripScreen({this.userRideRequestDetails});

  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {

  GoogleMapController? newTripGoogleMapControler;
  final Completer <GoogleMapController> _controllerGoogleMap = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  String? buttonTitle = "Arrived";
  Color? buttonColor= Colors.red;

  Set<Marker> setOfMarkers = Set<Marker>();
  Set<Circle> setOfCircle = Set<Circle>();
  Set<Polyline> setOfPolyline = Set<Polyline>();

  List<LatLng> polyLinePositionCoordinates=[];

  PolylinePoints polylinePoints = PolylinePoints();

  double mapPadding =0;

  BitmapDescriptor? iconAnimatedMarker;
  var geoLocator = Geolocator();

  Position? onlineDriverCurrentPosition;

  String rideRequestStatus = "accepted";

  String durationFromOriginToDestination="";

  bool isRequestDirectionDetails = false;

  //when driver accepts user ride request
  //originLatLng = drivers current locaton
  //destinationLatlng = user pickup location

  //step 2: when driver picksup user in his car
//originLatlng = user current location whicj will be current location of the driver
  Future <void> drawPolyLineFromOriginToDestination(LatLng originLatLng,LatLng destinationLatLng,bool darkTheme)async{
    showDialog(context: context, builder: (BuildContext context)=>ProgressDialog(message : "Please Wait"));

    var directionDetailsInfo = await AssistantMethods.obtainOriginToDestinationDirectionDetails(originLatLng, destinationLatLng);

    Navigator.pop(context);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResultList = pPoints.decodePolyline(directionDetailsInfo.e_points!);

    polyLinePositionCoordinates.clear();
    if(decodedPolyLinePointsResultList.isNotEmpty){
      decodedPolyLinePointsResultList.forEach((PointLatLng pointLatLng){

        polyLinePositionCoordinates.add(LatLng(pointLatLng.latitude,pointLatLng.longitude));

      });
    }

    setOfPolyline.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: darkTheme?Colors.amber:Colors.blue,

          polylineId: PolylineId("PolylineID"),
        jointType: JointType.round,
        points: polyLinePositionCoordinates,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        width: 5

      );
      setOfPolyline.add(polyline);
    });

    LatLngBounds boundsLatLng;

    if(originLatLng.latitude>destinationLatLng.latitude && originLatLng.longitude > destinationLatLng.longitude){
      boundsLatLng = LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    }
    else if(originLatLng.longitude > destinationLatLng.longitude){

      boundsLatLng = LatLngBounds(
          southwest: LatLng(originLatLng.latitude,destinationLatLng.longitude),
          northeast: LatLng(destinationLatLng.latitude,originLatLng.longitude));

    }
    else if(originLatLng.latitude > destinationLatLng.latitude){
      boundsLatLng = LatLngBounds(
          southwest: LatLng(destinationLatLng.latitude,originLatLng.longitude),
          northeast: LatLng(originLatLng.latitude,destinationLatLng.longitude),

      );
    }
    else{
      boundsLatLng = LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }
    
    newTripGoogleMapControler!.animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng,65));

    Marker originMarker = Marker(
      markerId: MarkerId("originID"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId("destinationID"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
    setState(() {
      setOfMarkers.add(originMarker);
      setOfMarkers.add(destinationMarker);

    });

    Circle originCircle = Circle(
      circleId: CircleId("originID"),
      fillColor: Colors.green,
      radius:12,
      strokeColor: Colors.blue,
      center: originLatLng,
      strokeWidth: 3
    );

    Circle destinationCircle = Circle(
        circleId: CircleId("destinationID"),
        fillColor: Colors.green,
        radius:12,
        strokeColor: Colors.blue,
        center: destinationLatLng,
        strokeWidth: 3
    );
    setState(() {
      setOfCircle.add(originCircle);
      setOfCircle.add(destinationCircle);

    });
  }


@override
  void initState() {
    // TODO: implement initState
    super.initState();
    saveAssignedDriverDetailsToUserRideRequest();
  }


  getDriverLocationUpdateAtRealTime(){

    LatLng oldLatLng =LatLng(0, 0);


    streamSubscriptionDriverLivePosition = Geolocator.getPositionStream().listen((Position position) {
      driverCurrentPosition = position;
      onlineDriverCurrentPosition = position;
      LatLng latLngLiveDriverPosition = LatLng(onlineDriverCurrentPosition!.latitude,onlineDriverCurrentPosition!.longitude);

      Marker animatingMarker = Marker(
        markerId: MarkerId("AnimatedMarker"),
        position: latLngLiveDriverPosition,
        icon: iconAnimatedMarker!,
        infoWindow: InfoWindow(title: "This is your position")

      );

      setState(() {
        CameraPosition cameraPosition = CameraPosition(target: latLngLiveDriverPosition,zoom:18);
         newTripGoogleMapControler!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
         
         setOfMarkers.remove((element)=>element.markerId.value == "AnimatedMarker");
         
         setOfMarkers.add(animatingMarker);
      });

      oldLatLng = latLngLiveDriverPosition;
      updateDurationTimeAtRealTime();

      Map driverLatLngDataMap = {
        "latitude":onlineDriverCurrentPosition!.latitude.toString(),
        "longitude":onlineDriverCurrentPosition!.longitude.toString()

      };
      
      FirebaseDatabase.instance.ref().child("All Ride Requests").child(widget.userRideRequestDetails!.rideRequestId!).child("driverLocation").set(driverLatLngDataMap);

    });
  }

  updateDurationTimeAtRealTime() async{

    if(isRequestDirectionDetails == false){
      isRequestDirectionDetails = true;
      if(onlineDriverCurrentPosition == null){
        return;
      }
      var originLatLng = LatLng(onlineDriverCurrentPosition!.latitude, onlineDriverCurrentPosition!.longitude);

      var destinationLatLng;

      if(rideRequestStatus == "accepted"){

        destinationLatLng = widget.userRideRequestDetails!.originLatLng;

      }
      else{
        destinationLatLng = widget.userRideRequestDetails!.destinationLatLng;
      }
      
      var directionInformation = await AssistantMethods.obtainOriginToDestinationDirectionDetails(originLatLng, destinationLatLng);

      if(directionInformation != null){
        setState(() {
          durationFromOriginToDestination = directionInformation.duration_text!;
        });
      }

      isRequestDirectionDetails=false;
    }

  }


  createDriverIconMarker(){
    if(iconAnimatedMarker == null){
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(context,size: Size(2,2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/car.png").then((value){
        iconAnimatedMarker = value;
      });
    }
  }

  saveAssignedDriverDetailsToUserRideRequest(){

    DatabaseReference dataBaseReference = FirebaseDatabase.instance.ref().child("All Ride Requests").child(widget.userRideRequestDetails!.rideRequestId!);
    Map driverLocationDataMap ={
    "latitude":driverCurrentPosition!.latitude.toString(),
      "longitude":driverCurrentPosition!.longitude.toString()

    };
    if(dataBaseReference.child("driverId") != "waiting"){
      dataBaseReference.child("driverLocation").set(driverLocationDataMap);
      
      dataBaseReference.child("status").set("accepted");
      dataBaseReference.child("driverId").set(onlineDriverData.id);
      dataBaseReference.child("driverName").set(onlineDriverData.name);
      dataBaseReference.child("driverPhone").set(onlineDriverData.phone);
      dataBaseReference.child("ratings").set(onlineDriverData.ratings);
      dataBaseReference.child("car_details").set(onlineDriverData.car_model.toString()+" "+onlineDriverData.car_number.toString()+" ("+onlineDriverData.car_color.toString()+")");


      saveRideRequestIdToDriverHistory();
    }
    else{
      Fluttertoast.showToast(msg: "This ride is already accepted by another driver \n Reloading the app");
      Navigator.push(context, MaterialPageRoute(builder: (c)=>SplashScreen()));
    }



  } 

  saveRideRequestIdToDriverHistory(){
    DatabaseReference tripHistoryRef = FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid).child("tripHistory");
    tripHistoryRef.child(widget.userRideRequestDetails!.rideRequestId!).set(true);
  }

  endTripNow() async {
    showDialog(context: context,
        barrierDismissible: false,
        builder: (BuildContext context)=>ProgressDialog(message: "Please wait..",));

    //get the tripDirectionDetails = distanve travelled

    var currentDriverPositionLatLng = LatLng(onlineDriverCurrentPosition!.latitude,onlineDriverCurrentPosition!.longitude);
    print("do yooooo ...${currentDriverPositionLatLng}");

    var tripDirectionDetails = await AssistantMethods.obtainOriginToDestinationDirectionDetails(currentDriverPositionLatLng,widget.userRideRequestDetails!.originLatLng!);

    print("do user ride request details ...${widget.userRideRequestDetails!.originLatLng!}");
    //fare amount
    
    double totalFareAmount = AssistantMethods.calculateFareAmountFromOriginToDestination(tripDirectionDetails);

    FirebaseDatabase.instance.ref().child("All Ride Requests").child(widget.userRideRequestDetails!.rideRequestId!).child("fareAmount").set(totalFareAmount.toString());

    // FirebaseDatabase.instance.ref().child("All Ride Requests").child(widget.userRideRequestDetails!.rideRequestId!).child("status").set(rideRequestStatus);
    FirebaseDatabase.instance.ref().child("All Ride Requests").child(widget.userRideRequestDetails!.rideRequestId!).child("status").set("ended");

    Navigator.pop(context);

    //display fare amount in dialog box

    showDialog(
        context: context,
        builder: (BuildContext context)=>FareAmountCollectionDialog(
          totalFareAmount: totalFareAmount,
        )
    );

    //save fare amount to driver total earning

    saveFareAmountToDriverEarnings(totalFareAmount);

  }

  saveFareAmountToDriverEarnings(double totalFareAmount){
    
    FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid).child("earnings").once().then((snap){
      if(snap.snapshot.value != null){
        double oldEarnings = double.parse(snap.snapshot.value.toString());
        double driverTotalEarnings = totalFareAmount +oldEarnings;
        
        FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid).child("earnings").set(driverTotalEarnings.toString());
      }
      else{
        FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid).child("earnings").set(totalFareAmount.toString());




      }
    });

  }

  @override
  Widget build(BuildContext context) {

    createDriverIconMarker();
    bool darkTheme = MediaQuery.of(context).platformBrightness==Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom:mapPadding ),
              mapType: MapType.normal,
              myLocationButtonEnabled: true,
              initialCameraPosition: _kGooglePlex,
            markers: setOfMarkers,
            circles: setOfCircle,
            polylines: setOfPolyline,
            onMapCreated: (GoogleMapController controller){
              _controllerGoogleMap.complete(controller);
              newTripGoogleMapControler = controller;
              setState(() {
                mapPadding=350;

              });
              var driverCurrentLatLng = LatLng(driverCurrentPosition!.latitude,driverCurrentPosition!.longitude);

              var userPickUpLatLng = widget.userRideRequestDetails!.originLatLng;

              drawPolyLineFromOriginToDestination(driverCurrentLatLng,userPickUpLatLng!,darkTheme);
              getDriverLocationUpdateAtRealTime();
            },
          ),
          
          Positioned(
            bottom: 0,
              left: 0,
              right: 0,

              child: Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: darkTheme? Colors.black : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow:[ BoxShadow(
                      color: Colors.white,
                      blurRadius: 18,
                      spreadRadius: 0.5,
                      offset: Offset(0.6,0.6)

                    )]
                  ),

                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Text(
                          durationFromOriginToDestination,style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: darkTheme?Colors.amber.shade400:Colors.blue
                        ),
                        ),SizedBox(height: 10,),

                        Divider(thickness: 1,color: darkTheme?Colors.amber.shade400 : Colors.grey,),

                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                            Text(
                              widget.userRideRequestDetails!.userName!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                  color: darkTheme?Colors.amber.shade400 : Colors.black
                              ),
                            ),
                            IconButton(onPressed: (){

                            }, icon: Icon(Icons.phone,
                                color: darkTheme?Colors.amber.shade400 : Colors.black))
                          ],
                        ),

                        SizedBox(height: 10,),
                        Row(
                          children: [
                            Image.asset("images/origin.png",
                            width: 30,
                            height: 30,),
                            SizedBox(width: 10,),
                            Expanded(child: Container(child: Text(widget.userRideRequestDetails!.originAddress!,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: darkTheme?Colors.amber.shade400 : Colors.black
                              ),),))
                          ],

                        ),
                        SizedBox(height: 10,),
                        Row(
                          children: [
                            Image.asset("images/destination.png",
                              width: 30,
                              height: 30,),
                            SizedBox(width: 10,),
                            Expanded(child: Container(child: Text(widget.userRideRequestDetails!.destinationAddress!,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: darkTheme?Colors.amber.shade400 : Colors.black
                              ),),))
                          ],

                        ),

                        SizedBox(height: 10,),

                        Divider(
                          thickness: 1,
                            color: darkTheme?Colors.amber.shade400 : Colors.grey,

                        ),

                        SizedBox(height: 10,),

                        ElevatedButton.icon(onPressed: () async{


                          //driver has arrived at user PickUp location
                          
                          if(rideRequestStatus == "accepted"){
                            rideRequestStatus = "arrived";

                            FirebaseDatabase.instance.ref().child("All Ride Requests").child(widget.userRideRequestDetails!.rideRequestId!).child("status").set(rideRequestStatus);

                            setState(() {
                              buttonTitle = "Lets's Go";
                              buttonColor = Colors.lightGreen;
                            });

                            showDialog(context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context)=>ProgressDialog(message: "Loading...",
                                ));

                            await drawPolyLineFromOriginToDestination(
                                widget.userRideRequestDetails!.originLatLng!,
                                widget.userRideRequestDetails!.destinationLatLng!,
                                darkTheme);

                            Navigator.pop(context);

                          }

                          //user has beem pickedup from the users current location - lets go button

                          else if(rideRequestStatus=="arrived"){
                            rideRequestStatus="ontrip";

                            FirebaseDatabase.instance.ref().child("All Ride Requests").child(widget.userRideRequestDetails!.rideRequestId!).child("status").set(rideRequestStatus);

                            setState(() {
                              buttonTitle = "End Trip";
                              buttonColor = Colors.red;
                            });


                          }
                          //suppose user and driver reach dropof locaton
                          else if(rideRequestStatus == "ontrip"){
                            print(".................its on trip..................");

                            endTripNow();
                          }


                        },
                          icon:Icon(Icons.directions_car,color: darkTheme?Colors.black : Colors.white,size: 25,),
                          label: Text(buttonTitle!,style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              color: darkTheme?Colors.black : Colors.black
                          ) ,

                          ) ,)
                      ],
                    ),
                  ),
                ),
              ))

        ],
      ),
    );
  }
}
