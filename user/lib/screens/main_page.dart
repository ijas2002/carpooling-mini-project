import 'dart:async';
import 'dart:ffi';
import 'dart:ui';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:users/assistance/assistant_method.dart';
import 'package:users/assistance/geofire_assistant.dart';
import 'package:users/global/global.dart';
import 'package:users/global/map_key.dart';
import 'package:users/infoHandler/app_info.dart';
import 'package:users/models/active_nearby_available_drivers.dart';
import 'package:users/models/directions.dart';
import 'package:users/screens/drawer_screen.dart';
import 'package:users/screens/precise_pickup_location.dart';
import 'package:users/screens/rate_driver_screen.dart';
import 'package:users/screens/riide_take.dart';
import 'package:users/screens/search_places_screen.dart';
import 'package:users/splashScreen/splash_screen.dart';
import 'package:users/themeProvider/theme_provider.dart';
import 'package:users/widgets/progress_dialog.dart';

import '../widgets/pay_fare_amount_dialog.dart';


Future<void> _makePhoneCall(String url) async{
  if(await canLaunch(url)){
    await launch(url);
  }
  else{
    throw "Could not launch $url";
  }
}
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  LatLng? pickLocation;
  loc.Location location = loc.Location();
  String? _address;



  final Completer<GoogleMapController> _controllerGoogleMap =Completer();
  GoogleMapController? newGoogleMapController;
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();
  
  double searchLocationContainerHeight = 220;
  double waitingResponsefromDriverContainerHeight=0;
  double assignedDriverInfoContainerHeight=0;
  double suggestedRidesContainerHeight =0;
  double searchingForDriverContainerHeight =0;

  Position? userCurrentPosition;
  var geoLocation = Geolocator();

  LocationPermission? _locationPermission;
  double bottomPaddingOfMap = 0;

  List<LatLng> pLineCoOrdinatesList = [];
  Set<Polyline> polyLineSet ={};

  Set<Marker> markerSet ={};
  Set<Circle> circlesSet ={};

  String userName ="";
  String userEmail ="";

  bool openNavigationDrawer = true;

  bool activeNearbyDriverKeysLoaded = false;

  BitmapDescriptor? activeNearbyIcon;

  String selectedVehicleType="";
  DatabaseReference? referenceRideRequest;

  String driverRideStatus = "Driver is coming";
  StreamSubscription<DatabaseEvent>? tripRidesRequestInformationStreamSubscription;

  String userRideRequestStatus = "";

  List<ActiveNearByAvailableDrivers> onlineNearByAvailableDriverList =[];

  bool requestPositionInfo = true;
  

