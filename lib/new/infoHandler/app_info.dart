import 'package:flutter/cupertino.dart';

import '../modals/directions.dart';

class AppInfo extends ChangeNotifier{
  Directions? userPickupLocation, userDropOffLocation;
  int countTotalTrips = 0;
  // List<String> historyTripsKeysList = [];
  // List<TripsHistoryModel> allTripsHistoryInformationList = [];

void updatePickUpLocationAddress(Directions userPickupAddress){
  userPickupLocation = userPickupLocation;
  notifyListeners();
}

  void updateDropOffLocationAddress(Directions userDropOffAddress){
    userDropOffLocation = userDropOffAddress;
    notifyListeners();
  }

}