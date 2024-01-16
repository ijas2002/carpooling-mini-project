import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:drivers/models/user_model.dart';
import 'package:geolocator/geolocator.dart';

import '../models/driver_data.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

User? currentUser;
StreamSubscription <Position>? streamSubscriptionPosition;
StreamSubscription <Position>? streamSubscriptionDriverLivePosition;

UserModel? userModelCurrentInfo;

Position? driverCurrentPosition;

DriverData  onlineDriverData = DriverData();

String? driverVehicleType ="";
AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();