locateUserPosition () async {
  Position cPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  userCurrentPosition = cPosition;

  LatLng latLngPosition = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
  CameraPosition cameraPosition = CameraPosition(target: latLngPosition,zoom: 15);

  newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

   String humanReadableAddress = await AssistantMethods.searchAdrdressForGeographicCoOrdinates(userCurrentPosition!, context);

   print("This is user address = "+ humanReadableAddress);

   userName = userModelCurrentInfo!.name!;
   userEmail = userModelCurrentInfo!.email!;

   initializeGeoFireListener();

  //  AssistantMethods.readTripKeysForOnlineUser(context);

  

}

  initializeGeoFireListener(){
  Geofire.initialize("activeDrivers");
  Geofire.queryAtLocation(userCurrentPosition!.latitude, userCurrentPosition!.longitude, 10)!
      .listen((map) {
        if(map!= null){
          var callBack = map["callBack"];
          print("this is call back:${callBack}");

          switch(callBack){
            //driver is active online
            case Geofire.onKeyEntered:
              ActiveNearByAvailableDrivers activeNearByAvailableDrivers= ActiveNearByAvailableDrivers();
              activeNearByAvailableDrivers.locationLatitude = map["latitude"];
              activeNearByAvailableDrivers.locationLongitude = map["longitude"];
              activeNearByAvailableDrivers.driverId = map["key"];
              GeoFireAssistant.activeNearByAvailableDriversList.add(activeNearByAvailableDrivers);
              if(activeNearbyDriverKeysLoaded == true){
                displayActiveDriversOnUserMap();
              }
              break;
            case Geofire.onKeyExited:
              GeoFireAssistant.deleteOfflineDriverFromList( map["key"]);
              displayActiveDriversOnUserMap();
              break;
              //whenever driver is non active/online
            case Geofire.onKeyMoved:
              ActiveNearByAvailableDrivers activeNearByAvailableDrivers = ActiveNearByAvailableDrivers();
              activeNearByAvailableDrivers.locationLatitude = map["latitude"];
              activeNearByAvailableDrivers.locationLongitude=map["longitude"];
              GeoFireAssistant.updateActiveNearByAvailableDrivers(activeNearByAvailableDrivers);
              displayActiveDriversOnUserMap();
              break;
              //whenever driver moves fro their location
            case Geofire.onGeoQueryReady:
              activeNearbyDriverKeysLoaded = true;
              displayActiveDriversOnUserMap();
              print("Active drivers list size: ${GeoFireAssistant.activeNearByAvailableDriversList.length}");
              print("Active drivers list: ${GeoFireAssistant.activeNearByAvailableDriversList}");
              break;
              break;

          }
        }
        setState(() {

        });
  });

  }
  displayActiveDriversOnUserMap(){
  setState(() {
    markerSet.clear();
    circlesSet.clear();

    Set<Marker> driversMarkerSet = Set<Marker>();

    for(ActiveNearByAvailableDrivers eachDriver in GeoFireAssistant.activeNearByAvailableDriversList){
      LatLng eachDriverActivePosition = LatLng(eachDriver.locationLatitude!,eachDriver.locationLongitude!);
       Marker marker = Marker(
         markerId: MarkerId(eachDriver.driverId!),
         position: eachDriverActivePosition,
         icon: activeNearbyIcon!,
         rotation: 360

       );
       driversMarkerSet.add(marker);
    }
    setState(() {
      markerSet = driversMarkerSet;
    });
  });
  }

  void createActiveNearByDriverIconMarker() {
    if (activeNearbyIcon == null) {
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(context);

      BitmapDescriptor.fromAssetImage(
        imageConfiguration,
        "images/CarTop.png"
      ).then((value) {
        activeNearbyIcon = value;
      });
    }
  }

