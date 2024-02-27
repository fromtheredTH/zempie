import 'package:easy_localization/src/public_ext.dart';
import 'package:app/global/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ReportDialog extends StatefulWidget {
  ReportDialog({Key? key, this.onConfirm}) : super(key: key);

  final onConfirm;

  @override
  ReportDialogState createState() => ReportDialogState();
}

class ReportDialogState extends State<ReportDialog> {
  int type = 0;
  TextEditingController infoController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<bool> onBackPressed() async {
    Navigator.pop(context);
    return true;
  }

  void onConfirm() {
    if (infoController.text.isEmpty) return;
    widget.onConfirm(infoController.text, type);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: Container(
          width: double.infinity,
          height: double.infinity,
          color: appColorHint.withOpacity(0.3),
          child: Align(
            alignment: Alignment.center,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 50),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "report_title".tr(),
                    style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "report_content".tr(),
                    style: const TextStyle(color: appColorText4, fontSize: 16),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Image.asset('assets/image/ic_chat_add_radio_off.png', width: 20, height: 20),
                      const SizedBox(width: 8),
                      Text(
                        "report_reason_1".tr(),
                        style:
                            const TextStyle(color: appColorText4, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Image.asset('assets/image/ic_chat_add_radio_off.png', width: 20, height: 20),
                      const SizedBox(width: 8),
                      Text(
                        "report_reason_2".tr(),
                        style:
                            const TextStyle(color: appColorText4, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Image.asset('assets/image/ic_chat_add_radio_off.png', width: 20, height: 20),
                      const SizedBox(width: 8),
                      Text(
                        "report_reason_3".tr(),
                        style:
                            const TextStyle(color: appColorText4, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Image.asset('assets/image/ic_chat_add_radio_off.png', width: 20, height: 20),
                      const SizedBox(width: 8),
                      Text(
                        "report_reason_4".tr(),
                        style:
                            const TextStyle(color: appColorText4, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Image.asset('assets/image/ic_chat_add_radio_off.png', width: 20, height: 20),
                      const SizedBox(width: 8),
                      Text(
                        "report_reason_5".tr(),
                        style:
                            const TextStyle(color: appColorText4, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    maxLines: 3,
                    minLines: 3,
                    style: const TextStyle(color: appColorText4, fontSize: 16),
                    controller: infoController,
                    decoration: InputDecoration(
                        counterText: "",
                        hintText: "report_reason_extra".tr(),
                        hintStyle: TextStyle(color: appColorHint, fontSize: 16),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: appColorText2,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(4)),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: appColorText2,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(4)),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16)),
                  ),
                  const SizedBox(height: 15),
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
                                  "cancel".tr(),
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
                              onConfirm();
                            },
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5), color: appColorOrange2),
                              child: Center(
                                child: Text(
                                  "confirm".tr(),
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
              ),
            ),
          )),
    );
  }
}
