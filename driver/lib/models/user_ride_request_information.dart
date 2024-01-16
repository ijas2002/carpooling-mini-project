import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserRideRequestInformation{
  LatLng? originLatLng;
  LatLng? destinationLatLng;
  String? originAddress;
  String? destinationAddress;
  String? userName;
  String? userPhone;
  String? rideRequestId;

  UserRideRequestInformation({
    this.originAddress,this.destinationAddress,
    this.destinationLatLng,this.originLatLng,
    this.userName,this.userPhone,this.rideRequestId

});

}