Future<void> drawPolyLineFromOriginToDestination(bool darkTheme ,BuildContext context) async{

  var originPosition = Provider.of<AppInfo>(context,listen:false).userPickUpLocation;
  var destinationPosition = Provider.of<AppInfo>(context,listen:false).userDropOffLocation;

  var originLatLng = LatLng(originPosition!.locationLatitude!, originPosition.locationLongitude!);
  var destinationLatLng = LatLng(destinationPosition!.locationLatitude!, destinationPosition.locationLongitude!);

  showDialog(context: context, builder: (BuildContext context)=>ProgressDialog(message: "Please wait...",));

  var directionDetailsInfo = await AssistantMethods.obtainOriginToDestinationDirectionDetails(originLatLng, destinationLatLng);
  setState(() {
    tripDirectionDetailsInfo = directionDetailsInfo;
    
  });

  Navigator.pop(context);

  PolylinePoints pPoints = PolylinePoints();

  List<PointLatLng> decodePolyLinePointsResultList = pPoints.decodePolyline(directionDetailsInfo.e_points!);
  pLineCoOrdinatesList.clear();

  if(decodePolyLinePointsResultList.isNotEmpty){
    decodePolyLinePointsResultList.forEach((PointLatLng pointLatLng) {
      pLineCoOrdinatesList.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
     });
  }
  polyLineSet.clear();

  setState(() {
    Polyline polyline = Polyline(
      color: darkTheme? Colors.amberAccent:Colors.blue,
      polylineId: PolylineId("PolylineID"),jointType: JointType.round,
      points: pLineCoOrdinatesList,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      geodesic: true,
      width: 5

      );

      polyLineSet.add(polyline);
  }
  );

  LatLngBounds boundsLatLng;

  if(originLatLng.latitude > destinationLatLng.latitude && originLatLng.longitude > destinationLatLng.longitude){
    boundsLatLng = LatLngBounds(
      southwest: destinationLatLng, 
      northeast: originLatLng);
  }
  else if(originLatLng.longitude>destinationLatLng.longitude){
    boundsLatLng = LatLngBounds(
      southwest: LatLng(originLatLng.latitude,destinationLatLng.longitude),
       northeast: LatLng(destinationLatLng.latitude,originLatLng.longitude),
       );
  }
    else if(originLatLng.latitude>destinationLatLng.latitude){
    boundsLatLng = LatLngBounds(
      southwest: LatLng(destinationLatLng.latitude,originLatLng.longitude),
       northeast: LatLng(originLatLng.latitude,destinationLatLng.longitude),
       );
  }
  else{
    boundsLatLng = LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
  }

  newGoogleMapController!.animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

Marker originMarker = Marker(
  markerId: MarkerId("originID"),
  infoWindow: InfoWindow(title:originPosition.locationName,snippet: "Origin"),
  position: originLatLng,
  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
  
  );

  Marker destinationMarker = Marker(
  markerId: MarkerId("destinationID"),
  infoWindow: InfoWindow(title:destinationPosition.locationName,snippet: "Destination"),
  position: destinationLatLng,
  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
  
  );

  setState(() {
     markerSet.add(originMarker);
     markerSet.add(destinationMarker);
  });


  Circle originCircle = Circle(circleId: CircleId("originID"),fillColor: Colors.green,radius:12,strokeWidth: 3,
  strokeColor: Colors.white,center: originLatLng);

  Circle destinationCircle = Circle(circleId: CircleId("destinationID"),fillColor: Colors.green,radius:12,strokeWidth: 3,
  strokeColor: Colors.white,center: destinationLatLng);

  setState(() {
    circlesSet.add(originCircle);
    circlesSet.add(destinationCircle);
  });

}

//....................

 void showSearchingForDriversContainer(){
  setState(() {
    searchingForDriverContainerHeight = 200;
  });
 }

 void showSuggestedRidesContainer(){
  setState(() {
suggestedRidesContainerHeight = 400;
bottomPaddingOfMap = 400;
  });
  }

checkIfLocationPermissonAllowed() async {
  _locationPermission = await Geolocator.requestPermission();

  if(_locationPermission == LocationPermission.denied){
    _locationPermission = await Geolocator.requestPermission();
  }
}

