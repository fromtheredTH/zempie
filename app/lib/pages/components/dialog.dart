import 'package:easy_localization/src/public_ext.dart';
import 'package:app/global/app_colors.dart';
import 'package:app/helpers/common_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class AppDialog {
  static showAlertDialog(BuildContext context, Function() onConfirm, String title, String content,
      {String btnLabel = "", bool onBack = true}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 0.0,
          contentPadding: const EdgeInsets.all(25),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const SizedBox(width: 24),
                  const Spacer(),
                  Text(
                    title,
                    style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Image.asset('assets/image/ic_close.png', width: 24, height: 24))
                ],
              ),
              SizedBox(height: 10),
              Text(
                content,
                style: const TextStyle(
                  color: appColorText3,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: Color(0xFFBFBFBF), width: 1),
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
          ),
        );
      },
    );
  }

  static showConfirmDialog(BuildContext context, String title, String content, Function() onConfirm,
      {String confirmLabel = "", String cancelLabel = ""}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 0.0,
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 35),
              if (title.isNotEmpty)
                Text(
                  title,
                  style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              if (title.isNotEmpty) const SizedBox(height: 20),
              Text(
                content,
                style: const TextStyle(
                  color: appColorText4,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
            ],
          ),
          buttonPadding: EdgeInsets.zero,
          actionsPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          actionsAlignment: MainAxisAlignment.start,
          actionsOverflowButtonSpacing: 1,
          actions: <Widget>[
            SizedBox(
              width: double.infinity,
              height: 48,
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        height: 48,
                        decoration:
                            BoxDecoration(borderRadius: BorderRadius.circular(5), color: appColorGrey3),
                        child: Center(
                          child: Text(
                            cancelLabel.isEmpty ? "cancel".tr() : cancelLabel,
                            style: const TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        onConfirm();
                      },
                      child: Container(
                        height: 48,
                        decoration:
                            BoxDecoration(borderRadius: BorderRadius.circular(5), color: appColorOrange2),
                        child: Center(
                          child: Text(
                            confirmLabel.isEmpty ? "confirm".tr() : confirmLabel,
                            style: const TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
  }
}
