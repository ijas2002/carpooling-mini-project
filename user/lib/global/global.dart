import 'package:firebase_auth/firebase_auth.dart';
import 'package:users/models/direction_detail_info.dart';
import 'package:users/models/user_model.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

User? currentUser;

UserModel? userModelCurrentInfo;

List driversList=[];

String cloudMessagingServerToken = "key=AAAAoyUOfQY:APA91bFpIa5hYtzfOI-Osg0TieJXxzjW-qAjdFUZZ1oNEnN0BDWOAlIVnHwsZl87rc_5G2Cl_rpITJxKOp7tfbfl085eaFH32M6uHY3OL-ON-8P8rmTqPIg9lkQ78mnIsKM2zkn4PtBE";

String userDropOffAddress = "";
DirectionDetailsInfo? tripDirectionDetailsInfo;

String driverCarDetails="";
String driverName="";
String driverPhone="";
String driverRatings="";





double countRatingStars = 0.0;
String titleStartRating = "";


