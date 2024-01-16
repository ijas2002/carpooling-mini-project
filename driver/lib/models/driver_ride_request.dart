import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverRideRequestInformation{
  // LatLng? originLatLng;
  // LatLng? destinationLatLng;
  String? originAddress;
  String? destinationAddress;
  String? pickUpDate;
  String? pickUpTime;


  String? rideRequestId;

  DriverRideRequestInformation({
    this.originAddress,this.destinationAddress,
    this.pickUpDate,this.rideRequestId,this.pickUpTime
    // this.destinationLatLng,this.originLatLng,
    // this.userName,this.userPhone,this.rideRequestId

  });

}