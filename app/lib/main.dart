import 'dart:io';

import 'package:app/Constants/ColorConstants.dart';
import 'package:app/Constants/Constants.dart';
import 'package:app/pages/screens/splash.dart';
import 'package:app/push_notification.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:permission_handler/permission_handler.dart';

import 'global/app_get_it.dart';
import 'global/global.dart';
import 'global/local_service.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await FlutterDownloader.initialize(debug: true, ignoreSsl: true);
  setupLocator();
  await Permission.notification.request();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor:ColorConstants.colorBg1, // Replace with your desired color
      statusBarBrightness: Platform.isIOS ? Brightness.dark : Brightness.light,
      statusBarIconBrightness: Platform.isIOS ? Brightness.dark : Brightness.light
  ));


  //fcm
  await initFcm();
  await Constants.fetchChatRooms();

  runApp(
    EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ko')],
        path: 'assets/translations',
        // <-- change the path of the translation files
        fallbackLocale: const Locale('en'),
        child: const MyApp()),
  );
}

Future<void> initFcm() async {
  await PushNotificationService().setupInteractedMessage();
  FirebaseMessaging.onBackgroundMessage(PushNotificationService.firebaseMessagingBackgroundHandler);

  FirebaseMessaging.instance.getToken().then((token) {
    print('token:' + (token ?? ''));
    LocalService.setToken((token ?? ''));
    gPushKey = (token ?? '');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      title: 'zempie',
      initialRoute: '/splash',
      themeMode: Platform.isIOS ? ThemeMode.dark : ThemeMode.light,
      darkTheme: ThemeData(brightness: Platform.isIOS ? Brightness.dark : Brightness.light),
      routes: {
        '/splash': (context) => const SplashPage(),
      },
      navigatorKey: navigatorKey,
    );
  }
}