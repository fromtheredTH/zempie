import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';

import 'package:app/global/app_event.dart';
import 'package:app/helpers/common_util.dart';
import 'package:app/models/dto/chat_msg_dto.dart';
import 'package:app/models/dto/chat_room_dto.dart';
import 'package:app/write_log.dart';
import 'package:event_bus_plus/res/event_bus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:app/global/global.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import 'global/app_get_it.dart';

// ignore: slash_for_doc_comments
/**
 * Documents added by Alaa, enjoy ^-^:
 * There are 3 major things to consider when dealing with push notification :
 * - Creating the notification
 * - Hanldle notification click
 * - App status (foreground/background and killed(Terminated))
 *
 * Creating the notification:
 *
 * - When the app is killed or in background state, creating the notification is handled through the back-end services.
 *   When the app is in the foreground, we have full control of the notification. so in this case we build the notification from scratch.
 *
 * Handle notification click:
 *
 * - When the app is killed, there is a function called getInitialMessage which
 *   returns the remoteMessage in case we receive a notification otherwise returns null.
 *   It can be called at any point of the application (Preferred to be after defining GetMaterialApp so that we can go to any screen without getting any errors)
 * - When the app is in the background, there is a function called onMessageOpenedApp which is called when user clicks on the notification.
 *   It returns the remoteMessage.
 * - When the app is in the foreground, there is a function flutterLocalNotificationsPlugin, is passes a future function called onSelectNotification which
 *   is called when user clicks on the notification.
 *
 * */
class PushNotificationService {
  ///When the app is background, you hear a notification
  @pragma('vm:entry-point')
  static Future firebaseMessagingBackgroundHandler(RemoteMessage? message) async {
    print('Handling a background message ${message?.messageId}');

    try {
      final meta = jsonDecode(message!.data['meta']);
      int fcmType = meta['fcmType'];
      if (fcmType == 10) {
        //dm
        SendPort? send1 = IsolateNameServer.lookupPortByName('firbase_port1');
        send1?.send([jsonEncode(meta['chat']), jsonEncode(meta['room'])]);
        SendPort? send2 = IsolateNameServer.lookupPortByName('firbase_port2');
        send2?.send([jsonEncode(meta['chat']), jsonEncode(meta['room'])]);
      }
    } catch (e) {
      print(e);
    }
  }

  // It is assumed that all messages contain a data field with the key 'type'
  Future<void> setupInteractedMessage() async {
    await Firebase.initializeApp();
// Get any messages which caused the application to open from a terminated state.
    // If you want to handle a notification click when the app is terminated, you can use `getInitialMessage`
    // to get the initial message, and depending in the remoteMessage, you can decide to handle the click
    // This function can be called from anywhere in your app, there is an example in main file.
    // RemoteMessage initialMessage =
    //     await FirebaseMessaging.instance.getInitialMessage();
    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    // if (initialMessage != null && initialMessage.data['type'] == 'chat') {
    // Navigator.pushNamed(context, '/chat',
    //     arguments: ChatArguments(initialMessage));
    // }
// Also handle any interaction when the app is in the background via a
    // Stream listener
    // This function is called when the app is in the background and user clicks on the notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('onMessageOpenedApp data: ${message.data}');
      onClick(message.data);
    });
    // FirebaseMessaging.onBackgroundMessage((RemoteMessage message) async {
    //   print('Handling a background message ${message.messageId}');
    // });
    await enableIOSNotifications();
    await registerNotificationListeners();
  }

  void onClick(Map<String, dynamic> data) {
    print(data);
    final meta = jsonDecode(data['meta']);
    int fcmType = meta['fcmType'];
    if (fcmType == 10) {
      //dm
      int chatRoomId = meta['room']['id'];
      if (gChatRoomUid == chatRoomId) {
        //현재 입장한 채팅방의 채팅 푸시면 리턴
        return;
      }
      getIt<EventBus>()
          .fire(ChatProcEvent(ChatMsgDto.fromJson(meta['chat']), ChatRoomDto.fromJson(meta['room'])));
    }
  }

  registerNotificationListeners() async {
    AndroidNotificationChannel channel = androidNotificationChannel();
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    var androidSettings = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOSSettings = const DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    var initSetttings = InitializationSettings(android: androidSettings, iOS: iOSSettings);
    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onDidReceiveNotificationResponse: (details) async {
      // This function handles the click in the notification when the app is in foreground
      // Get.toNamed(NOTIFICATIOINS_ROUTE);
      String? payload = details.payload;
      if (payload != null) {
        print('onMessageOpenedApp data: ${payload}');
        Map<String, dynamic> data = json.decode(payload);
        onClick(data);
      }
    });
// onMessage is called when the app is in foreground and a notification is received
    FirebaseMessaging.onMessage.listen((RemoteMessage? message) {
      // Get.find<HomeController>().getNotificationsNumber();
    //  print(message);
     WriteLog.write("fcm come time:  ${DateTime.now()}\n message : ${message} \n  ",fileName: 'fcmCome.txt');
     WriteLog.write("fcm come time:  ${DateTime.now()}\n message : ${message} \n  ",fileName: 'AllInOne.txt');

      RemoteNotification? notification = message!.notification;
// If `onMessage` is triggered with a notification, construct our own
      // local notification to show to users using the created channel.

      String body = notification?.body ?? '';
      try {
        final meta = jsonDecode(message.data['meta']);
        
        int fcmType = meta['fcmType'];
        if (fcmType == 10) {
          //dm
          body = chatContent(meta['chat']['contents'], meta['chat']['type']);

          int chatRoomId = meta['room']['id'];
          getIt<EventBus>()
              .fire(ChatReceivedEvent(ChatMsgDto.fromJson(meta['chat']), ChatRoomDto.fromJson(meta['room'])));

          if (gChatRoomUid == chatRoomId) {
            //현재 입장한 채팅방의 채팅 푸시면 리턴
            return;
          }
        } else if (fcmType == 0) {
          //시스템 노티
          if ((notification?.title ?? '') == 'Leave') {
            // 방탈퇴
            try {
              int user_id = int.parse(body.split(",")[0].split(":")[1].trim());
              int room_id = int.parse(body.split(",")[1].split(":")[1].trim());

              getIt<EventBus>().fire(ChatLeaveEvent2(user_id, room_id));
            } catch (error) {}
          }
          return;
        }
      } catch (e) {
        print(e);
        return;
      }

      if (notification != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            body,
            NotificationDetails(
                android: AndroidNotificationDetails(
                  channel.id,
                  channel.name,
                  channelDescription: channel.description,
                  // icons: message.notification?.android?.smallIcon,
                  playSound: true,
                ),
                iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true)),
            payload: jsonEncode(message.data));
      }
    });
  }

  enableIOSNotifications() async {
    await FirebaseMessaging.instance
        .requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    )
        .then((settings) {
      print('User granted permission: ${settings.authorizationStatus}');
    });

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: false, // Required to display a heads up notification
      badge: false,
      sound: false,
    );
  }

  androidNotificationChannel() => const AndroidNotificationChannel(
        'flamingo_high_importance_channel', // id
        'Flamingo High Importance Notifications', // title
        description: 'This channel is used for Flamingo important notifications.', // description
        importance: Importance.defaultImportance,
      );
}
