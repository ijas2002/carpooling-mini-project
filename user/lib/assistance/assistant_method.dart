

import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:users/assistance/request_assistant.dart';
import 'package:users/global/global.dart';
import 'package:users/global/map_key.dart';
import 'package:users/infoHandler/app_info.dart';
import 'package:users/models/direction_detail_info.dart';
import 'package:users/models/directions.dart';
import 'package:users/models/user_model.dart';
import 'package:http/http.dart' as http;

class AssistantMethods{

  static void readCurrentOnlineUserInfo() async{
    currentUser = firebaseAuth.currentUser;
    DatabaseReference userRef = FirebaseDatabase.instance
    .ref()
    .child("users").child(currentUser!.uid);

    userRef.once().then((snap){
      if(snap.snapshot.value != null){
        userModelCurrentInfo = UserModel.fromSnapShot(snap.snapshot);
      }

    });
  }

  static Future<String> searchAdrdressForGeographicCoOrdinates(Position position, context ) async{
    String apiUrl  ="https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";

    String humanReadableAddress = "";

    var requestResponse = await RequestAssistant.receiveRequest(apiUrl);

    if(requestResponse != "Error Accure. Failed No response."){
      humanReadableAddress = requestResponse["results"][0]["formatted_address"];


      Directions userPickUpAddress = Directions();

      userPickUpAddress.locationLatitude = position.latitude ;
      userPickUpAddress.locationLongitude=position.longitude ;
      userPickUpAddress.locationName = humanReadableAddress;

      Provider.of<AppInfo>(context,listen:false).updatePickUpLocationAddress(userPickUpAddress);



    }


    return humanReadableAddress;
  }

  static Future<DirectionDetailsInfo> obtainOriginToDestinationDirectionDetails(LatLng originPosition,LatLng destinationPosition) async {

    String urlOriginToDestinationDirectionDetails = "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";

    var responseDirectionApi = await RequestAssistant.receiveRequest(urlOriginToDestinationDirectionDetails);

    

    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
    directionDetailsInfo.e_points = responseDirectionApi["routes"][0]["overview_polyline"]["points"];
    
    directionDetailsInfo.distance_text = responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailsInfo.distance_value = responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];
    
    directionDetailsInfo.duration_text = responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    directionDetailsInfo.duration_value = responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetailsInfo;
  }

  static double calculateFare(double distance) {
    const double rateFirst5Km = 5.0; // Rupees per kilometer for the first 5 kilometers
    const double rateRemainingKm = 10.0; // Rupees per kilometer for remaining kilometers

    // Calculate fare for the first 5 kilometers
    double fareFirst5Km = rateFirst5Km * (distance < 5.0 ? distance : 5.0);

    // Calculate fare for the remaining kilometers
    double fareRemainingKm = rateRemainingKm * (distance > 5.0 ? distance - 5.0 : 0);

    // Calculate total fare
    double totalFare = fareFirst5Km + fareRemainingKm;

    return totalFare;
  }
  
  static double calculateFareAmountFromOriginToDestination(DirectionDetailsInfo directionDetailsInfo,String selectedVehicleType){
    double timeTravelledFareAmountPerMinute = (directionDetailsInfo.duration_value!/60);
    double distanceTravelledFareAmountPerKilometer =  (directionDetailsInfo.distance_value!/1000);

    double totalFareAmount = timeTravelledFareAmountPerMinute+ distanceTravelledFareAmountPerKilometer;
    double localCurrencyTotalFare = calculateFare(distanceTravelledFareAmountPerKilometer);

    if(selectedVehicleType=="Bike"){
      print(localCurrencyTotalFare);
      print(localCurrencyTotalFare.truncate());
      double resultFareAmount = ((localCurrencyTotalFare.truncate()).toDouble() * 0.8);
      return resultFareAmount;
    }
    else if(selectedVehicleType=="Car"){
      double resultFareAmount = ((localCurrencyTotalFare.truncate()).toDouble()*2);
      return resultFareAmount;

    }
    else{
      return localCurrencyTotalFare.truncate().toDouble();
    }

    // return double.parse(totalFareAmount.toStringAsFixed(1));
  }

  static sendNotificationToDriverNow(String deviceRegistrationToken, String userRideRequestId,context) async{
    String destinationAddress = userDropOffAddress;

    Map<String,String> headerNotification ={
      'Content-Type': 'application/json',
      'Authorization': cloudMessagingServerToken,
    };

    Map bodyNotification = {
      "body":"Destination Address: \n$destinationAddress.",
      "title":"New Trip Request"
    };

    Map dataMap = {
      "click_action":"FLUTTER_NOTIFICATION_CLICK",
      "id":"1",
      "status":"done",
      "rideRequestId": userRideRequestId
    };

    Map officialNotificationFormat={
      "notification":bodyNotification,
      "data":dataMap,
      "priority":"high",
      "to":deviceRegistrationToken

      
    };


    try {
      var responseNotification = await http.post(
        Uri.parse("https://fcm.googleapis.com/fcm/send"),
        headers: headerNotification,
        body: jsonEncode(officialNotificationFormat),
      );

      // Handle response
      if (responseNotification.statusCode == 200) {
        print("Notification sent successfully");
      } else {
        print("Failed to send notification. Status code: ${responseNotification.statusCode}");
      }
    } catch (error) {
      print("Error sending notification: $error");
    }
  }

  //retrive the trips keys for online user
//trip key = ride request

static void readTripKeysFormOnlineUser(context){
    FirebaseDatabase.instance.ref().child("All Ride Requests").orderByChild("userName").equalTo(userModelCurrentInfo!.name).once().then((snap){
      if(snap.snapshot.value != null){
        Map keysTripId = snap.snapshot.value as Map;

        //count total number of trips and share it with provder

        int overAllTripsCounter = keysTripId.length;
        // Provider.of<AppInfo>(context,listen: false).update

      }
    });

  }

}                 