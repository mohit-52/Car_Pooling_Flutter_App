import 'dart:ui';

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


  String _pickupLocation = '';
  String _dropoffLocation = '';
  DateTime _pickupDate = DateTime.now();
  DateTime _dropoffDate = DateTime.now();

  Future<void> _selectDate(BuildContext context, bool isPickupDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isPickupDate) {
          _pickupDate = picked;
        } else {
          _dropoffDate = picked;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

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
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: pickUpTextEditingController,
                          decoration: InputDecoration(
                            labelText: 'Pickup Location',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _pickupLocation = value;
                            });
                          },
                        ),
                        // SizedBox(height: 16.0),
                        // TextField(
                        //   decoration: InputDecoration(
                        //     labelText: 'Dropoff Location',
                        //     border: OutlineInputBorder(),
                        //   ),
                        //   onChanged: (value) {
                        //     setState(() {
                        //       _dropoffLocation = value;
                        //     });
                        //   },
                        // ),
                        // SizedBox(height: 16.0),
                        // Row(
                        //   children: <Widget>[
                        //     Expanded(
                        //       child: Text(
                        //         _pickupDate == null
                        //             ? 'Pickup Date: '
                        //             : 'Pickup Date: ${_pickupDate.toString()}',
                        //       ),
                        //     ),
                        //     ElevatedButton(
                        //       onPressed: () => _selectDate(context, true),
                        //       child: Text('Select Pickup Date'),
                        //     ),
                        //   ],
                        // ),
                        // SizedBox(height: 16.0),
                        // Row(
                        //   children: <Widget>[
                        //     Expanded(
                        //       child: Text(
                        //         _dropoffDate == null
                        //             ? 'Dropoff Date: '
                        //             : 'Dropoff Date: ${_dropoffDate.toString()}',
                        //       ),
                        //     ),
                        //     ElevatedButton(
                        //       onPressed: () => _selectDate(context, false),
                        //       child: Text('Select Dropoff Date'),
                        //     ),
                        //   ],
                        // ),
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
            print("My current location is: ");
            print(value.latitude.toString() + value.longitude.toString());

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
      print("My current location is: ");
      print(value.latitude.toString() + value.longitude.toString());

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
