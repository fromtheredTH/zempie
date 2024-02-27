import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Constants/FontConstants.dart';

// 앱 고유 텍스트
class AppText extends StatelessWidget {
  TextDecoration? textDecoration;
  String text;
  Color? color;
  double? fontSize;
  FontWeight? fontWeight;
  String? fontFamily;
  TextAlign? textAlign;
  TextOverflow? overflow = TextOverflow.fade;
  int? maxLine;
  int? maxLength;
  double? height;
  double? width;

  AppText(
      {Key? key,
        required this.text,
        this.color,
        this.fontFamily,
        this.height,
        this.textAlign,
        this.overflow,
        this.maxLine,
        this.fontSize,
        this.fontWeight,
        this.width,
        this.maxLength,
        this.textDecoration})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLine,
      style: TextStyle(
        height: height,
        decoration: textDecoration ?? TextDecoration.none,
        fontFamily: fontFamily ?? FontConstants.AppFont,
        fontSize: fontSize ?? Get.width * 0.03,
        fontWeight: fontWeight ?? FontWeight.w400,
        color: color ?? Colors.white,
      ),
    );
  }
}
