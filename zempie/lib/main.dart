import 'dart:async';
import 'dart:io';

import 'package:app/Constants/ColorConstants.dart';
import 'package:app/Constants/Constants.dart';
import 'package:app/global/DioClient.dart';
import 'package:app/pages/components/app_text.dart';
import 'package:app/pages/screens/bottomnavigationscreen/bottomNavBarScreen.dart';
import 'package:app/pages/screens/discover/DiscoverGameDetails.dart';
import 'package:app/pages/screens/discover/PostDetailScreen.dart';
import 'package:app/pages/screens/profile/profile_screen.dart';
import 'package:app/pages/screens/splash.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'package:app/push_notification.dart';
import 'package:app/service/social_service.dart';
import 'package:app_links/app_links.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uni_links/uni_links.dart';
import 'package:intl/intl_standalone.dart';
import 'Constants/utils.dart';
import 'firebase_options.dart';
import 'global/app_get_it.dart';
import 'global/global.dart';
import 'global/local_service.dart';
import 'models/GameModel.dart';
import 'models/PostModel.dart';
import 'models/User.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  await EasyLocalization.ensureInitialized();
  await FlutterDownloader.initialize(debug: true, ignoreSsl: true);
  GetIt.I.registerSingleton<SocialService>(SocialService());
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

  findSystemLocale().then((value) {
    print("로케이션 값음 ${value}");
    Intl.systemLocale = "en_US";
  });

  runApp(
    EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ko')],
        path: 'assets/translations',
        // <-- change the path of the translation files
        fallbackLocale: const Locale('en'),
        child: MyApp()),
  );

  AndroidOptions _getAndroidOptions() => const AndroidOptions(
    encryptedSharedPreferences: true,
  );
  final _storage = new FlutterSecureStorage(aOptions: _getAndroidOptions());
  String language = await _storage.read(key: "language") ?? "";
  String translationCode = await _storage.read(key: "translationCode") ?? "";
  String translationName = await _storage.read(key: "translationName") ?? "";
  Constants.cachingKey = DateTime.now().millisecondsSinceEpoch.toString();
  if(language.isEmpty){
    String languageCode = PlatformDispatcher.instance.locale.languageCode;
    _storage.write(key: "language", value: languageCode);
    if(languageCode != "ko"){
      languageCode = "en";
    }
    language = languageCode;
    translationCode = languageCode;
    if(translationCode == "ko"){
      translationName = "한국어";
    }else{
      translationName = "English";
    }
    _storage.write(key: "translationCode", value: translationCode);
    _storage.write(key: "translationName", value: translationName);
  }

  Constants.languageCode = language;
  Constants.translationCode = translationCode;
  Constants.translationName = translationName;

  // Create customized instance which can be registered via dependency injection
  final InternetConnectionChecker customInstance =
  InternetConnectionChecker.createInstance(
    checkTimeout: const Duration(seconds: 1),
    checkInterval: const Duration(seconds: 1),
  );

  // Check internet connection with created instance
  execute(customInstance);
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


Future<void> execute(
    InternetConnectionChecker internetConnectionChecker
    ) async {
  // Simple check to see if we have Internet
  // ignore: avoid_print
  print('''The statement 'this machine is connected to the Internet' is: ''');
  final bool isConnected = await InternetConnectionChecker().hasConnection;
  // ignore: avoid_print
  print(
    isConnected.toString(),
  );
  // returns a bool

  // We can also get an enum instead of a bool
  // ignore: avoid_print
  print(
    'Current status: ${await InternetConnectionChecker().connectionStatus}',
  );
  // Prints either InternetConnectionStatus.connected
  // or InternetConnectionStatus.disconnected

  // actively listen for status updates
  final StreamSubscription<InternetConnectionStatus> listener =
  InternetConnectionChecker().onStatusChange.listen(
        (InternetConnectionStatus status) {
      switch (status) {
        case InternetConnectionStatus.connected:
        // ignore: avoid_print
          print('Data connection is available.');
          break;
        case InternetConnectionStatus.disconnected:
        // ignore: avoid_print
        //   var snackBar = SnackBar(
        //       backgroundColor: ColorConstants.red,
        //       behavior: SnackBarBehavior.floating, content: Row(
        //     mainAxisAlignment: MainAxisAlignment.start,
        //     crossAxisAlignment: CrossAxisAlignment.center,
        //     children: [
        //       SizedBox(width: 10,),
        //       Icon(Icons.wifi_off_rounded, size: 16, color: Colors.white,),
        //       Expanded(
        //           child: AppText(
        //             text: "네트워크 연결을 확인해 주세요",
        //           )
        //       ),
        //       SizedBox(width: 10,),
        //     ],
        //   ));

          Utils.showToast("네트워크 연결을 확인해 주세요");
          break;
      }
    },
  );

  // close listener after 30 seconds, so the program doesn't run forever
  await Future<void>.delayed(const Duration(seconds: 30));
  await listener.cancel();
}

class MyApp extends StatelessWidget {

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

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
      home: SplashPage(),
      navigatorObservers: <NavigatorObserver>[observer],
      themeMode: Platform.isIOS ? ThemeMode.dark : ThemeMode.light,
      darkTheme: ThemeData(brightness: Platform.isIOS ? Brightness.dark : Brightness.light),
      navigatorKey: Constants.navigatorKey,
    );
  }
}