saveRideRequestInformation(String selectedVehicleType){
  //save ride request information;

    referenceRideRequest = FirebaseDatabase.instance.ref().child("All Ride Requests").push();

    var originLocation = Provider.of<AppInfo>(context,listen: false).userPickUpLocation;
    var destinationLocation = Provider.of<AppInfo>(context,listen: false).userDropOffLocation;

    Map originLocationMap = {
      //key and values

      "latitude": originLocation!.locationLatitude.toString(),
      "longitude": originLocation!.locationLongitude.toString(),
    };

    Map destinationLocationMap = {
      //key and values

      "latitude": destinationLocation!.locationLatitude.toString(),
      "longitude": destinationLocation!.locationLongitude.toString(),
    };

    Map userInformationMap ={
      "origin": originLocationMap,
      "destination":destinationLocationMap,
      "time":DateTime.now().toString(),
      "userName":userModelCurrentInfo!.name,
      "userPhone":userModelCurrentInfo!.phone,
       "originAddress":originLocation.locationName,
      "destinationAddress":destinationLocation.locationName,
      "driverId":"waiting",
    };

    referenceRideRequest!.set(userInformationMap);

    tripRidesRequestInformationStreamSubscription = referenceRideRequest!.onValue.listen((eventSnap) async {
      if(eventSnap.snapshot.value == null){
        return;
      }
    if((eventSnap.snapshot.value as Map)["car_details"] != null){
      setState(() {
        driverCarDetails = (eventSnap.snapshot.value as Map)["car_details"].toString();
      });

      }
      if((eventSnap.snapshot.value as Map)["driverPhone"] != null){
        setState(() {
          driverPhone = (eventSnap.snapshot.value as Map)["driverPhone"].toString();
        });

      }

      if((eventSnap.snapshot.value as Map)["driverName"] != null){
        setState(() {
          driverName = (eventSnap.snapshot.value as Map)["driverName"].toString();
        });

      }
      if((eventSnap.snapshot.value as Map)["ratings"] != null){
        setState(() {
          driverRatings = (eventSnap.snapshot.value as Map)["ratings"].toString();
        });

      }

      if((eventSnap.snapshot.value as Map)["status"] != null){
        setState(() {
          userRideRequestStatus=driverCarDetails = (eventSnap.snapshot.value as Map)["status"].toString();
        });

      }

      if((eventSnap.snapshot.value as Map)["driverLocation"]!=null){
        double driverCurrentPositionLat = double.parse((eventSnap.snapshot.value as Map)["driverLocation"]["latitude"].toString());
        double driverCurrentPositionLng = double.parse((eventSnap.snapshot.value as Map)["driverLocation"]["longitude"].toString());

        LatLng driverCurrentPositionLatLng = LatLng(driverCurrentPositionLat,driverCurrentPositionLng);

        //status accepted

        if(userRideRequestStatus == "accepted"){
          updateArrivalTimeToUserPickUpLocation(driverCurrentPositionLatLng);
        }

        //status is arrived

        if(userRideRequestStatus == "arrived"){
          setState(() {
            driverRideStatus = "Driver has arrived";
          });
        }

        // status is on trip

        if(userRideRequestStatus == "ontrip"){
          updateReachingTimeToUserDropOffLocation(driverCurrentPositionLatLng);
        }

        if(userRideRequestStatus == "ended"){
          if((eventSnap.snapshot.value as Map)["fareAmount"] != null){
            double fareAmount = double.parse((eventSnap.snapshot.value as Map)["fareAmount"].toString());

            var response = await showDialog(context: context, builder: (BuildContext context)=>
                PayFareAmountDialog(
              fareAmount: fareAmount
            ));

            if(response == "Cash Paid"){
              //user can rate driver now

              if((eventSnap.snapshot.value as Map)["driverId"] != null){
                String assignedDriverId = (eventSnap.snapshot.value as Map)["driverId"].toString();
                Navigator.push(context, MaterialPageRoute(builder: (c)=>RateDriverScreen(
                  assignedDriverId: assignedDriverId,
                )));
              referenceRideRequest!.onDisconnect();
              tripRidesRequestInformationStreamSubscription!.cancel();


              }
            }

          }
        }


      }



    });

    onlineNearByAvailableDriverList= GeoFireAssistant.activeNearByAvailableDriversList;
    searchNearestOnlineDrivers(selectedVehicleType);
}

searchNearestOnlineDrivers(String selectedVehicleType) async {

  if(onlineNearByAvailableDriverList.length==0){
    //cancel or delete ride request
    referenceRideRequest!.remove();
    setState(() {
      polyLineSet.clear();
      markerSet.clear();
      circlesSet.clear();
      pLineCoOrdinatesList.clear();
    });
    Fluttertoast.showToast(msg: "No Online Nearest Driver Available");
    Fluttertoast.showToast(msg: "Search Again and Restarting App");
    
    Future.delayed(Duration(microseconds: 4000),(){
      referenceRideRequest!.remove();
      Navigator.push(context,MaterialPageRoute(builder: (c)=>SplashScreen()));



    });
    return;
  }

  await retrieveOnlineDriversInformation(onlineNearByAvailableDriverList);

  print("Driver List :"+driversList.toString());

  for(int i=0;i<driversList.length;i++){
    if(driversList[i]["car_details"]["type"]==selectedVehicleType){
      AssistantMethods.sendNotificationToDriverNow(driversList[i]["token"],referenceRideRequest!.key!,context);
    }
  }

  Fluttertoast.showToast(msg: "Notification Send Successfully");

  showSearchingForDriversContainer();
  
  await FirebaseDatabase.instance.ref().child("All Ride Requests").child(referenceRideRequest!.key!).child("driverId").onValue.listen((eventRideRequestSnapshot) {
    print("EventSnapShot:${eventRideRequestSnapshot.snapshot.value}");
    if(eventRideRequestSnapshot.snapshot.value !=null){
      if(eventRideRequestSnapshot.snapshot.value != "waiting"){
        showUIForAssignedDriverInfo();
      }
    }
  });


  }

