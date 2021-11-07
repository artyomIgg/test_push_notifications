import 'dart:io';

import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationService {
  final FirebaseMessaging _fbm = FirebaseMessaging.instance;
  final FirebaseInAppMessaging qwe = FirebaseInAppMessaging();

  Future initialise() async {
    if(Platform.isIOS) {
      _fbm.requestPermission();
    }

    FirebaseMessaging.onMessage.listen((event) {
      print('OnMessage $event');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      print('onMessageOpenedApp $event');
    });
  }
}