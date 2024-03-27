import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController pickUpTextEditingController =
  TextEditingController();

  final Completer<GoogleMapController> _controller =
  Completer<GoogleMapController>();
  static const CameraPosition _kGooglePlex =
  CameraPosition(target: LatLng(28.2487, 77.0635), zoom: 14);
  final List<Marker> _markers = <Marker>[
    Marker(
        markerId: MarkerId('1'),
        position: LatLng(28.2487, 77.0635),
        infoWindow: InfoWindow(title: "My"))
  ];

  String pickupAdd = 'Click Map Icon to Update Address';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          'My Location',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child:Stack(
          children: [
            GoogleMap(
              initialCameraPosition: _kGooglePlex,
              mapType: MapType.hybrid,
              compassEnabled: false,
              zoomControlsEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
            Positioned(
              top: 16.0,
              left: 16.0,
              right: 16.0,
              child: Container(
                color: Colors.white,

                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5), // Adjust opacity as needed
                      borderRadius: BorderRadius.circular(100),

                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: pickUpTextEditingController,
                          enabled: false,
                          decoration: InputDecoration(
                            labelText: pickupAdd,
                            border: OutlineInputBorder(),
                            labelStyle: TextStyle(
                              color: Colors.black
                            )
                          ),
                        ),

                      ],
                    ),
                  ),

              ),
            ),
          ],
        ),


      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.location_on_outlined),
        onPressed: () {
          getUserCurrentLocation().then((value) async {
            // print("My current location is: ");
            // print(value.latitude.toString() + value.longitude.toString());
            loadData();
            _markers.add(Marker(
                markerId: MarkerId('2'),
                position: LatLng(value.latitude, value.longitude),
                infoWindow: InfoWindow(title: "My Current Location")));

            CameraPosition cameraPosition = CameraPosition(
                target: LatLng(value.latitude, value.longitude), zoom: 14);

            final GoogleMapController controller = await _controller.future;

            controller
                .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

            setState(() {});
          });
        },
      ),

    );
  }


  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {
      print("Error" + error.toString());
    });

    return await Geolocator.getCurrentPosition();
  }

  loadData() {
    getUserCurrentLocation().then((value) async {
      // print("My current location is: ");
      // print(value.latitude.toString() + value.longitude.toString());
      List<Placemark> placemarks = await placemarkFromCoordinates(value.latitude, value.longitude);
      setState((){
        pickupAdd =  placemarks.reversed.last.subLocality.toString() +", "+
            placemarks.reversed.last.locality.toString() +", "+
            placemarks.reversed.last.administrativeArea.toString() +", "+
            placemarks.reversed.last.postalCode.toString() +", "+
            placemarks.reversed.last.country.toString();
            // placemarks.reversed.last.street.toString() +", "+
            // placemarks.reversed.last.isoCountryCode.toString() +", "+
            // placemarks.reversed.last.subAdministrativeArea.toString() +", "+
            // placemarks.reversed.last.thoroughfare.toString() +", "+
      });
      _markers.add(Marker(
          markerId: MarkerId('2'),
          position: LatLng(value.latitude, value.longitude),
          infoWindow: InfoWindow(title: "My Current Location")));

      CameraPosition cameraPosition = CameraPosition(
          target: LatLng(value.latitude, value.longitude), zoom: 18);

      final GoogleMapController controller = await _controller.future;

      controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

      setState(() {});
    });
  }
}
