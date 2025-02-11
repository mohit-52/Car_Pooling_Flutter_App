import 'dart:async';
import 'dart:convert';
import 'package:car_pooling/new/assistants/request_assistants.dart';
import 'package:car_pooling/new/global/global.dart';
import 'package:car_pooling/new/modals/direction_details_info.dart';
import 'package:car_pooling/new/modals/user_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../global/map_key.dart';
import '../infoHandler/app_info.dart';
import '../modals/directions.dart';
import 'package:http/http.dart' as http;

class AssistantMethods {

  static void readCurrentOnlineUserInfo() async {
    currentUser = firebaseAuth.currentUser;
    DatabaseReference userRef =
        FirebaseDatabase.instance.ref().child("users").child(currentUser!.uid);

    userRef.once().then((snap) {
      if(snap.snapshot.value!=null){
        userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);
      }
    });
  }

  static Future<String> searchAddressForGeographicCoordinates(Position position, context) async {

    String apiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    String humanReadbleAddress = "";
    var requestResponse = await RequestAssistant.receiveRequest(apiUrl);
    if(requestResponse != "Error occurred. Failed. No Response"){
      humanReadbleAddress = requestResponse["results"][0]["formatted_address"];

      Directions userPickupAddress = Directions();
      userPickupAddress.locationLatitude = position.latitude;
      userPickupAddress.locationLongitude = position.longitude;
      userPickupAddress.humanReadableAddress = humanReadbleAddress;

      Provider.of<AppInfo>(context, listen: false).updatePickUpLocationAddress(userPickupAddress);
    }

    return humanReadbleAddress;
  }

  static Future<DirectionDetailsInfo> obtainOriginToDestinationDirectionDetails(LatLng originPosition, LatLng destinationPosition)async{
    String urlOriginToDestinationDirectionDetails = "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";


    var responseDirectionsApi = await RequestAssistant.receiveRequest(urlOriginToDestinationDirectionDetails);
    // if(responseDirectionsApi != "Error occurred. Failed. No Response"){
    //
    // }

    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();

    directionDetailsInfo.e_points = responseDirectionsApi["routes"][0]["overview_polyline"]["points"];

    directionDetailsInfo.distance_text = responseDirectionsApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailsInfo.distance_value = responseDirectionsApi["routes"][0]["legs"][0]["distance"]["value"];

    directionDetailsInfo.duration_text = responseDirectionsApi["routes"][0]["legs"][0]["duration"]["text"];
    directionDetailsInfo.duration_value = responseDirectionsApi["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetailsInfo;

  }

  static double calculateFareAmountFromOriginToDestination (DirectionDetailsInfo directionDetailsInfo) {
    double timeTraveledFareAmountPerMinute = (directionDetailsInfo
        .duration_value! / 60) * 0.1;
    double distanceTraveledFareAmountPerKilometer = (directionDetailsInfo
        .duration_value! / 1000) * 0.1;

    //USD

    double totalFareAmount = timeTraveledFareAmountPerMinute +
        distanceTraveledFareAmountPerKilometer;

    return double.parse(totalFareAmount.toStringAsFixed(1));
  }

  static sendNotificationToDriverNow(String deviceRegistrationToken, String userRideRequestId, context)async{
    String destinationAddress = userDropOffAddress;

    Map<String, String> headerNotification = {
      'Content-Type' : 'application/json',
      'Authorization' : cloudMessagingServerToken,
    };

    Map bodyNotification = {
      'body' : 'Destination Address: \n$destinationAddress.',
      'title' : "New Trip Request",
    };

    Map dataMap = {
      'click_action' : 'FLUTTER_NOTIFICATION_CLICK',
      'id' : "1",
      'status' : 'done',
      'rideRequestId' : userRideRequestId
    };

    Map officialNotificationFormat = {
      "notification" : bodyNotification,
      "data" : dataMap,
      "priority" : "high",
      "to" : deviceRegistrationToken,
    };

    var responseNotification = http.post(
      Uri.parse("https://fcm.googleapis.com/fcm/send"),
      headers: headerNotification,
      body: jsonEncode(officialNotificationFormat),
    );
  }
}
