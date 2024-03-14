import 'package:carousel_slider/carousel_controller.dart';
import 'package:get/get.dart' hide Trans;

import '../Constants/ImageConstants.dart';

class OnBoardController extends GetxController {
  RxInt current = 0.obs;
  CarouselController buttonCarouselController = CarouselController();
  List<OnBoardModel> onboardData = [
    OnBoardModel(
        title: "Connect, Create and Conquer",
        subTitle: "Amplify Your Game Development Journey",
        description: "Dive into our global social network service with an integrated community platform.",
        image: ImageConstants.onBoardingImage1),
    OnBoardModel(
        title: "Level Up Your Network, Share Your Play",
        subTitle: "",
        description: "Elevate your game in our social network service designed for game developers worldwide. Connect, share and grow with ease, no matter where you are.",
        image: ImageConstants.onBoardingImage2),
    OnBoardModel(
        title: "Playtest Together",
        subTitle: "Unleash Your Creations on a Global Stage",
        description: "Playtest your creations seamlessly, share experiences, and witness your games reach a global audience. It’s more than sharing - it’s about creating a global gaming legacy together.",
        image: ImageConstants.onBoardingImage3),

  ];
}

class OnBoardModel {
  String? title;
  String? subTitle;
  String? description;
  String? image;
  OnBoardModel({this.title, this.subTitle, this.description, this.image});
}
