import 'package:car_pooling/new/modals/direction_details_info.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../modals/user_model.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
User? currentUser;

UserModel? userModelCurrentInfo;

String cloudMessagingServerToken = "key=AAAAFrTAk9A:APA91bGnByOEih2rNyCmkf-J4fhL0AJVgi4chTIhvMJY6i2ldQncqxkwnfLiZHqj3Ztjb9hfmN7n4ZpHjmOn02Pj0USXPZmFX5D_dIJCgHRM7jjNUU98XfxkZusXJPWkXkov2SWfZTaw";
List driversList = [];

DirectionDetailsInfo? tripDirectionsDetailsInfo;
String userDropOffAddress = "";
String driverCarDetails = "";
String driverName = "";
String driverRatings = "";
String driverPhone = "";

double countRatingStars = 0.0;
String titleStarsRating = "";

