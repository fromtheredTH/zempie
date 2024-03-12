


import 'dart:convert';
import 'dart:io';

import 'package:app/Constants/Constants.dart';
import 'package:app/Constants/ImageUtils.dart';
import 'package:app/global/DioClient.dart';
import 'package:app/models/GameModel.dart';
import 'package:app/models/ReplyModel.dart';
import 'package:app/models/User.dart';
import 'package:app/pages/components/BottomProfileWidget.dart';
import 'package:app/pages/components/GameSimpleItemWidget.dart';
import 'package:app/pages/components/GameUserPageWidget.dart';
import 'package:app/pages/components/ReplyWidget.dart';
import 'package:app/pages/components/item/TagCreator.dart';
import 'package:app/pages/screens/discover/GameDetailReplyScreen.dart';
import 'package:app/pages/screens/discover/GameFollowerScreen.dart';
import 'package:app/pages/screens/profile/ProfileFollowMemberScreen.dart';
import 'package:app/pages/screens/profile/profile_edit_screen.dart';
import 'package:app/pages/screens/profile/profile_following_game_screen.dart';
import 'package:app/pages/screens/profile/setting_list_screen.dart';
import 'package:app/pages/screens/splash.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_core/src/get_main.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:rich_text_view/rich_text_view.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../../../Constants/ColorConstants.dart';
import '../../../Constants/FontConstants.dart';
import '../../../Constants/ImageConstants.dart';
import '../../../Constants/utils.dart';
import '../../../models/PostFileModel.dart';
import '../../../models/PostModel.dart';
import '../../../models/res/btn_bottom_sheet_model.dart';
import '../../components/BtnBottomSheetWidget.dart';
import '../../components/GalleryBottomSheet.dart';
import '../../components/GameWidget.dart';
import '../../components/MyAssetPicker.dart';
import '../../components/UserListItemWidget.dart';
import '../../components/app_text.dart';
import '../../base/base_state.dart';
import '../../components/fucus_detector.dart';
import '../../components/loading_widget.dart';
import '../../components/post_widget.dart';
import '../newPostScreen.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({super.key, required this.user});
  UserModel user;

  @override
  State<ProfileScreen> createState() => _ProfileScreen();
}

class _ProfileScreen extends BaseState<ProfileScreen> {
  RxInt? currentIndex = 0.obs;
  late UserModel user;

  int? _selectedIndex = 0;

  late Future postFuture;
  late Future gameFuture;
  List<PostModel> posts = [];
  List<GameModel> followGames = [];
  int postPage = 0;
  int totalPost = 0;
  bool hasNextPosts = false;

  ScrollController scrollController = ScrollController();

  Future<void> initFollowingGames() async {
    var gameResponse = DioClient.getUserGameList(user.id);
    gameResponse.then(
            (response) {
          setState(() {
            followGames = response.data["result"] == null ? [] : response
                .data["result"].map((json) => GameModel.fromJson(json)).toList().cast<
                GameModel>();
          });
        }
    );
  }

  Future<List<PostModel>> initUserTimelines() async {
    var response = await DioClient.getUserPostings(user.channelId, 10, 0);
    List<PostModel> results = response.data["result"] == null ? [] : response.data["result"].map((json) => PostModel.fromJson(json)).toList().cast<PostModel>();
    postPage = 1;
    totalPost = response.data["totalCount"];
    hasNextPosts = response.data?["pageInfo"]?["hasNextPage"] ?? false;
    setState(() {
      posts = results;
    });
    return posts;
  }

  Future<void> getScrollNextPage() async {
    if (scrollController.position.extentAfter < 200 && !isLoading) {
      if(_selectedIndex == 0 && hasNextPosts){
        isLoading = true;
        var response = await DioClient.getUserPostings(user.channelId, 10, postPage);
        List<PostModel> results = response.data["result"] == null ? [] : response.data["result"].map((json) => PostModel.fromJson(json)).toList().cast<PostModel>();
        postPage += 1;
        hasNextPosts = response.data["pageInfo"]?["hasNextPage"] ?? false;
        setState(() {
          posts.addAll(results);
        });
      }
      isLoading = false;
    }
  }