updateArrivalTimeToUserPickUpLocation(driverCurrentPositionLatLng) async {
  if(requestPositionInfo == true){
    requestPositionInfo=false;
    LatLng userPickUpPosition = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

    var directionDetailInfo = await AssistantMethods.obtainOriginToDestinationDirectionDetails(
        driverCurrentPositionLatLng, userPickUpPosition);

    if(directionDetailInfo == null){
      return;
    }
    setState(() {
      driverRideStatus = "Driver is coming: "+directionDetailInfo.duration_text.toString();

    });

    requestPositionInfo = true;
  }
  }

updateReachingTimeToUserDropOffLocation(driverCurrentPositionLatLng) async{
  if(requestPositionInfo == true){
    requestPositionInfo = false;

    var dropOffLocation = Provider.of<AppInfo>(context,listen: false).userDropOffLocation;

    LatLng userDestinationPosition = LatLng(
        dropOffLocation!.locationLatitude!,
        dropOffLocation.locationLongitude!);

    var directionDetailsInfo = await AssistantMethods.obtainOriginToDestinationDirectionDetails(
        driverCurrentPositionLatLng,
        userDestinationPosition);

    if(directionDetailsInfo == null){
      return;
    }
    setState(() {
      driverRideStatus="Going Towards Destination: "+directionDetailsInfo.duration_text.toString();
    });


    requestPositionInfo = true;
  }
  }

showUIForAssignedDriverInfo(){
  setState(() {
    waitingResponsefromDriverContainerHeight=0;
    searchLocationContainerHeight =0;
    assignedDriverInfoContainerHeight=400;
    suggestedRidesContainerHeight=0;
    bottomPaddingOfMap = 200;
  });
  }

  retrieveOnlineDriversInformation(List onlineNearestDriversList) async {

  driversList.clear();
  DatabaseReference ref = FirebaseDatabase.instance.ref().child("drivers");
  for(int i=0;i< onlineNearestDriversList.length;i++){
    await ref.child(onlineNearestDriversList[i].driverId.toString()).once().then((dataSnapshot){
      var driverKeyInfo = dataSnapshot.snapshot.value;

      driversList.add(driverKeyInfo);

      print("driver key information="+driversList.toString());

    });
  }

  }



