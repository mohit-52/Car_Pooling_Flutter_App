import 'dart:async';
import 'package:car_pooling/new/assistants/assistant_methods.dart';
import 'package:car_pooling/new/assistants/geofire_assistant.dart';
import 'package:car_pooling/new/global/global.dart';
import 'package:car_pooling/new/modals/active_nearby_available_drivers.dart';
import 'package:car_pooling/new/screens/drawer_screen.dart';
import 'package:car_pooling/new/screens/precise_pickup_location.dart';
import 'package:car_pooling/new/screens/search_places_screen.dart';
import 'package:car_pooling/new/screens/splash_screen.dart';
import 'package:car_pooling/new/widgets/progress_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../infoHandler/app_info.dart';
import '../widgets/pay_fare_amount_dialog.dart';

// Call the Driver after booking a ride
Future<void> _makePhoneCall(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  }
  else {
    throw "Could Not Launch $url";
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  LatLng? pickLocation;
  loc.Location location = loc.Location();
  String? _address;

  final Completer<GoogleMapController> _controllerGoogleMap =
  Completer<GoogleMapController>();
  GoogleMapController? newGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();
  double searchLocationContainerHeight = 220;
  double waitingResponseFromDriverContainerHeight = 0;
  double assignedDriverInfoContainerHeight = 0;
  double suggestedRideContainerHeight = 0;
  double searchingForDriverContainerHeight = 0;

  Position? userCurrentPosition;
  var geoLocation = Geolocator();

  LocationPermission? _locationPermission;
  double bottomPaddingOfMap = 0;

  List<LatLng> pLineCoordinatesList = [];
  Set<Polyline> polylineSet = {};

  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};

  String? userName = "";
  String? userEmail = "";

  bool openNavigationDrawer = true;

  bool activeNearbyDriverKeysLoaded = false;

  BitmapDescriptor? activeNearbyIcon;

  DatabaseReference? referenceRideRequest;

  String selectedVehicleType = "";

  String driverRideStatus = "Driver Is Coming";
  StreamSubscription<DatabaseEvent>? tripRidesRequestInfoStreamSubscription;

  List<ActiveNearbyAvailableDrivers> onlineNearByAvailableDriversList = [];

  String userRideRequestStatus = "";

  bool requestPositionInfo = true;

  locateUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = cPosition;

    LatLng latLngPosition =
    LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
    CameraPosition cameraPosition =
    CameraPosition(target: latLngPosition, zoom: 20);

    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress =
    await AssistantMethods.searchAddressForGeographicCoordinates(
        userCurrentPosition!, context);
    print("This is our address" + humanReadableAddress);

    userName = userModelCurrentInfo!.name;
    userEmail = userModelCurrentInfo!.email;

    initializeGeoFireListener();
    //
    // AssistantMethods.readTripsKeysFromOnlineUser(context);
  }

  initializeGeoFireListener() {
    Geofire.initialize("activeDrivers");

    Geofire.queryAtLocation(
        userCurrentPosition!.latitude, userCurrentPosition!.longitude, 10)!
        .listen((map) {
      print(map);

      if (map != null) {
        var callBack = map["callBack"];

        switch (callBack) {
        // whenever driver becomes active/online
          case Geofire.onKeyEntered:
            ActiveNearbyAvailableDrivers activeNearbyAvailableDrivers =
            ActiveNearbyAvailableDrivers();
            activeNearbyAvailableDrivers.driverId = map["key"];
            activeNearbyAvailableDrivers.locationLatitude = map["latitude"];
            activeNearbyAvailableDrivers.locationLongitude = map["longitude"];

            GeoFireAssistant.activeNearbyAvailableDriversList
                .add(activeNearbyAvailableDrivers);
            if (activeNearbyDriverKeysLoaded == true) {
              displayActiveDriverOnUserMap();
            }

            break;

        // whenever any driver becomes non-active
          case Geofire.onKeyExited:
            GeoFireAssistant.deleteOfflineDriverFromList(map["key"]);
            displayActiveDriverOnUserMap();
            break;

        // when driver moves  - update driver location
          case Geofire.onKeyMoved:
            ActiveNearbyAvailableDrivers activeNearbyAvailableDrivers =
            ActiveNearbyAvailableDrivers();
            activeNearbyAvailableDrivers.locationLatitude = map["latitude"];
            activeNearbyAvailableDrivers.locationLongitude = map["longitude"];
            activeNearbyAvailableDrivers.driverId = map["key"];

            GeoFireAssistant.updateActiveNearByAvailableDriverLocation(
                activeNearbyAvailableDrivers);
            displayActiveDriverOnUserMap();
            break;

        // display those online active drivers on user's ,ap'
          case Geofire.onGeoQueryReady:
            activeNearbyDriverKeysLoaded = true;
            displayActiveDriverOnUserMap();
            break;
        }
      }
    });
  }

  displayActiveDriverOnUserMap() {
    setState(() {
      markerSet.clear();
      circleSet.clear();

      Set<Marker> driversMarkerSet = Set<Marker>();

      for (ActiveNearbyAvailableDrivers eachDriver
      in GeoFireAssistant.activeNearbyAvailableDriversList) {
        LatLng eachDriverActivePosition =
        LatLng(eachDriver.locationLatitude!, eachDriver.locationLongitude!);

        Marker marker = Marker(
          markerId: MarkerId(eachDriver.driverId!),
          position: eachDriverActivePosition,
          icon: activeNearbyIcon!,
          rotation: 360,
        );

        driversMarkerSet.add(marker);
      }

      setState(() {
        markerSet = driversMarkerSet;
      });
    });
  }

  createActiveNearbyDriverIconMarker() {
    if (activeNearbyIcon == null) {
      ImageConfiguration imageConfiguration =
      createLocalImageConfiguration(context, size: Size(2, 2));
      BitmapDescriptor.fromAssetImage(
          imageConfiguration, "assets/images/car_top_view.png")
          .then((value) {
        activeNearbyIcon = value;
      });
    }
  }

  Future<void> drawPolyLineFromOriginToDestination(bool darkTheme) async {
    var originPosition =
        Provider
            .of<AppInfo>(context, listen: false)
            .userPickupLocation;
    var destinationPosition =
        Provider
            .of<AppInfo>(context, listen: false)
            .userDropOffLocation;

    var originLatLng = LatLng(
        originPosition!.locationLatitude!, originPosition!.locationLongitude!);
    var destinationLatLng = LatLng(destinationPosition!.locationLatitude!,
        destinationPosition!.locationLongitude!);

    showDialog(
        context: context,
        builder: (BuildContext context) =>
            ProgressDialog(
              message: "Please Wait...",
            ));
    var directionDetailsInfo =
    await AssistantMethods.obtainOriginToDestinationDirectionDetails(
        originLatLng, destinationLatLng);
    setState(() {
      tripDirectionsDetailsInfo = directionDetailsInfo;
    });

    Navigator.pop(context);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodePolylinePointsResult =
    pPoints.decodePolyline(directionDetailsInfo.e_points!);
    pLineCoordinatesList.clear();

    if (decodePolylinePointsResult.isNotEmpty) {
      decodePolylinePointsResult.forEach((PointLatLng pointLatLng) {
        pLineCoordinatesList
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polylineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: darkTheme ? Colors.amberAccent : Colors.blue,
        polylineId: PolylineId("PolylineId"),
        jointType: JointType.round,
        points: pLineCoordinatesList,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        width: 5,
      );

      polylineSet.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if (originLatLng.latitude > destinationLatLng.latitude &&
        originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng =
          LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    } else if (originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = LatLngBounds(
          southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
          northeast:
          LatLng(destinationLatLng.latitude, originLatLng.longitude));
    } else if (originLatLng.latitude > destinationLatLng.latitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
        northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
      );
    } else {
      boundsLatLng =
          LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }

    newGoogleMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    Marker originMarker = Marker(
        markerId: MarkerId("originID"),
        infoWindow:
        InfoWindow(title: originPosition.locationName, snippet: "Origin"),
        position: originLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen));

    Marker destinationMarker = Marker(
      markerId: MarkerId("destinationID"),
      infoWindow: InfoWindow(
          title: destinationPosition.locationName, snippet: "Destination"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      markerSet.add(originMarker);
      markerSet.add(destinationMarker);
    });

    Circle originCircle = Circle(
        circleId: CircleId("originId"),
        fillColor: Colors.green,
        radius: 12,
        strokeWidth: 3,
        strokeColor: Colors.white,
        center: originLatLng);

    Circle destinationCircle = Circle(
        circleId: CircleId("destinationId"),
        fillColor: Colors.red,
        radius: 12,
        strokeWidth: 3,
        strokeColor: Colors.white,
        center: destinationLatLng);

    setState(() {
      circleSet.add(originCircle);
      circleSet.add(destinationCircle);
    });
  }

  void showSuggestedRideContainer() {
    setState(() {
      suggestedRideContainerHeight = 400;
      bottomPaddingOfMap = 400;
    });
  }

  void showSearchingForDriversContainer() {
    setState(() {
      searchingForDriverContainerHeight = 200;
    });
  }

  // getAddressFromLatLng() async {
  //   try {
  //     if (pickLocation != null) {
  //       GeoData data = await Geocoder2.getDataFromCoordinates(
  //           latitude: pickLocation!.latitude,
  //           longitude: pickLocation!.longitude,
  //           googleMapApiKey: mapKey);
  //
  //       setState(() {
  //         Directions userPickupAddress = Directions();
  //         userPickupAddress.locationLatitude = pickLocation!.latitude;
  //         userPickupAddress.locationLongitude = pickLocation!.longitude;
  //         userPickupAddress.humanReadableAddress = data.address;
  //
  //         Provider.of<AppInfo>(context, listen: false)
  //             .updatePickUpLocationAddress(userPickupAddress);
  //
  //         _address = data.address;
  //         print(_address.toString() + "current address");
  //       });
  //     }
  //   } catch (e) {
  //     print("Error: $e");
  //   }
  // }

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  saveRideRequestInformation(String selectedVehicleType) {
    //1. save the rideRequest Information
    referenceRideRequest =
        FirebaseDatabase.instance.ref().child("All Ride Requests").push();

    var originLocation = Provider
        .of<AppInfo>(context, listen: false)
        .userPickupLocation;
    var destinationLocation = Provider
        .of<AppInfo>(context, listen: false)
        .userDropOffLocation;

    Map originLocationMap = {
      //key:value
      "latitude": originLocation!.locationLatitude.toString(),
      "longitude": originLocation!.locationLongitude.toString(),
    };

    Map destinationLocationMap = {
      //key:value
      "latitude": destinationLocation!.locationLatitude.toString(),
      "longitude": destinationLocation!.locationLongitude.toString(),
    };

    Map userInformationMap = {
      "origin": originLocationMap,
      "destination": destinationLocationMap,
      "time": DateTime.now().toString(),
      "username": userModelCurrentInfo!.name,
      "userPhone": userModelCurrentInfo!.phone,
      "originAddress": originLocation.locationName,
      "destinationAddress": destinationLocation.locationName,
      "driverId": "waiting"
    };

    referenceRideRequest!.set(userInformationMap);

    tripRidesRequestInfoStreamSubscription =
        referenceRideRequest!.onValue.listen((eventSnap) async {
          if (eventSnap.snapshot.value == null) {
            return;
          }

          if ((eventSnap.snapshot.value as Map)["car_details"] != null) {
            setState(() {
              driverCarDetails =
                  (eventSnap.snapshot.value as Map)["car_details"].toString();
            });
          }

          if ((eventSnap.snapshot.value as Map)["driverPhone"] != null) {
            setState(() {
              driverPhone =
                  (eventSnap.snapshot.value as Map)["driverPhone"].toString();
            });
          }

          if ((eventSnap.snapshot.value as Map)["driverName"] != null) {
            setState(() {
              driverName =
                  (eventSnap.snapshot.value as Map)["driverName"].toString();
            });
          }

          if ((eventSnap.snapshot.value as Map)["ratings"] != null) {
            setState(() {
              driverRatings =
                  (eventSnap.snapshot.value as Map)["ratings"].toString();
            });
          }

          if ((eventSnap.snapshot.value as Map)["status"] != null) {
            setState(() {
              userRideRequestStatus =
                  (eventSnap.snapshot.value as Map)["status"].toString();
            });
          }

          if ((eventSnap.snapshot.value as Map)["driverLocation"] != null) {
            double driverCurrentPositionLat = double.parse(
                (eventSnap.snapshot.value as Map)["driverLocation"]["latitude"]
                    .toString());
            double driverCurrentPositionLng = double.parse(
                (eventSnap.snapshot.value as Map)["driverLocation"]["longitude"]
                    .toString());

            LatLng driverCurrentPositionLatLng = LatLng(
                driverCurrentPositionLat, driverCurrentPositionLng);

            //status = accepted
            if (userRideRequestStatus == "accepted") {
              updateArrivalTimeToUserPickupLocation(driverCurrentPositionLatLng);
            }

            //status = arrived
            if (userRideRequestStatus == "arrived") {
              setState(() {
                driverRideStatus = "Driver has arrived";
              });
            }

            //status = onTrip
            if (userRideRequestStatus == "onTrip") {
              updateReachingTimeToDropOffLocation(driverCurrentPositionLatLng);
            }

            //status == ended
            if (userRideRequestStatus == "ended") {
              if ((eventSnap.snapshot.value as Map)["fareAmount"] != null) {
                double fareAmount = double.parse(
                    (eventSnap.snapshot.value as Map)["fareAmount"].toString());

                var response = await showDialog(
                    context: context,
                    builder: (BuildContext context) =>
                        PayFareAmountDialog(
                          fareAmount: fareAmount,
                        )
                );
              }
            }
          }
        });

    onlineNearByAvailableDriversList = GeoFireAssistant.activeNearbyAvailableDriversList;
    searchNearestOnlineDrivers(selectedVehicleType);
  }

  searchNearestOnlineDrivers(selectedVehicleType) async {
    if (onlineNearByAvailableDriversList.length == 0) {
      // cancel / delete the ride request information
      referenceRideRequest!.remove();

      setState(() {
        polylineSet.clear();
        markerSet.clear();
        circleSet.clear();
        pLineCoordinatesList.clear();
      });

      Fluttertoast.showToast(msg: "No online nearest Driver Available");
      Fluttertoast.showToast(msg: "Search Again. \n Restarting App");

      Future.delayed(Duration(milliseconds: 4000), () {
        referenceRideRequest!.remove();
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => SplashScreen()));
      });

      return;
    }

    await retrieveOnlineDriversInformation(onlineNearByAvailableDriversList);
    print("Driver List: " + driversList.toString());

    for (int i = 0; i < driversList.length; i++) {
      if (driversList[i]["car_details"]["type"] == selectedVehicleType) {
        AssistantMethods.sendNotificationToDriverNow(
            driversList[i]["token"], referenceRideRequest!.key!, context);
      }
    }

    Fluttertoast.showToast(msg: "Notification Send Successfully");

    showSearchingForDriversContainer();

    await FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(referenceRideRequest!.key!)
        .child("driverId")
        .onValue
        .listen((eventRideRequestSnapshot) {
      print("Events snapshot: ${eventRideRequestSnapshot.snapshot.value}");
      if (eventRideRequestSnapshot.snapshot.value != null) {
        if (eventRideRequestSnapshot.snapshot.value != "waiting") {
          showUiForAssignedDriverInfo();
        }
      }
    });
  }

  updateArrivalTimeToUserPickupLocation(driverCurrentPositionLatLng) async {
    if (requestPositionInfo == true) {
      requestPositionInfo = false;

      LatLng userPickupPosition = LatLng(
          userCurrentPosition!.latitude, userCurrentPosition!.longitude);

      var directionDetailsInfo = await AssistantMethods
          .obtainOriginToDestinationDirectionDetails(
          driverCurrentPositionLatLng, userPickupPosition);

      if (directionDetailsInfo == null) {
        return;
      }

      setState(() {
        driverRideStatus =
            "Driver is coming" + directionDetailsInfo.duration_text.toString();
      });

      requestPositionInfo = true;
    }
  }

  updateReachingTimeToDropOffLocation(driverCurrentPositionLatLng) async {
    if (requestPositionInfo == true) {
      requestPositionInfo = false;

      var dropOffLocation = Provider
          .of<AppInfo>(context, listen: false)
          .userDropOffLocation;

      LatLng userDestinationPosition = LatLng(
          dropOffLocation!.locationLatitude!,
          dropOffLocation!.locationLongitude!);

      var directionDetailsInfo = await AssistantMethods
          .obtainOriginToDestinationDirectionDetails(
          driverCurrentPositionLatLng, userDestinationPosition);

      if (directionDetailsInfo == null) {
        return;
      }

      setState(() {
        driverRideStatus = "Going Towards Destination: " +
            directionDetailsInfo.duration_text.toString();
      });

      requestPositionInfo = true;
    }
  }

  showUiForAssignedDriverInfo() {
    setState(() {
      waitingResponseFromDriverContainerHeight = 0;
      searchLocationContainerHeight = 0;
      assignedDriverInfoContainerHeight = 200;
      suggestedRideContainerHeight = 0;
      bottomPaddingOfMap = 200;
    });
  }

  retrieveOnlineDriversInformation(List onlineNearestDriversList) async {
    driversList.clear();
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("drivers");

    for (int i = 0; i < onlineNearByAvailableDriversList.length; i++) {
      await ref.child(onlineNearestDriversList[i].driverId.toString())
          .once()
          .then((dataSnapshot) {
        var driverKetInfo = dataSnapshot.snapshot.value;

        driversList.add(driverKetInfo);
        print("Driver key information = " + driversList.toString());
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkIfLocationPermissionAllowed();
    currentUser = FirebaseAuth.instance.currentUser!;

    // displayActiveDriverOnUserMap();
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery
            .of(context)
            .platformBrightness == Brightness.dark;
    createActiveNearbyDriverIconMarker();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: _scaffoldState,
        drawer: DrawerScreen(),
        body: Stack(
          children: [

            // GOOGLE MAP
            GoogleMap(
              mapType: MapType.normal,
              myLocationEnabled: true,
              zoomControlsEnabled: true,
              zoomGesturesEnabled: true,
              compassEnabled: true,
              myLocationButtonEnabled: true,
              initialCameraPosition: _kGooglePlex,
              polylines: polylineSet,
              markers: markerSet,
              circles: circleSet,
              onMapCreated: (GoogleMapController controller) {
                _controllerGoogleMap.complete(controller);
                newGoogleMapController = controller;

                setState(() {
                  bottomPaddingOfMap = 200;
                });

                locateUserPosition();
              },
              onCameraMove: (CameraPosition? position) {
                if (pickLocation != position!.target) {
                  pickLocation = position.target;
                }
              },

            ),

            // PICK LOCATION
            // Align(
            //   alignment: Alignment.center,
            //   child: Padding(
            //     padding: const EdgeInsets.only(bottom: 35),
            //     child: Image.asset(
            //       "assets/images/pick.png",
            //       height: 45,
            //       width: 45,
            //     ),
            //   ),
            // ),

            // Custom Hamburger Icon

            // HAMBURGER ICON
            Positioned(
                top: 50,
                left: 20,
                child: Container(
                  child: GestureDetector(
                    onTap: () {
                      _scaffoldState.currentState!.openDrawer();
                    },
                    child: CircleAvatar(
                      backgroundColor:
                      darkTheme ? Colors.amber.shade400 : Colors.blue,
                      child: Icon(
                        Icons.menu,
                        color: darkTheme ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                )),

            //Pickup And Dop-off Location
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.fromLTRB(10, 50, 10, 10),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: darkTheme ? Colors.black : Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: darkTheme
                                  ? Colors.grey.shade900
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                // FROM
                                Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        color: darkTheme
                                            ? Colors.amber.shade400
                                            : Colors.blue,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          // FROM TITLE
                                          Text(
                                            "From",
                                            style: TextStyle(
                                                color: darkTheme
                                                    ? Colors.amber.shade400
                                                    : Colors.blue,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),

                                          // ADDRESS
                                          Text(
                                            Provider
                                                .of<AppInfo>(context)
                                                .userPickupLocation !=
                                                null
                                                ? (Provider
                                                .of<AppInfo>(
                                                context)
                                                .userPickupLocation!
                                                .locationName!)
                                                .substring(0, 24) +
                                                "..."
                                                : "Not getting address",
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10,),

                                Divider(
                                  height: 1,
                                  thickness: 2,
                                  color: darkTheme
                                      ? Colors.amber.shade400
                                      : Colors.blue,
                                ),
                                SizedBox(height: 10),

                                // TO
                                Padding(
                                  padding: EdgeInsets.all(5),
                                  child: GestureDetector(
                                    onTap: () async {
                                      //go to search places screen
                                      var responseFromSearchScreen =
                                      await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (c) =>
                                                  SearchPlacesScreen()));

                                      if (responseFromSearchScreen ==
                                          "ObtainedDropOffLocation") {
                                        setState(() {
                                          openNavigationDrawer = false;
                                        });
                                      }

                                      await drawPolyLineFromOriginToDestination(
                                          darkTheme);
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_outlined,
                                          color: darkTheme
                                              ? Colors.amber.shade400
                                              : Colors.blue,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            // TO TITLE
                                            Text(
                                              "To",
                                              style: TextStyle(
                                                  color: darkTheme
                                                      ? Colors.amber.shade400
                                                      : Colors.blue,
                                                  fontSize: 14,
                                                  fontWeight:
                                                  FontWeight.bold),
                                            ),

                                            // ADDRESS
                                            Text(
                                              Provider
                                                  .of<AppInfo>(context)
                                                  .userDropOffLocation !=
                                                  null
                                                  ? (Provider
                                                  .of<AppInfo>(
                                                  context)
                                                  .userDropOffLocation!
                                                  .locationName!)
                                                  .substring(0, 24) +
                                                  "..."
                                                  : "Where To..",
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14,
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 15),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // CHANGE PICKUP ADDRESS
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(
                                builder: (c) => PrecisePickupLocation()));
                          },
                          child: Text(
                            "Change Pick Up Address",
                            style: TextStyle(
                                color: darkTheme ? Colors.black : Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: darkTheme
                                  ? Colors.amber.shade400
                                  : Colors.blue,
                              textStyle: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(width: 10),

                        // SHOW FARE
                        ElevatedButton(
                          onPressed: () {
                            // remove later
                            showSuggestedRideContainer();

                            if (Provider
                                .of<AppInfo>(context, listen: false)
                                .userDropOffLocation != null) {
                              showSuggestedRideContainer();
                            }
                          },
                          child: Text(
                            "Show Fare",
                            style: TextStyle(
                                color:
                                darkTheme ? Colors.black : Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: darkTheme
                                  ? Colors.amber.shade400
                                  : Colors.blue,
                              textStyle: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ),

                      ],
                    )
                  ],
                ),
              ),
            ),

            // UI FOR RIDES SUGGESTIONS
            Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: suggestedRideContainerHeight,
                  decoration: BoxDecoration(
                      color: darkTheme ? Colors.black : Colors.white,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20),
                      )
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // USER PICKUP LOCATION
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: darkTheme
                                    ? Colors.amber.shade400
                                    : Colors.blue,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Icon(
                                Icons.star,
                                color: Colors.white,
                              ),
                            ),

                            SizedBox(width: 15,),

                            // USER PICKUP LOCATION
                            Text(Provider
                                .of<AppInfo>(context)
                                .userPickupLocation !=
                                null
                                ? (Provider
                                .of<AppInfo>(
                                context)
                                .userPickupLocation!
                                .locationName!)
                                .substring(0, 24) +
                                "..."
                                : "Not getting address",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold
                              ),),
                          ],
                        ),
                        SizedBox(height: 20,),

                        // USER DROP-OFF LOCATIOn
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Icon(
                                Icons.star,
                                color: Colors.white,
                              ),
                            ),

                            SizedBox(width: 15,),

                            Text(Provider
                                .of<AppInfo>(context)
                                .userDropOffLocation !=
                                null
                                ? (Provider
                                .of<AppInfo>(
                                context)
                                .userDropOffLocation!
                                .locationName!)
                                .substring(0, 24) +
                                "..."
                                : "Where To..",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold
                              ),),
                          ],
                        ),
                        SizedBox(height: 20,),

                        Text("SUGGESTED RIDES",
                          style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),

                        SizedBox(height: 20,),

                        // Available Rides i.e. Car , cnf or bike
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // CAR
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedVehicleType = "Car";
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: selectedVehicleType == "Car"
                                      ? (darkTheme
                                      ? Colors.amber.shade400
                                      : Colors.blue)
                                      : (darkTheme ? Colors.black54 : Colors
                                      .grey[100]),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(25),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                          "assets/images/car.png", scale: 10),

                                      SizedBox(height: 8,),

                                      Text("Car",
                                        style: TextStyle(
                                            color: selectedVehicleType == "Car"
                                                ? (darkTheme
                                                ? Colors.black
                                                : Colors.white)
                                                : (darkTheme
                                                ? Colors.white
                                                : Colors.black),
                                            fontWeight: FontWeight.bold
                                        ),),

                                      SizedBox(height: 2,),

                                      Text(
                                        tripDirectionsDetailsInfo != null
                                            ? "${((AssistantMethods
                                            .calculateFareAmountFromOriginToDestination(
                                            tripDirectionsDetailsInfo!) * 2) *
                                            107).toStringAsFixed(1)}"
                                            : "null",
                                        style: TextStyle(
                                          color: Colors.grey,
                                        ),)
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // CNG
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedVehicleType = "CNG";
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: selectedVehicleType == "CNG"
                                      ? (darkTheme
                                      ? Colors.amber.shade400
                                      : Colors.blue)
                                      : (darkTheme ? Colors.black54 : Colors
                                      .grey[100]),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(25),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                          "assets/images/cng.png", scale: 15),

                                      SizedBox(height: 8,),

                                      Text("CNG",
                                        style: TextStyle(
                                            color: selectedVehicleType == "CNG"
                                                ? (darkTheme
                                                ? Colors.black
                                                : Colors.white)
                                                : (darkTheme
                                                ? Colors.white
                                                : Colors.black),
                                            fontWeight: FontWeight.bold
                                        ),),

                                      SizedBox(height: 2,),

                                      Text(
                                        tripDirectionsDetailsInfo != null
                                            ? "${((AssistantMethods
                                            .calculateFareAmountFromOriginToDestination(
                                            tripDirectionsDetailsInfo!) * 1) *
                                            107).toStringAsFixed(1)}"
                                            : "null",
                                        style: TextStyle(
                                          color: Colors.grey,
                                        ),)
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // BIKE
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedVehicleType = "Bike";
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: selectedVehicleType == "Bike"
                                      ? (darkTheme
                                      ? Colors.amber.shade400
                                      : Colors.blue)
                                      : (darkTheme ? Colors.black54 : Colors
                                      .grey[100]),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(25),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                          "assets/images/bike.png", scale: 10),

                                      SizedBox(height: 8,),

                                      Text("Bike",
                                        style: TextStyle(
                                            color: selectedVehicleType == "Bike"
                                                ? (darkTheme
                                                ? Colors.black
                                                : Colors.white)
                                                : (darkTheme
                                                ? Colors.white
                                                : Colors.black),
                                            fontWeight: FontWeight.bold
                                        ),),

                                      SizedBox(height: 2,),

                                      Text(
                                        tripDirectionsDetailsInfo != null
                                            ? "${((AssistantMethods
                                            .calculateFareAmountFromOriginToDestination(
                                            tripDirectionsDetailsInfo!) * 0.8) *
                                            107).toStringAsFixed(1)}"
                                            : "null",
                                        style: TextStyle(
                                          color: Colors.grey,
                                        ),)
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20,),

                        // Request Ride Button
                        Expanded(child: GestureDetector(
                          onTap: () {
                            if (selectedVehicleType != "") {
                              saveRideRequestInformation(selectedVehicleType);
                            } else {
                              Fluttertoast.showToast(
                                  msg: "Please select a vehicle type \n Suggested Rides");
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: darkTheme
                                    ? Colors.amber.shade400
                                    : Colors.blue,
                                borderRadius: BorderRadius.circular(10)
                            ),
                            child: Center(
                              child: Text(
                                "Request a Ride",
                                style: TextStyle(
                                  color: darkTheme ? Colors.black : Colors
                                      .white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),),
                      ],
                    ),
                  ),
                )),
            SizedBox(height: 20,),

            // Requesting a Ride UI
            Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: Container(
                    height: searchingForDriverContainerHeight,
                    decoration: BoxDecoration(
                        color: darkTheme ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15))
                    ),
                    padding: EdgeInsets.all(20),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 24, vertical: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LinearProgressIndicator(
                              color: darkTheme ? Colors.amber.shade400 : Colors
                                  .blue
                          ),

                          SizedBox(height: 10,),

                          Center(
                            child: Text(
                              "Searching For a Driver...", style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey
                            ),
                            ),


                          ),
                          SizedBox(height: 10,),

                          GestureDetector(
                            onTap: () {
                              referenceRideRequest!.remove();
                              setState(() {
                                searchLocationContainerHeight = 0;
                                suggestedRideContainerHeight = 0;
                              });
                            },
                            child: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                  color: darkTheme ? Colors.black : Colors
                                      .white,
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                      width: 1, color: Colors.grey)
                              ),

                              child: Icon(Icons.close, size: 35),
                            ),
                          ),

                          SizedBox(height: 15,),

                          Container(
                            width: double.infinity,
                            child: Text(
                              "Cancel",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                )),

            //Assigned driver info UI
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: assignedDriverInfoContainerHeight,
                  decoration: BoxDecoration(
                      color: darkTheme ? Colors.black : Colors.white,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Text(
                          driverRideStatus,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5,),
                        Divider(thickness: 1,
                          color: darkTheme ? Colors.grey : Colors.grey[300],),
                        SizedBox(height: 5,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: darkTheme
                                          ? Colors.amber.shade400
                                          : Colors.lightBlue,
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: Icon(Icons.person,
                                    color: darkTheme ? Colors.black : Colors
                                        .white,
                                  ),
                                ),

                                SizedBox(width: 10,),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      driverName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    Row(
                                      children: [
                                        Icon(Icons.star, color: Colors.orange,),

                                        SizedBox(width: 5,),

                                        Text(
                                          "4.5",
                                          style: TextStyle(
                                            color: Colors.grey,
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                )
                              ],
                            ),

                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Image.asset("assets/images/car.png", scale: 10),

                                Text(
                                  driverCarDetails,
                                  style: TextStyle(fontSize: 12),
                                )
                              ],
                            )
                          ],
                        ),

                        SizedBox(height: 5,),
                        Divider(thickness: 1,
                          color: darkTheme ? Colors.grey : Colors.grey[300],),
                        ElevatedButton.icon(
                            onPressed: () {
                              _makePhoneCall("tel: ${driverPhone}");
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: darkTheme
                                  ? Colors.amber.shade400
                                  : Colors.blue,),
                            icon: Icon(Icons.phone),
                            label: Text("Call Driver"))
                      ],
                    ),
                  ),
                )),


            // Positioned(
            //     top:40,
            //     right:20,
            //     left:20,
            //     child: Container(
            //       decoration: BoxDecoration(
            //         border: Border.all(
            //           color: Colors.black
            //         ),
            //       ),
            //       padding: EdgeInsets.all(20),
            //       child: Text(Provider.of<AppInfo>(context).userPickupLocation!=null
            //           ? (Provider.of<AppInfo>(context).userPickupLocation!.locationName!).substring(0,24) +"...":
            //       "Not getting address" ,
            //       overflow: TextOverflow.visible,softWrap: true,),
            //     ))
          ],
        ),
      ),
    );
  }
}
