import 'package:flutter/cupertino.dart';
import 'package:users/models/directions.dart';

class AppInfo extends ChangeNotifier{
  Directions? userPickUpLocation,userDropOffLocation;
  int countTotalTrips=0;
  // List<String> historyTripKeysList = [];
  // List<TripHistoryModel> allTripsHistoryInformationList = [];


    void updatePickUpLocationAddress(Directions userPickUpAddress){

    userPickUpLocation = userPickUpAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Directions dropOffAddress){
    userDropOffLocation = dropOffAddress;
    notifyListeners();

  }
  updateOverAllTripCounter(int overAllTripsCounter){
    countTotalTrips = overAllTripsCounter;
    notifyListeners();
  }

  updateOverAllTripsKeys(List<String> tripsKetsList){

    // historyTrips

  }

}