  Future<void> getUserInfo() async {
    var response = await DioClient.getUser(user.nickname);
    await CachedNetworkImage.evictFromCache(user.picture);
    ImageCache().clearLiveImages();
    ImageCache().clear();
    print(user.nickname);
    setState(() {
      user = UserModel.fromJson(response.data["result"]["target"]);
      print(user.nickname);
      print(response);
      if(user.id == Constants.user.id) {
        Constants.user = user;
      }
    });
  }


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
          var response = await DioClient.updateUserProfile(f, null,null,null);
          await CachedNetworkImage.evictFromCache(user.picture);
          getUserInfo();
        }
      });
    }
  }

  Future<void> procAssetsWithGallery(List<Medium> assets) async {

    await Future.forEach<Medium>(assets, (file) async {
      File? f = await file.getFile();
      if (file.mediumType == MediumType.image && f != null) {
        var response = await DioClient.updateUserProfile(f, null, null, null);
        await CachedNetworkImage.evictFromCache(user.picture);
        getUserInfo();
      }
    });
  }



  @override
  void initState() {
    user = widget.user;
    postFuture = initUserTimelines();
    initFollowingGames();
    getUserInfo();
    super.initState();
    scrollController.addListener(getScrollNextPage);
  }

  @override
  Widget build(BuildContext context) {

    return FocusDetector(
        onFocusLost: () {

    },
    onFocusGained: () {
          if(user.id == Constants.user.id) {
            setState(() {
              user = Constants.user;
            });
          }
    },
    child: Scaffold(
        backgroundColor: ColorConstants.colorBg1,
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            SizedBox(height: Get.height*0.07),
            Padding(
              padding:EdgeInsets.only(left: 15, right: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                          onTap: (){
                            Get.back();
                          },
                          child: Icon(Icons.arrow_back_ios, color:Colors.white)),

                      AppText(
                        text: user.id == Constants.user.id ? "마이 페이지" : user.nickname,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      )
                    ],
                  ),
                  user.id == Constants.user.id ?
                  Row(
                    children: [
                      GestureDetector(
                        onTap: (){
                          Get.bottomSheet(BottomProfileWidget(user: user, setting: (){
                            Get.to(SettingListScreen(onChangedUser: (user){
                              setState(() {
                                this.user = user;
                              });
                            },));
                          }, logout: () async {
                            final SharedPreferences prefs = await SharedPreferences.getInstance();
                            prefs.clear();
                            prefs.setBool("isShowOnBoard", true);
                            await FirebaseAuth.instance.signOut();
                            Get.offAll(SplashPage());
                          }));
                        },
                        child:
                        SvgPicture.asset(ImageConstants.moreIcon),
                      )

                    ],
                  ) : Container()
                ],
              ),
            ),
            SizedBox(height: Get.height*0.02),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                    children: [
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Column(
                          children: [
                            user.urlBanner.isNotEmpty ?
                            Image.network(
                              user.urlBanner,
                              height: Get.width/4,
                              width: Get.width,
                              fit: BoxFit.fill,
                            ) : Container(
                              height: Get.width/4,
                              width: Get.width,
                              color: ColorConstants.textGry,
                            ),

                            Padding(
                              padding: EdgeInsets.only(left: 10, right: 10,top: 8,bottom: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    width: 70,
                                    height: 70,
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: ImageUtils.ProfileImage(user.picture, 60, 60),
                                        ),

                                        if(user.id == Constants.user.id)
                                        Align(
                                          alignment:Alignment.bottomCenter,
                                          child: GestureDetector(
                                            onTap: (){
                                              List<BtnBottomSheetModel> items = [];
                                              items.add(BtnBottomSheetModel(ImageConstants.cameraIcon, "camera".tr(), 0));
                                              items.add(BtnBottomSheetModel(ImageConstants.albumIcon, "gallery".tr(), 1));
                                              items.add(BtnBottomSheetModel(ImageConstants.deleteIcon, "현재 사진 삭제", 2));

                                              Get.bottomSheet(BtnBottomSheetWidget(
                                                btnItems: items,
                                                onTapItem: (sheetIdx) async {
                                                  if(sheetIdx == 0){
                                                    AssetEntity? assets = await MyAssetPicker.pickCamera(context);
                                                    if (assets != null) {
                                                      procAssets([assets]);
                                                    }
                                                  }else if(sheetIdx == 1){
                                                    if (await _promptPermissionSetting()) {
                                                      showModalBottomSheet(
                                                          context: context,
                                                          isScrollControlled: true,
                                                          isDismissible: true,
                                                          backgroundColor: Colors.transparent,
                                                          constraints: BoxConstraints(
                                                            minHeight: 0.8,
                                                            maxHeight: Get.height*0.95,
                                                          ),
                                                          builder: (BuildContext context) {
                                                            return DraggableScrollableSheet(
                                                                initialChildSize: 0.5,
                                                                minChildSize: 0.4,
                                                                maxChildSize: 0.9,
                                                                expand: false,
                                                                builder: (_, controller) => GalleryBottomSheet(
                                                                  controller: controller,
                                                                  limitCnt: 1,
                                                                  onTapSend: (results){
                                                                    procAssetsWithGallery(results);
                                                                  },
                                                                )
                                                            );
                                                          }
                                                      );
                                                    }
                                                  }else{
                                                    var response = await DioClient.updateUserProfile(null, null, true, null);
                                                    await CachedNetworkImage.evictFromCache(user.picture);
                                                    getUserInfo();
                                                  }
                                                },
                                              ));
                                            },
                                            child: ImageUtils.setImage(ImageConstants.editProfile, 20, 20),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          AppText(
                                            text: user.nickname,
                                            fontSize: 14,
                                            maxLine: 1,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              AppText(text: "@${user.name}",
                                                  fontSize: 12,
                                                  color: ColorConstants.halfWhite),

                                              SizedBox(width: 5,),

                                              if(user.profile.jobGroup == "1")
                                                TagCreatorWidget()
                                            ],
                                          ),

                                          SizedBox(height: 5,),

                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              GestureDetector(
                                                onTap: (){
                                                  Get.to(ProfileFollowMemberScreen(user: user, isFollowing: true, changeFollowCnt: (user){
                                                    setState(() {
                                                      this.user = user;
                                                      Constants.user = user;
                                                    });
                                                  },));
                                                },
                                                child: Row(
                                                  children: [
                                                    AppText(
                                                      text: "${user.followingCnt}",
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                    AppText(
                                                      text: " 팔로잉",
                                                      fontSize: 10,
                                                      color: ColorConstants.white70Percent,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                margin: EdgeInsets.only(left: 10,right: 10),
                                                height: 10,
                                                width: 0.5,
                                                color: ColorConstants.white70Percent,
                                              ),
                                              GestureDetector(
                                                onTap: (){
                                                  Get.to(ProfileFollowMemberScreen(user: user, isFollowing: false, changeFollowCnt: (user) {
                                                    setState(() {
                                                      this.user = user;
                                                      Constants.user = user;
                                                    });
                                                  },));
                                                },
                                                child: Row(
                                                  children: [
                                                    AppText(
                                                      text: "${user.followerCnt}",
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                    AppText(
                                                      text: " 팔로워",
                                                      fontSize: 10,
                                                      color: ColorConstants.white70Percent,
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                  ),

                                  user.id == Constants.user.id ?
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          if(Constants.userQrCode != null) {
                                            double currentBright = await ScreenBrightness().current;
                                            await ScreenBrightness().setScreenBrightness(1.0);
                                            showDialog(
                                              context: context,
                                              barrierDismissible: true,
                                              //바깥 영역 터치시 닫을지 여부 결정
                                              builder: ((context) {
                                                return Dialog(
                                                  backgroundColor: ColorConstants
                                                      .colorBg1,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius
                                                          .circular(16)
                                                  ),
                                                  child: Container(
                                                    width: Get.width * 0.6,
                                                    height: Get.width * 0.8,
                                                    padding: EdgeInsets.only(
                                                        left: 15, right: 15),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment
                                                          .center,
                                                      children: [
                                                        SizedBox(height: 15,),

                                                        AppText(
                                                          text: "내 QR 코드",
                                                          fontSize: 18,
                                                          fontWeight: FontWeight
                                                              .w700,
                                                        ),

                                                        SizedBox(height: 10,),

                                                        Container(
                                                          width: double
                                                              .maxFinite,
                                                          height: 0.5,
                                                          color: ColorConstants
                                                              .halfWhite,
                                                        ),

                                                        SizedBox(height: 15,),

                                                        SvgPicture.asset(ImageConstants.appLogo, height: 20,),

                                                        SizedBox(height: 15,),

                                                        Image.memory(
                                                          Constants.userQrCode!,
                                                          width: Get.width *
                                                              0.4,
                                                          height: Get.width *
                                                              0.4,),

                                                        SizedBox(height: 15,),

                                                        Row(
                                                          crossAxisAlignment: CrossAxisAlignment
                                                              .center,
                                                          mainAxisAlignment: MainAxisAlignment
                                                              .center,
                                                          children: [
                                                            ImageUtils.setImage(
                                                                ImageConstants
                                                                    .copyIcon,
                                                                18, 18),
                                                            AppText(
                                                              text: "내 채널 링크 복사",
                                                              fontSize: 14,
                                                            )
                                                          ],
                                                        ),

                                                        SizedBox(height: 20,)

                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }),
                                            ).then((value) async {
                                              await ScreenBrightness().setScreenBrightness(currentBright);
                                            });
                                          }
                                        },
                                        child: ImageUtils.setImage(ImageConstants.qr, 25, 25),
                                      ),

                                      SizedBox(width: 15,),

                                      GestureDetector(
                                        onTap: (){
                                          Get.to(ProfileEditScreen());
                                        },
                                        child: ImageUtils.setImage(ImageConstants.editRoomIcon, 25, 25),
                                      )
                                    ],
                                  ) : Container()
                                ],
                              ),
                            ),

                            SizedBox(height: 5,),

                            if(user.profile.country.isNotEmpty && user.profile.city.isNotEmpty)
                              Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      ImageUtils.setImage(ImageConstants.profileLocation, 22, 22),
                                      SizedBox(width: 5,),
                                      AppText(
                                        text: "${Constants.getCountryName(user.profile.country)} ${user.profile.city}",
                                        fontSize: 11,
                                      )
                                    ],
                                  ),

                                  SizedBox(height: 5,),
                                ],
                              ),

                            if(user.profile.jobDept.isNotEmpty)
                              Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      ImageUtils.setImage(ImageConstants.profileBuilding, 22, 22),
                                      SizedBox(width: 5,),
                                      AppText(
                                        text: "${user.profile.jobDept} 재직중",
                                        fontSize: 11,
                                      )
                                    ],
                                  ),

                                  SizedBox(height: 5,),
                                ],
                              ),

                            if(user.profile.stateMsg.isNotEmpty)
                              Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      ImageUtils.setImage(ImageConstants.profileQuestion, 22, 22),
                                      SizedBox(width: 5,),
                                      AppText(
                                        text: Constants.getUserStateMsg(user.profile.stateMsg),
                                        fontSize: 11,
                                        overflow: TextOverflow.ellipsis,
                                        maxLine: 1,
                                      )
                                    ],
                                  ),

                                  SizedBox(height: 5,),
                                ],
                              ),

                            if(user.profile.linkName.isNotEmpty && user.profile.link.isNotEmpty)
                              Column(
                                children: [
                                  GestureDetector(
                                    onTap: (){
                                      String link = user.profile.link;
                                      if(!link.contains("http")) {
                                        link = "https://${user.profile.link}";
                                      }
                                      Utils.urlLaunch(link);
                                    },
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        ImageUtils.setImage(ImageConstants.profileLink, 22, 22),
                                        SizedBox(width: 5,),
                                        AppText(
                                          text: "${user.profile.linkName}",
                                          fontSize: 11,
                                          color: ColorConstants.blue1,
                                        )
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: 10,),
                                ],
                              ),

                            if(user.profile.description.isNotEmpty)
                            Container(
                              width: double.maxFinite,
                              padding: EdgeInsets.only(left: 0, right: 0,top: 10,),
                              child: RichTextView(
                                text: user.profile.description ?? "",
                                maxLines: 4,
                                truncate: true,
                                supportedTypes: [],
                                viewLessText: '줄이기',
                                viewMoreText: '더 보기',
                                viewMoreLessStyle : TextStyle(
                                    fontSize: 12,
                                    color: ColorConstants.halfWhite,
                                    fontFamily: FontConstants.AppFont,
                                    fontWeight: FontWeight.w400,
                                  height: 1.5
                                ),
                                style: TextStyle(
                                    color: ColorConstants.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: FontConstants.AppFont,
                                    height: 1.5
                                ),
                                linkStyle: TextStyle(
                                    fontSize: 12,
                                    color: ColorConstants.blue1,
                                    fontFamily: FontConstants.AppFont,
                                    fontWeight: FontWeight.w400,
                                    height: 1.5
                                ),
                              ),
                            ),

                            SizedBox(height: 10,),

                            if(user.id != Constants.user.id)
                              Padding(
                                padding: EdgeInsets.only(bottom: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:  MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                        child: GestureDetector(
                                          onTap: (){

                                          },
                                          child: Container(
                                            height: 50,
                                            margin: EdgeInsets.only(right: 5),
                                            decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),
                                                color: ColorConstants.colorMain
                                            ),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                AppText(
                                                  text: "메시지 보내기",
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,),
                                                SizedBox(width: 10),
                                                SvgPicture.asset(ImageConstants.downArrow, width: 8, height: 8,)

                                              ],
                                            ),
                                          ),
                                        )
                                    ),
                                    Expanded(
                                        child: GestureDetector(
                                          onTap: () async {
                                            if(user.isFollowing){
                                              await DioClient.postUserUnFollow(user.id);
                                              setState(() {
                                                user.isFollowing = false;
                                              });
                                            }else{
                                              await DioClient.postUserFollow(user.id);
                                              setState(() {
                                                user.isFollowing = true;
                                              });
                                            }
                                          },
                                          child: Container(
                                              height: 50,
                                              margin: EdgeInsets.only(left: 5),
                                              decoration: BoxDecoration(
                                                border: Border.all(color: ColorConstants.colorMain, width: 1.0),
                                                borderRadius: BorderRadius.all(Radius.circular(10)),

                                              ),
                                              child: !user.isFollowing ? Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.add, color: ColorConstants.colorMain, size: 16,),
                                                  SizedBox(width: 5),
                                                  AppText(text: "팔로우",
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w400,
                                                      color: ColorConstants.colorMain),
                                                ],
                                              ) : Center(
                                                child: AppText(text: "팔로잉 취소",
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: ColorConstants.colorMain),
                                              )
                                          ),
                                        )
                                    )

                                  ],
                                ),
                              ),

                            if(followGames.length != 0)
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      AppText(
                                        text: "내가 팔로잉 중인 게임",
                                        fontSize: 14,
                                        color: ColorConstants.halfWhite,
                                      ),

                                      GestureDetector(
                                        onTap: (){
                                          Get.to(ProfileFollowingGameScreen(user: user, refreshList: (){
                                            initFollowingGames();
                                          }));
                                        },
                                        child: AppText(
                                          text: "전체 보기",
                                          fontSize: 12,
                                        ),
                                      )
                                    ],
                                  ),

                                  SizedBox(height: 10,),
                                  Container(
                                    width: double.maxFinite,
                                    height: 0.5,
                                    color: ColorConstants.halfWhite,
                                  ),

                                  ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: followGames.length > 3 ? 3 : followGames.length,
                                      padding: EdgeInsets.only(top: 15),
                                      itemBuilder: (context, index){
                                        return GameUserPageWidget(game: followGames[index], isAction: false, removeItem: (){

                                        },);
                                      }
                                  ),
                                ],
                              ),


                            SizedBox(height: 15,),

                            if(user.id == Constants.user.id)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [

                                  ImageUtils.ProfileImage(user.picture, 40, 40),

                                  SizedBox(width: 10,),

                                  Flexible(
                                      child: GestureDetector(
                                        onTap: (){
                                          Get.to(NewPostScreen(uploadedPost: (post){
                                            setState(() {
                                              posts.insert(0, post);
                                            });
                                          },));
                                        },
                                        child: Container(
                                          width: double.maxFinite, // Set width according to your needs
                                          decoration: BoxDecoration(
                                            color: ColorConstants.searchBackColor,
                                            borderRadius:
                                            BorderRadius.circular(6.0), // Adjust the value as needed
                                          ),
                                          child: TextFormField(
                                            enabled: false,
                                            decoration: InputDecoration(
                                              hintText: 'What’s on your mind?',

                                              contentPadding: EdgeInsets.symmetric(
                                                  horizontal: 16.0,
                                                  vertical: 12.0), // Adjust vertical padding
                                              border: InputBorder.none,

                                              // Align hintText to center
                                              hintStyle: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white, fontSize: Get.height * 0.016),
                                              alignLabelWithHint: true,
                                            ),
                                          ),
                                        ),
                                      )
                                  )
                                ],
                              ),
                          ],
                        )
                      ),

                      SizedBox(height: 5,),

                      DefaultTabController(
                        length: 2,
                        child: TabBar(
                          indicatorColor: ColorConstants.white,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicatorWeight: 2,
                          labelColor: Colors.white,
                          dividerColor: ColorConstants.tabDividerColor,
                          unselectedLabelColor: ColorConstants.tabTextColor,
                          labelStyle: TextStyle(
                              fontSize: 14,
                              fontFamily: FontConstants.AppFont,
                              fontWeight: FontWeight.w700),
                          tabs: [
                            Tab(text: '포스트 ${totalPost}'),
                            Tab(text: '게임 ${user.games.length}'),
                          ],
                          onTap: (index) {
                            setState(() {
                              _selectedIndex = index;
                            });
                          },

                        ),
                      ),

                      (_selectedIndex==0)?
                      FutureBuilder(
                          future: postFuture,
                          builder: (context, snapShot) {
                            if(snapShot.hasData){
                              if(posts.length == 0){
                                return Padding(
                                  padding: EdgeInsets.only(top: 50,bottom: 50),
                                  child: Center(
                                    child: AppText(
                                      text: "게시중인 포스팅이 없습니다",
                                      fontSize: 14,
                                      color: ColorConstants.halfWhite,
                                    ),
                                  ),
                                );
                              }
                              return MediaQuery.removePadding(
                                removeTop: true,
                                removeRight: true,
                                removeLeft: true,
                                removeBottom: true,
                                context: context,
                                child: ListView.builder(
                                    itemCount: posts.length,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context,index){
                                      Key key = Key(posts[index].id);
                                      return  PostWidget(key: key, post: posts[index], onPostDeleteAction: (post, msg){
                                        if(msg == "delete"){
                                          setState(() {
                                            posts.removeAt(index);
                                          });
                                        }else if(msg == "userBlock"){
                                          for(int i=0;i<posts.length; i++){
                                            if(posts[i].userId == post.userId){
                                              posts.removeAt(i);
                                              i--;
                                            }
                                          }
                                          setState(() {

                                          });
                                        }
                                      },);
                                    }),
                              );
                            }

                            return Padding(
                                padding: EdgeInsets.only(top: 50,bottom: 50),
                                child: LoadingWidget()
                            );
                          }
                      )
                          : Container(
                        child:user.games.length == 0 ?
                        Padding(
                          padding: EdgeInsets.only(top: 50,bottom: 50),
                          child: Center(
                            child: AppText(
                              text: "게임이 없습니다",
                              fontSize: 14,
                              color: ColorConstants.halfWhite,
                            ),
                          ),
                        )
                            : GridView.builder(
                          padding: EdgeInsets.only(top: 20),
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, // 1개의 행에 항목을 3개씩
                              mainAxisSpacing: 0,
                              crossAxisSpacing: 0,
                              childAspectRatio: 1/1.45
                          ),
                          itemCount: user.games.length,
                          itemBuilder: (context, index) {

                            Key key = Key(user.games[index].id.toString());
                            return GameWidget(key: key, game: user.games[index]);
                          },
                        ),
                      )
                    ]),
              ),
            ),
          ],
        )
    )
    );
  }
}