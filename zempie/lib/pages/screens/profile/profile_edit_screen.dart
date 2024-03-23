import 'dart:io';

import 'package:app/models/CountryModel.dart';
import 'package:app/models/User.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../../Constants/ColorConstants.dart';
import '../../../Constants/Constants.dart';
import '../../../Constants/FontConstants.dart';
import '../../../Constants/ImageConstants.dart';
import '../../../Constants/ImageUtils.dart';
import '../../../Constants/utils.dart';
import '../../../global/DioClient.dart';
import '../../../models/MatchEnumModel.dart';
import '../../../models/res/btn_bottom_sheet_model.dart';
import '../../base/base_state.dart';
import '../../components/BottomCountryWidget.dart';
import '../../components/BottomInterestGameGenreWidget.dart';
import '../../components/BottomInterestGenreWidget.dart';
import '../../components/BottomProfileJobPositionWidget.dart';
import '../../components/BottomProfileJobWidget.dart';
import '../../components/BtnBottomSheetWidget.dart';
import '../../components/GalleryBottomSheet.dart';
import '../../components/MyAssetPicker.dart';
import '../../components/app_text.dart';

class ProfileEditScreen extends StatefulWidget {
  ProfileEditScreen({super.key, required this.onRefreshUser});
  Function(UserModel) onRefreshUser;

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreen();
}

class _ProfileEditScreen extends BaseState<ProfileEditScreen> {
  UserModel user = Constants.user;

  TextEditingController jobDeptController = TextEditingController();

  MatchEnumModel? jobGroup;
  MatchEnumModel? jobPosition;
  String jobPositionStr = "";
  TextEditingController jobController = TextEditingController();

  late CountryModel country;
  late String city;
  TextEditingController countryController = TextEditingController();

  List<MatchEnumModel> interestGenreItems = [];
  TextEditingController interestGenreController = TextEditingController();

  List<MatchEnumModel> interestGameGenreItems = [];
  TextEditingController interestGameGenreController = TextEditingController();

  TextEditingController myLinkController = TextEditingController();
  TextEditingController myLinkNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  bool isBanner = false;

