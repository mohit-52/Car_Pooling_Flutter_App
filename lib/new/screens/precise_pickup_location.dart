import 'dart:async';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../assistants/assistant_methods.dart';
import '../global/map_key.dart';
import '../infoHandler/app_info.dart';
import '../modals/directions.dart';

class PrecisePickupLocation extends StatefulWidget {
  const PrecisePickupLocation({Key? key}) : super(key: key);

  @override
  State<PrecisePickupLocation> createState() => _PrecisePickupLocationState();
}

class _PrecisePickupLocationState extends State<PrecisePickupLocation> {

  LatLng? pickLocation;
  loc.Location location = loc.Location();
  String? _address;

  final Completer<GoogleMapController> _controllerGoogleMap = Completer<GoogleMapController>();
  GoogleMapController? newGoogleMapController;

  Position? userCurrentPosition;
  double bottomPaddingOfMap = 0;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

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

  }

  getAddressFromLatLng() async {
    try {
        GeoData data = await Geocoder2.getDataFromCoordinates(
            latitude: pickLocation!.latitude,
            longitude: pickLocation!.longitude,
            googleMapApiKey: mapKey);

        setState(() {
          Directions userPickupAddress = Directions();
          userPickupAddress.locationLatitude = pickLocation!.latitude;
          userPickupAddress.locationLongitude = pickLocation!.longitude;
          userPickupAddress.locationName = data.address;

          Provider.of<AppInfo>(context, listen: false).updatePickUpLocationAddress(userPickupAddress);

          // _address = data.address;
          print(_address.toString() + "current address");
        });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(top:100, bottom: bottomPaddingOfMap),
            mapType: MapType.normal,
            myLocationEnabled: true,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;

              setState(() {
                bottomPaddingOfMap =50;
              });

              locateUserPosition();
            },
            onCameraMove: (CameraPosition? position) {
              if (pickLocation != position!.target) {
                pickLocation = position.target;
              }
            },
            onCameraIdle: () {
              getAddressFromLatLng();
            },
          ),

          // PICK LOCATION
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 35),
              child: Image.asset(
                "assets/images/pick.png",
                height: 45,
                width: 45,
              ),
            ),
          ),


          Positioned(
              top:40,
              right:20,
              left:20,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black
                  ),
                ),
                padding: EdgeInsets.all(20),
                child: Text(Provider.of<AppInfo>(context).userPickupLocation!=null
                    ? (Provider.of<AppInfo>(context).userPickupLocation!.locationName!).substring(0,24) +"...":
                "Not getting address" ,
                overflow: TextOverflow.visible,softWrap: true,),
              )),

          Positioned(
              bottom:0,
              left:0,right:0,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: ElevatedButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: darkTheme? Colors.amber.shade400:Colors.blue,
                      textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold
                      )
                  ),
                  child: Text(
                    "Set Current Location"
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
