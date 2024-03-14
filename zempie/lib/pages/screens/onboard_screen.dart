
import 'package:app/pages/screens/Authentication/loginscreen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart' hide Trans;

import '../../Constants/ColorConstants.dart';
import '../../Constants/FontConstants.dart';
import '../../Constants/ImageConstants.dart';
import '../../controller/onboard_controller.dart';

class OnBoardScreen extends StatelessWidget {

  final onboardController = Get.put(OnBoardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.colorBg1,
      body:
      Column(
        children: [
          SizedBox(height: Get.height*0.10 ),
          SvgPicture.asset(ImageConstants.appLogo,fit: BoxFit.cover),
          SizedBox(height: Get.height*0.04),
          MediaQuery.removePadding(
            context: context,
            removeRight: true,
            removeLeft: true,
            removeTop: true,
            removeBottom: true,
            child: CarouselSlider(
              carouselController: onboardController.buttonCarouselController,
              options: CarouselOptions(
                height: Get.height * 0.8,
                autoPlay: false,
                enlargeCenterPage: true,
                viewportFraction: 1,
                reverse: false,
                enableInfiniteScroll: false,
                aspectRatio: 1,
                initialPage: 0,
                onPageChanged: (index, reason) {
                  onboardController.current.value = index;
                  if(index==2)
                    {
                      Future.delayed(Duration(seconds: 2), () {
                        Get.offAll(LoginScreen());
                      });
                    }
                },
              ),
              items: onboardController.onboardData.map((i) {
                return OnBoardItem(
                  image: i.image,
                  title: i.title,
                  subTitle: i.subTitle,
                  description: i.description,
                  current: onboardController.current,
                  dataLength: onboardController.onboardData.length,
                  buttonCarouselController: onboardController.buttonCarouselController,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class OnBoardItem extends StatelessWidget {
  final String? image;
  final String? title;
  final String? subTitle;
  final String? description;
  final RxInt current;
  final int dataLength;
  final CarouselController buttonCarouselController;

  OnBoardItem({
    required this.image,
    required this.title,
    required this.subTitle,
    required this.description,
    required this.current,
    required this.dataLength,
    required this.buttonCarouselController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.colorBg1,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: Get.height * 0.4,
            width: double.infinity,
            color: ColorConstants.colorBg1,
            child: Image.asset(image!),
          ),
          Container(
            height: Get.height * 0.3,
            decoration: BoxDecoration(
              color: ColorConstants.colorBg1,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10.0,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                SizedBox(height: Get.height * 0.03),
                Text(title!, textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: FontConstants.AppFont,
                        fontWeight: FontWeight.w700,
                        color: ColorConstants.white,
                        fontSize: Get.height*0.019
                    )),
                SizedBox(height: Get.height * 0.005),
                Text(subTitle!, textAlign: TextAlign.center,
                    style: TextStyle(
                        color: ColorConstants.white,
                        fontFamily: FontConstants.AppFont,
                        fontSize: Get.height*0.016,
                        fontWeight: FontWeight.w400
                    )),
                SizedBox(height: Get.height * 0.02),
            Padding(
              padding: EdgeInsets.only(left: 13, right: 13),
              child: Text(description!, textAlign: TextAlign.center,
                  maxLines: 3,
                  style: TextStyle(
                    fontFamily: FontConstants.AppFont,
                    color: ColorConstants.gray3,
                    overflow: TextOverflow.ellipsis,
                    fontSize: Get.height*0.016,

                  )
              ),
            ),
                SizedBox(height: Get.height * 0.075),
                Expanded(
                    child: Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(dataLength, (index) {
                        return GestureDetector(
                          onTap: () => buttonCarouselController.animateToPage(index),
                          child: Container(
                            width: Get.width * 0.020,
                            height: Get.height * 0.020,
                            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (Theme.of(context).brightness == Brightness.dark
                                  ? ColorConstants.gray3
                                  : ColorConstants.colorMain)
                                  .withOpacity(current.value == index ? 0.9 : 0.4),
                            ),
                          ),
                        );
                      }),
                    )),
                )

              ],
            ),
          ),
        ],
      ),
    );
  }
}