@override
  void initState() {
    // TODO: implement initState
    super.initState();

    checkIfLocationPermissonAllowed();
  }





  @override
  
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    createActiveNearByDriverIconMarker();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: _scaffoldState,
        drawer: DrawerScreen(),

        body: Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              myLocationEnabled: true,
              zoomControlsEnabled: true,
              initialCameraPosition: _kGooglePlex,
              polylines: polyLineSet,
              markers: markerSet,
              circles: circlesSet,
              onMapCreated: (GoogleMapController controller){
                _controllerGoogleMap.complete(controller);
                newGoogleMapController = controller;

                setState(() {
                  
                });

                locateUserPosition();
              },

            ),

            //custom button

            Positioned(
              top:50,
              left:20,
              
              child: Container(
                child: GestureDetector(
                  onTap:(){
                    _scaffoldState.currentState!.openDrawer();

                  },
                  child: CircleAvatar(
                    backgroundColor: darkTheme ? Colors.amber.shade400 : Colors.white,
                  child: Icon(Icons.menu,color: darkTheme?Colors.black : Colors.lightBlue,),
                   ),
                  

                ),
              )),
            Positioned(
                top:50,

                right: 20,

                child: Container(
                  child: GestureDetector(
                    onTap:(){
                      Navigator.push(context,MaterialPageRoute(builder: (c)=>RideTakeScreen()));

                    },
                    child: CircleAvatar(
                      // backgroundColor: darkTheme ? Colors.amber.shade400 : Colors.white,
                      backgroundColor: Colors.red.shade200,
                      child:Icon(Icons.arrow_forward_ios_rounded)

                    ),


                  ),
                )),

            //ui for searhing location 

            Positioned(
              bottom:0,
              left:0,
              right:0,

              
              child: Padding(
                padding: EdgeInsets.fromLTRB(20,50,20,20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color :  darkTheme ? Colors.black : Colors.white ,
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Column(children: [
                        Container(
                          decoration: BoxDecoration(
                            color :  darkTheme ? Colors.grey.shade900 : Colors.grey.shade100 
                          ),
                          child:Column(
                            children: [
                              Padding(padding: EdgeInsets.all(5),
                              child : Row(children: [
                                Icon(Icons.location_on_outlined,color : Colors.blue)
                                ,SizedBox(width: 10,),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("From",
                                    style: TextStyle(
                                      color :  darkTheme ? Colors.amber.shade400 : Colors.blue
                                      ),
                                      ),
                                    Text(Provider.of<AppInfo>(context).userPickUpLocation != null 
                                    ? (Provider.of<AppInfo>(context).userPickUpLocation!.locationName!).substring(0,24)+"..."
                                    :"Not Getting Address",style: TextStyle(color: Colors.grey,fontSize: 14),
                                    )
                                  ],

                                )
                                ],)
                              ),
                              SizedBox(height: 5,),
                              Divider(
                                height: 1,
                                thickness: 2,
                                color :  darkTheme ? Colors.amber.shade400 : Colors.blue
                              ),
                               SizedBox(height: 5,),

                               Padding(
                                padding: EdgeInsets.all(5),
                               child: GestureDetector(
                                onTap: () async {

                                  //go to search places screen
                                  var responseFromSearchScreen = await Navigator.push(context,MaterialPageRoute(builder:(c)=>SearchPlaceScreen())) ;

                                  if(responseFromSearchScreen == "obtainedDropoff"){
                                    setState(() {
                                      openNavigationDrawer = false;
                                      
                                    });
                                    
                                  }
                                  await drawPolyLineFromOriginToDestination(darkTheme,context);

                                },
                                child:  Row(children: [
                                Icon(Icons.location_on_outlined,color : Colors.blue)
                                ,SizedBox(width: 10,),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("To",style: TextStyle(color :  darkTheme ? Colors.amber.shade400 : Colors.blue),),
                                    Text(Provider.of<AppInfo>(context).userDropOffLocation!= null 
                                    ? Provider.of<AppInfo>(context).userDropOffLocation!.locationName!
                                    :"Where to?",style: TextStyle(color: Colors.grey,fontSize: 14),
                                    )
                                  ],

                                )
                                ],)
                               )
                               )
                            ],
                          )
                        ),

                        SizedBox(height: 5,),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: (){
                                Navigator.push(context, MaterialPageRoute(builder: (c)=>PrecisePickUpScreen()));

                            }, 
                            child: Text("Pick Up Address",
                            style: TextStyle(
                              color:darkTheme? Colors.black : Colors.white, )
                              ),
                              style: ElevatedButton.styleFrom(
                                primary: darkTheme ? Colors.amber.shade400 : Colors.blue,
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize:16
                                )
                              ),
                            
                            ),
                            SizedBox(width: 10,),
                             ElevatedButton(onPressed: (){
                               if(Provider.of<AppInfo>(context,listen:false).userDropOffLocation!=null){
                                 showSuggestedRidesContainer();
                               }
                               else{
                                 Fluttertoast.showToast(msg: "Please Selet destination Location");
                               }
                             },
                            child: Text("Show Fare",
                            style: TextStyle(
                              color:darkTheme? Colors.black : Colors.white, )
                              ),
                              style: ElevatedButton.styleFrom(
                                primary: darkTheme ? Colors.amber.shade400 : Colors.blue,
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize:16
                                )
                              ),
                            
                            )
                          ],
                        )

                      ]),
                    )

                  ]),
              )),

            //ui for suggested rides
            Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: suggestedRidesContainerHeight,
                  decoration: BoxDecoration(
                    color: darkTheme? Colors.black : Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),

                    )
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20) ,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: darkTheme? Colors.amber.shade400 : Colors.blue,
                                borderRadius : BorderRadius.circular(2)
                              ),
                              child: Icon(
                                Icons.star,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 25,),
                            Text(Provider.of<AppInfo>(context).userPickUpLocation != null
                                ? (Provider.of<AppInfo>(context).userPickUpLocation!.locationName!).substring(0,24)+"..."
                                :"Not Getting Address",style: TextStyle(color: Colors.black,fontSize: 18,fontWeight: FontWeight.bold),
                            )
                          ],

                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                  color: darkTheme? Colors.amber.shade400 : Colors.blue,
                                  borderRadius : BorderRadius.circular(2)
                              ),
                              child: Icon(
                                Icons.star,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 25,),
                            Text(Provider.of<AppInfo>(context).userDropOffLocation != null
                                ? Provider.of<AppInfo>(context).userDropOffLocation!.locationName!
                                :"Not Getting Address",style: TextStyle(color: Colors.grey,fontSize: 18,fontWeight: FontWeight.bold),
                            )
                          ],

                        ),
                        SizedBox(height: 20,),
                        Text("Suggested Rides",style: TextStyle(
                          fontWeight: FontWeight.bold
                        ),),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: (){
                                 setState(() {
                                   selectedVehicleType ="Car";


                                 });
                              },
                              child: Container(
                                decoration: BoxDecoration(

                                  color: selectedVehicleType=="Car"?Colors.blue.shade200:Colors.grey,
                                  borderRadius: BorderRadius.circular(12), ),
                                child: Padding(
                                  padding: EdgeInsets.all(25.0),
                                  child: Column(
                                    children: [
                                      Image.asset("images/car.png",scale:3),
                                      SizedBox(height: 8,),
                                      Text(
                                        "Car",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black
                                        )
                                      ),
                                      SizedBox(height: 2,),
                                      Text(tripDirectionDetailsInfo!=null?"Rs.${AssistantMethods.calculateFareAmountFromOriginToDestination(tripDirectionDetailsInfo!,"Car").toStringAsFixed(1)}": "null" ,
                                      style: TextStyle(color: Colors.black),),

                                    ],

                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: (){
                                setState(() {
                                  selectedVehicleType ="Bike";

                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: selectedVehicleType=="Bike"?Colors.blue.shade200:Colors.grey,
                                  borderRadius: BorderRadius.circular(12), ),
                                child: Padding(
                                  padding: EdgeInsets.all(25.0),
                                  child: Column(
                                    children: [
                                      Image.asset("images/bike.png",scale:3),
                                      SizedBox(height: 8,),
                                      Text(
                                          "Bike",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black
                                          )
                                      ),
                                      SizedBox(height: 2,),
                                      Text(tripDirectionDetailsInfo!=null?"Rs.${AssistantMethods.calculateFareAmountFromOriginToDestination(tripDirectionDetailsInfo!,"Bike").toStringAsFixed(1)}": "null" ,
                                        style: TextStyle(color: Colors.black),),

                                    ],

                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Expanded(
                            child: GestureDetector(
                          onTap: (){
                            if(selectedVehicleType !=""){

                              saveRideRequestInformation(selectedVehicleType);

                            }
                            else{
                              Fluttertoast.showToast(msg: "please select Vehicle from suggested rides");
                            }

                          },
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:darkTheme? Colors.amber.shade200 : Colors.blue,
                              borderRadius: BorderRadius.circular(10)
                            ),
                            child: Center(
                              child: Text("Request a Ride",style: TextStyle(color: darkTheme?Colors.black : Colors.white,fontWeight: FontWeight.bold,fontSize: 20),),
                            ),
                          ),
                        ))

                      ],
                    ),

                  ),
                )),
            //requesting a ride

            Positioned(
                bottom: 0,
                left: 0,
                right:0,

                child: Container(
                  height: searchingForDriverContainerHeight,
                  decoration: BoxDecoration(
                    color: darkTheme? Colors.black : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),topRight: Radius.circular(15)
                    )
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24,vertical: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LinearProgressIndicator(
                          color: darkTheme?Colors.amber.shade400:Colors.blue,
                        ),
                        SizedBox(height: 10,),
                        Center(
                          child: Text(
                            "Searching for a driver...",style: TextStyle(
                            color: Colors.grey,fontSize: 22,fontWeight: FontWeight.bold
                          ),
                          ),
                        ),
                        SizedBox(height: 20,),

                        GestureDetector(
                          onTap: (){

                            referenceRideRequest!.remove();
                            setState(() {
                              searchingForDriverContainerHeight =0;
                              suggestedRidesContainerHeight =0;

                            });

                          },
                          child: Container(
                            height: 50,
                              width: 50,
                            decoration: BoxDecoration(
                              color: darkTheme? Colors.black :Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(width: 1,color: Colors.grey)
                            ),
                            child: Icon(Icons.close,size: 25,),

                          ),
                        ),

                        SizedBox(height: 15,),

                        Container(
                          width: double.infinity,
                          child: Text(
                            "Cancel",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: 12),

                          ),
                        )
                      ],
                    ),
                  ),


            )),
            
            //ui for displaying assigned driver information
            
            Positioned(
              bottom: 0,
                left: 0,
                right: 0,


                child: Container(
                  height: assignedDriverInfoContainerHeight,
                  decoration: BoxDecoration(
                    color: darkTheme? Colors.black: Colors.white,
                    borderRadius: BorderRadius.circular(10)

                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Text(
                          driverRideStatus,style: TextStyle(fontWeight: FontWeight.bold, ),
                        ),
                        SizedBox(height: 5,),
                        Divider(thickness: 1,color:darkTheme? Colors.grey: Colors.grey[300],),
                        SizedBox(height: 5,),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: darkTheme?Colors.amber.shade400:Colors.lightBlue,
                                borderRadius: BorderRadius.circular(10),


                              ),
                              child: Icon(Icons.person,color:darkTheme?Colors.black:Colors.white,),
                            ),

                            SizedBox(width: 10,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Text(driverName,style: TextStyle(fontWeight: FontWeight.bold,color:darkTheme?Colors.black:Colors.white )),

                                Row(

                                  children: [
                                    Icon(Icons.star,color: Colors.orange,),
                                    Text(
                                      //rating

                                      driverRatings == null? "0.0":driverRatings,
                                        style: TextStyle(fontWeight: FontWeight.bold,color:Colors.grey )
                                          
                                    )
                                  ],
                                )
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Image.asset("images/car.png",scale: 3,),
                                Text(driverCarDetails,style: TextStyle(fontSize: 12),)
                              ],
                            )


                          ],
                        ),

                        SizedBox(height: 5,),
                        Divider(
                          thickness: 1,color: darkTheme? Colors.grey : Colors.grey[300],
                          
                          
                        ),
                        ElevatedButton.icon(
                            onPressed: (){

                              _makePhoneCall("tel:${driverPhone}");

                            },
                          style: ElevatedButton.styleFrom(
                            primary: darkTheme? Colors.amber.shade400:Colors.blue
                          ),
                            icon:Icon(Icons.phone),
                            label:Text(
                              "Call Driver"
                            ) ,)


                        

                        


                      ],
                    ),
                  ),
                ))

            // Positioned(
            //   top:100,
            //   right:20,
            //   left:20,
              

              

          ],
        )

        
      ),
    );
  }
}