  Future<bool> _promptPermissionSetting() async {
    if (Platform.isIOS) {
      if (await Permission.photos.request().isGranted || await Permission.storage.request().isGranted) {
        return true;
      }
    }
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isGranted ||
          await Permission.photos.request().isGranted &&
              await Permission.videos.request().isGranted) {
        return true;
      }
    }
    return false;
  }

  Future<void> procAssets(List<AssetEntity>? assets) async {
    if (assets != null) {
      await Future.forEach<AssetEntity>(assets, (file) async {
        File? f = await file.originFile;
        if (file.type == AssetType.image && f != null) {
          var response = await DioClient.updateUserProfile(isBanner ? null : f, isBanner ? f : null,null,null);
          Constants.cachingKey = DateTime.now().millisecondsSinceEpoch.toString();
          getUserInfo();
        }
      });
    }
  }

  Future<void> procAssetsWithGallery(List<Medium> assets) async {

    await Future.forEach<Medium>(assets, (file) async {
      File? f = await file.getFile();
      if (file.mediumType == MediumType.image && f != null) {
        var response = await DioClient.updateUserProfile(isBanner ? null : f, isBanner ? f : null, null, null);
        Constants.cachingKey = DateTime.now().millisecondsSinceEpoch.toString();
        getUserInfo();
      }
    });
  }

  Future<void> getUserInfo() async {
    var response = await DioClient.getUser(user.nickname);
    setState(() {
      user = UserModel.fromJson(response.data["result"]["target"]);
      Constants.user = user;
    });
  }

  @override
  void initState() {
    super.initState();
    jobDeptController.text = user.profile.jobDept;
    jobGroup = Constants.getProfileJobGroup(user.profile.jobGroup);
    jobPosition = Constants.getProfileJobPosition(user.profile.jobPosition);
    jobController.text = "${jobGroup?.koName ?? ""} ${jobPosition?.koName ?? ""}";
    country = Constants.getCountryModel(user.profile.country);
    city = user.profile.city;
    countryController.text = "${country.nameModel.ko} ${city}";

    interestGenreItems = Constants.getUserStateList(user.profile.stateMsg);
    interestGenreController.text = Constants.getNameList(interestGenreItems);

    interestGameGenreItems = Constants.getUserGameGenryList(user.profile.interestGameGenre);
    interestGameGenreController.text = Constants.getNameList(interestGameGenreItems);

    descriptionController.text = user.profile.description;
    myLinkNameController.text = user.profile.linkName;
    myLinkController.text = user.profile.link;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFF1A1C29),
        body: Column(
          children: [

            SizedBox(height: Get.height * 0.07),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                          onTap: () {
                            Get.back();
                          },
                          child: Icon(
                              Icons.arrow_back_ios, color: Colors.white)),

                      AppText(
                        text: "내 프로필",
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      )
                    ],
                  ),

                ],
              ),
            ),
            SizedBox(height: 10),

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: Get.width / 4,
                        width: Get.width,
                        child: Stack(
                          children: [
                            user.urlBanner.isNotEmpty ?
                            Image.network(
                              user.urlBanner,
                              height: Get.width / 4,
                              width: Get.width,
                              fit: BoxFit.fill,
                            ) : Container(
                              height: Get.width / 4,
                              width: Get.width,
                              color: ColorConstants.textGry,
                            ),

                            Align(
                              alignment: Alignment.center,
                              child: GestureDetector(
                                onTap: (){
                                  List<BtnBottomSheetModel> items = [];
                                  items.add(BtnBottomSheetModel(
                                      ImageConstants.cameraIcon,
                                      "camera".tr(), 0));
                                  items.add(BtnBottomSheetModel(
                                      ImageConstants.albumIcon,
                                      "gallery".tr(), 1));
                                  items.add(BtnBottomSheetModel(
                                      ImageConstants.deleteIcon, "현재 사진 삭제",
                                      2));

                                  Get.bottomSheet(BtnBottomSheetWidget(
                                    btnItems: items,
                                    onTapItem: (sheetIdx) async {
                                      isBanner = true;
                                      if (sheetIdx == 0) {
                                        AssetEntity? assets = await MyAssetPicker
                                            .pickCamera(context);
                                        if (assets != null) {
                                          procAssets([assets]);
                                        }
                                      } else if (sheetIdx == 1) {
                                        if (await _promptPermissionSetting()) {
                                          showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              isDismissible: true,
                                              backgroundColor: Colors
                                                  .transparent,
                                              constraints: BoxConstraints(
                                                minHeight: 0.8,
                                                maxHeight: Get.height * 0.95,
                                              ),
                                              builder: (
                                                  BuildContext context) {
                                                return DraggableScrollableSheet(
                                                    initialChildSize: 0.5,
                                                    minChildSize: 0.4,
                                                    maxChildSize: 0.9,
                                                    expand: false,
                                                    builder: (_,
                                                        controller) =>
                                                        GalleryBottomSheet(
                                                          controller: controller,
                                                          limitCnt: 1,
                                                          sendText: "변경하기",
                                                          onTapSend: (
                                                              results) {
                                                            procAssetsWithGallery(
                                                                results);
                                                          },
                                                        )
                                                );
                                              }
                                          );
                                        }
                                      } else {
                                        var response = await DioClient
                                            .updateUserProfile(
                                            null, null, isBanner ? null : true, isBanner ? true : null);
                                        getUserInfo();
                                      }
                                    },
                                  ));
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 12),
                                  decoration: BoxDecoration(
                                      color: ColorConstants.halfBlack,
                                      borderRadius: BorderRadius.circular(4)
                                  ),
                                  child: AppText(
                                    text: "변경하기",
                                    fontSize: 12,
                                  ),
                                ),
                              )
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 100,
                          height: 100,
                          child: Stack(
                            children: [
                              Center(
                                child: ImageUtils.ProfileImage(
                                    user.picture, 60, 60),
                              ),

                              Align(
                                alignment: Alignment.bottomCenter,
                                child: GestureDetector(
                                  onTap: () {
                                    List<BtnBottomSheetModel> items = [];
                                    items.add(BtnBottomSheetModel(
                                        ImageConstants.cameraIcon,
                                        "camera".tr(), 0));
                                    items.add(BtnBottomSheetModel(
                                        ImageConstants.albumIcon,
                                        "gallery".tr(), 1));
                                    items.add(BtnBottomSheetModel(
                                        ImageConstants.deleteIcon, "현재 사진 삭제",
                                        2));

                                    Get.bottomSheet(BtnBottomSheetWidget(
                                      btnItems: items,
                                      onTapItem: (sheetIdx) async {
                                        isBanner = false;
                                        if (sheetIdx == 0) {
                                          AssetEntity? assets = await MyAssetPicker
                                              .pickCamera(context);
                                          if (assets != null) {
                                            procAssets([assets]);
                                          }
                                        } else if (sheetIdx == 1) {
                                          if (await _promptPermissionSetting()) {
                                            showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                isDismissible: true,
                                                backgroundColor: Colors
                                                    .transparent,
                                                constraints: BoxConstraints(
                                                  minHeight: 0.8,
                                                  maxHeight: Get.height * 0.95,
                                                ),
                                                builder: (
                                                    BuildContext context) {
                                                  return DraggableScrollableSheet(
                                                      initialChildSize: 0.5,
                                                      minChildSize: 0.4,
                                                      maxChildSize: 0.9,
                                                      expand: false,
                                                      builder: (_,
                                                          controller) =>
                                                          GalleryBottomSheet(
                                                            controller: controller,
                                                            limitCnt: 1,
                                                            sendText: "변경하기",
                                                            onTapSend: (
                                                                results) {
                                                              procAssetsWithGallery(
                                                                  results);
                                                            },
                                                          )
                                                  );
                                                }
                                            );
                                          }
                                        } else {
                                          var response = await DioClient
                                              .updateUserProfile(
                                              null, null, isBanner ? null : true, isBanner ? true : null);
                                          getUserInfo();
                                        }
                                      },
                                    ));
                                  },
                                  child: ImageUtils.setImage(
                                      ImageConstants.editProfile, 20, 20),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      AppText(
                        text: "소속",
                        fontSize: 12,
                        color: ColorConstants.halfWhite,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      TextField(
                        onTap: () {

                        },
                        controller: jobDeptController,
                        style: TextStyle(
                          color: ColorConstants.white,
                          fontSize: 13,
                          fontFamily: FontConstants.AppFont,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide:
                              BorderSide(color: Color(0xFFFFFFFF).withOpacity(
                                  0.5)),
                            ),
                            hintText: "jobdept_input".tr(),
                            hintStyle: TextStyle(
                              color: ColorConstants.halfWhite,
                              fontWeight: FontWeight.w400,
                              fontFamily: FontConstants.AppFont,
                              fontSize: 13,
                            ),
                            contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10)),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          AppText(
                            text: "직군",
                            fontSize: 12,
                            color: ColorConstants.halfWhite,
                          ),
                          Text("*",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontFamily: FontConstants.AppFont,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      TextField(
                        onTap: () {
                          Get.bottomSheet(
                              backgroundColor: ColorConstants.backGry,
                              isScrollControlled: true,
                              BottomProfileJobWidget(
                                selectedJobGroup: jobGroup!, onSelectJobGroup: (
                                  group) {
                                Get.bottomSheet(
                                    backgroundColor: ColorConstants.backGry,
                                    isScrollControlled: true,
                                    BottomProfileJobPositionWidget(
                                      selectedJobGroup: group,
                                      selectedJobPosition: jobPosition,
                                      onSelectJobPosition: (group, position) {
                                        jobGroup = group;
                                        jobPosition = position;
                                        jobController.text =
                                        "${jobGroup?.koName ??
                                            ""} ${jobPosition!.koName}";
                                      },)
                                );
                              },)
                          );
                        },
                        controller: jobController,
                        readOnly: true,
                        style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 13,
                          fontFamily: FontConstants.AppFont,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                            suffixIcon: Icon(Icons.keyboard_arrow_down_rounded,
                              color: Colors.white,),

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide:
                              BorderSide(color: Color(0xFFFFFFFF).withOpacity(
                                  0.5)),
                            ),
                            hintText: "jobgroup_input".tr(),
                            hintStyle: TextStyle(
                              color: ColorConstants.halfWhite,
                              fontWeight: FontWeight.w400,
                              fontFamily: FontConstants.AppFont,
                              fontSize: 13,
                            ),
                            contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10)),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          AppText(
                            text: "country_city_title".tr(),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                          Text(
                            "*",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontFamily: FontConstants.AppFont,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      TextField(
                        onTap: () {
                          Get.bottomSheet(
                              backgroundColor: ColorConstants.backGry,

                              isScrollControlled: true,
                              BottomCountryWidget(
                                selectedCountry: country,
                                city: city,
                                onSelectCountry: (country, city) {
                                  setState(() {
                                    this.country = country;
                                    this.city = city;
                                    countryController.text =
                                    "${country.nameModel.ko} ${city}";
                                  });
                                },
                              )
                          );
                        },
                        readOnly: true,
                        controller: countryController,
                        style: TextStyle(

                          color: Color(0xFFFFFFFF),
                          fontSize: 13,
                          fontFamily: FontConstants.AppFont,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          suffixIcon: Icon(Icons.keyboard_arrow_down_rounded,
                            color: Colors.white,),
                          contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide:
                            BorderSide(color: Color(0xFFFFFFFF).withOpacity(
                                0.5)),
                          ),
                          hintText: "country_input".tr(),
                          hintStyle: TextStyle(
                            color: Color(0xFFFFFFFF).withOpacity(0.5),
                            fontWeight: FontWeight.w400,
                            fontFamily: FontConstants.AppFont,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          AppText(
                            text: "관심 분야",
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                          Text(
                            "*",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontFamily: FontConstants.AppFont,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      TextField(
                        controller: interestGenreController,
                        onTap: () {
                          Get.bottomSheet(
                              backgroundColor: ColorConstants.backGry,
                              isScrollControlled: true,
                              BottomInterestGenreWidget(
                                selectedGenre: interestGenreItems,
                                onSelectGenre: (items) {
                                  setState(() {
                                    interestGenreItems = items;
                                    interestGenreController.text =
                                        Constants.getNameList(
                                            interestGenreItems);
                                  });
                                },)
                          );
                        },
                        style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 13,
                          fontFamily: FontConstants.AppFont,
                          fontWeight: FontWeight.w400,
                        ),
                        readOnly: true,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide:
                              BorderSide(color: Color(0xFFFFFFFF).withOpacity(
                                  0.5)),
                            ),
                            hintText: "interest_genre_input".tr(),
                            hintStyle: TextStyle(
                              color: Color(0xFFFFFFFF).withOpacity(0.5),
                              fontWeight: FontWeight.w400,
                              fontFamily: FontConstants.AppFont,
                              fontSize: 13,
                            ),
                            contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10)),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      AppText(
                        text: "관심 게임 장르",
                        fontSize: 12,
                        color: ColorConstants.halfWhite,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      TextField(
                        onTap: () {
                          Get.bottomSheet(
                              backgroundColor: ColorConstants.backGry,
                              isScrollControlled: true,
                              BottomInterestGameGenreWidget(
                                selectedGameGenre: interestGameGenreItems,
                                onSelectGameGenre: (items) {
                                  setState(() {
                                    interestGameGenreItems = items;
                                    interestGameGenreController.text =
                                        Constants.getNameList(
                                            interestGameGenreItems);
                                  });
                                },)
                          );
                        },
                        style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 13,
                          fontFamily: FontConstants.AppFont,
                          fontWeight: FontWeight.w400,
                        ),
                        readOnly: true,
                        controller: interestGameGenreController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide:
                              BorderSide(color: Color(0xFFFFFFFF).withOpacity(
                                  0.5)),
                            ),
                            hintText: "interest_game_genre_input".tr(),
                            hintStyle: TextStyle(
                              color: Color(0xFFFFFFFF).withOpacity(0.5),
                              fontWeight: FontWeight.w400,
                              fontFamily: FontConstants.AppFont,
                              fontSize: 13,
                            ),
                            contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10)),
                      ),
                      if(interestGameGenreItems.length > 0)
                        Container(
                          height: 25,
                          margin: EdgeInsets.only(bottom: 20, top: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      ListView.builder(
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  interestGameGenreItems
                                                      .removeAt(index);
                                                });
                                              },
                                              child: Container(
                                                margin: EdgeInsets.only(
                                                    right: 10),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8),
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius
                                                        .circular(
                                                        30),
                                                    border: Border.all(
                                                        color: ColorConstants
                                                            .colorMain,
                                                        width: 0.5)),
                                                child: Row(
                                                  children: [
                                                    AppText(
                                                      text: interestGameGenreItems[index]
                                                          .koName,
                                                      fontSize: 14,
                                                      color: ColorConstants
                                                          .colorMain,
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          left: 4),
                                                      decoration: BoxDecoration(
                                                          borderRadius: BorderRadius
                                                              .circular(6),
                                                          color: ColorConstants
                                                              .colorMain
                                                      ),
                                                      child: Icon(
                                                        Icons.close_rounded,
                                                        size: 12,
                                                        color: ColorConstants
                                                            .colorBg1,),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                          itemCount: interestGameGenreItems
                                              .length),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      SizedBox(
                        height: 10,
                      ),
                      AppText(
                        text: "내 링크",
                        fontSize: 12,
                        color: ColorConstants.halfWhite,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      TextField(
                        controller: myLinkNameController,
                        style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 13,
                          fontFamily: FontConstants.AppFont,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide:
                              BorderSide(color: Color(0xFFFFFFFF).withOpacity(
                                  0.5)),
                            ),
                            hintText: "링크를 표시할 이름을 입력해 주세요",
                            hintStyle: TextStyle(
                              color: Color(0xFFFFFFFF).withOpacity(0.5),
                              fontWeight: FontWeight.w400,
                              fontFamily: FontConstants.AppFont,
                              fontSize: 13,
                            ),
                            contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10)),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      TextField(
                        controller: myLinkController,
                        style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 13,
                          fontFamily: FontConstants.AppFont,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide:
                              BorderSide(color: Color(0xFFFFFFFF).withOpacity(
                                  0.5)),
                            ),
                            hintText: "링크를 입력해 주세요",
                            hintStyle: TextStyle(
                              color: Color(0xFFFFFFFF).withOpacity(0.5),
                              fontWeight: FontWeight.w400,
                              fontFamily: FontConstants.AppFont,
                              fontSize: 13,
                            ),
                            contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10)),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      AppText(
                        text: "사용 언어",
                        fontSize: 12,
                        color: ColorConstants.halfWhite,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      TextField(
                        style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 13,
                          fontFamily: FontConstants.AppFont,
                          fontWeight: FontWeight.w400,
                        ),
                        readOnly: true,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide:
                              BorderSide(color: Color(0xFFFFFFFF).withOpacity(
                                  0.5)),
                            ),
                            hintText: "사용 언어를 선택해 주세요",
                            hintStyle: TextStyle(
                              color: Color(0xFFFFFFFF).withOpacity(0.5),
                              fontWeight: FontWeight.w400,
                              fontFamily: FontConstants.AppFont,
                              fontSize: 13,
                            ),
                            contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10)),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      AppText(
                        text: "자기 소개",
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Color(0xFFFFFFFF)
                              .withOpacity(0.5)),
                        ),
                        child: TextField(
                          controller: descriptionController,
                          style: TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 13,
                            fontFamily: FontConstants.AppFont,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 4,
                          maxLength: 150,
                          decoration: InputDecoration(
                            contentPadding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                            border: InputBorder.none,
                            // border: OutlineInputBorder(
                            //   borderRadius: BorderRadius.circular(5),
                            //   borderSide:
                            //       BorderSide(color: Color(0xFFFFFFFF).withOpacity(0.5)),
                            // ),
                            hintText: "간략한 자기 소개 글을 작성해 주세요...",
                            hintStyle: TextStyle(
                              color: Color(0xFFFFFFFF).withOpacity(0.5),
                              fontWeight: FontWeight.w400,
                              fontFamily: FontConstants.AppFont,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          if(jobDeptController.text.isEmpty){
                            Utils.showToast("jobdept_description_setting");
                            return;
                          }
                          if(this.jobGroup == null){
                            Utils.showToast("jobgroup_description_setting");
                            return;
                          }
                          if(this.jobPosition == null && this.jobPositionStr.isEmpty){
                            Utils.showToast("jobposition_description".tr());
                            return;
                          }
                          if(interestGenreItems.length == 0){
                            Utils.showToast("interset_genre_select".tr());
                            return;
                          }
                          if(interestGameGenreItems.length == 0){
                            Utils.showToast("interset_game_genre_select".tr());
                            return;
                          }
                          String jobDept = this.jobDeptController.text;
                          int jobGroup = this.jobGroup!.idx;
                          int jobPosition = this.jobPosition!.idx;

                          String genre = "";
                          genre += interestGenreItems[0].idx.toString();
                          for(int i=1;i<interestGenreItems.length;i++){
                            genre += ",${interestGenreItems[i].idx}";
                          }

                          String gameGenre = "";
                          gameGenre += interestGameGenreItems[0].idx.toString();
                          for(int i=1;i<interestGameGenreItems.length;i++){
                            gameGenre += ",${interestGameGenreItems[i].idx}";
                          }

                          var response = await DioClient.updateAllProfile(
                              jobDeptController.text,
                              jobGroup.toString(),
                              jobPosition == 100 ? this.jobPosition!.koName : jobPosition.toString(),
                              country.code,
                              city,
                              gameGenre,
                              genre,
                            myLinkNameController.text,
                            myLinkController.text,
                            descriptionController.text
                          );
                          UserModel user = UserModel.fromJson(response.data["result"]["user"]);
                          Constants.user = user;
                          widget.onRefreshUser(user);
                          Utils.showToast("toast_edit_profile_complete".tr());
                          Get.back();
                        },
                        child: Container(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            padding: EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              color: Color(0xFFE99315),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Center(
                              child: Text(
                                "save".tr(),
                                style: TextStyle(
                                    color: Color(0xFFFFFFFFF),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    fontFamily: FontConstants.AppFont),
                              ),
                            )),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        )
    );
  }
}