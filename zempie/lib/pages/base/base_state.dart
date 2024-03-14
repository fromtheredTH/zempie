import 'package:app/Constants/utils.dart';
import 'package:dio/dio.dart';
import 'package:event_bus_plus/event_bus_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:app/global/app_api_c.dart';
import 'package:app/global/app_api_p.dart';
import 'package:app/global/app_get_it.dart';
import 'package:app/helpers/common_util.dart';
import 'package:get/get.dart' hide Trans;

abstract class BaseState<T extends StatefulWidget> extends State<T> {
  final ApiC apiC = getIt<ApiC>();
  final ApiP apiP = getIt<ApiP>();
  bool isLoading = false;
  final event = getIt<EventBus>();
  final dio = getIt<Dio>();

  void showLoading() {
    Utils.showDialogWidget(context);
  }

  void hideLoading() {
    Get.back();
  }

  void hideKeyboard() {
    if (keyboardIsVisible(context)) {
      FocusScope.of(context).requestFocus(FocusNode());
    }
  }
}
