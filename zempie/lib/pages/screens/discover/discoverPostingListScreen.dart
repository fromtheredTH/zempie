


import 'dart:convert';
import 'dart:io';

import 'package:app/Constants/Constants.dart';
import 'package:app/Constants/ImageUtils.dart';
import 'package:app/global/DioClient.dart';
import 'package:app/models/GameModel.dart';
import 'package:app/models/ReplyModel.dart';
import 'package:app/models/SettingModel.dart';
import 'package:app/models/User.dart';
import 'package:app/pages/components/BottomProfileWidget.dart';
import 'package:app/pages/components/GameSimpleItemWidget.dart';
import 'package:app/pages/components/GameUserPageWidget.dart';
import 'package:app/pages/components/ReplyWidget.dart';
import 'package:app/pages/components/item/TagCreator.dart';
import 'package:app/pages/screens/discover/GameDetailReplyScreen.dart';
import 'package:app/pages/screens/discover/GameFollowerScreen.dart';
import 'package:app/pages/screens/profile/ProfileFollowMemberScreen.dart';
import 'package:app/pages/screens/profile/profile_following_game_screen.dart';
import 'package:app/pages/screens/splash.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_core/src/get_main.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:rich_text_view/rich_text_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../../../Constants/ColorConstants.dart';
import '../../../Constants/FontConstants.dart';
import '../../../Constants/ImageConstants.dart';
import '../../../Constants/utils.dart';
import '../../../models/PostFileModel.dart';
import '../../../models/PostModel.dart';
import '../../../models/res/btn_bottom_sheet_model.dart';
import '../../components/BlockUserListItemWidget.dart';
import '../../components/BtnBottomSheetWidget.dart';
import '../../components/GalleryBottomSheet.dart';
import '../../components/GameWidget.dart';
import '../../components/MyAssetPicker.dart';
import '../../components/UserListItemWidget.dart';
import '../../components/app_text.dart';
import '../../base/base_state.dart';
import '../../components/loading_widget.dart';
import '../../components/post_widget.dart';
import '../newPostScreen.dart';

class DiscsoverPostingListScreen extends StatefulWidget {
  DiscsoverPostingListScreen({super.key, required this.post});
  PostModel post;

  @override
  State<DiscsoverPostingListScreen> createState() => _DiscsoverPostingListScreen();
}

class _DiscsoverPostingListScreen extends BaseState<DiscsoverPostingListScreen> {
  bool isLoading = false;
  ScrollController scrollController = ScrollController();
  bool hasPostNextPage = false;
  late Future postFuture;
  late List<PostModel> posts;
  int page = 0;

  Future<List<PostModel>> initPosts() async {
    var response = await DioClient.getDiscoverPostings(10, 0, widget.post.id);
    posts = response.data["result"] == null ? [] : response
        .data["result"].map((json) => PostModel.fromJson(json)).toList().cast<
        PostModel>();
    posts.insert(0, widget.post);
    hasPostNextPage = response.data["pageInfo"]?["hasNextPage"] ?? false;
    page = 1;
    hasPostNextPage = Constants.initDiscoverHasNextPage;
    return posts;
  }

  Future<void> getNextPost() async {
    if(scrollController.position.extentAfter < 200 && !isLoading && hasPostNextPage) {
      isLoading = true;
      var response = await DioClient.getDiscoverPostings(10, page, widget.post.id);
      List<PostModel> results = response.data["result"] == null ? [] : response
          .data["result"].map((json) => PostModel.fromJson(json)).toList().cast<
          PostModel>();
      page += 1;
      hasPostNextPage = response.data["pageInfo"]?["hasNextPage"] ?? false;
      setState(() {
        posts.addAll(results);
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    postFuture = initPosts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: ColorConstants.colorBg1,
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            SizedBox(height: Get.height*0.07),
            Padding(
              padding:EdgeInsets.only(left: 15, right: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
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
                        text: "tab_search_discover".tr(),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      )
                    ],
                  ),

                ],
              ),
            ),

            SizedBox(height: 20,),

            Expanded(
                child: FutureBuilder(
                    future: postFuture,
                    builder: (context, snapShot) {
                      if(snapShot.hasData) {
                        return MediaQuery.removePadding(
                            removeTop: true,
                            removeRight: true,
                            removeLeft: true,
                            removeBottom: true,
                            context: context,
                            child: RefreshIndicator(
                              onRefresh: () async {
                                await initPosts();
                                setState(() {

                                });
                              },
                              child: ListView.builder(
                                  itemCount: posts.length,
                                  shrinkWrap: true,
                                  controller: scrollController,
                                  itemBuilder: (context, index) {
                                    if (posts.length == index) {
                                      return Padding(
                                        padding: EdgeInsets.only(
                                            top: 30, bottom: 50),
                                        child: LoadingWidget(),
                                      );
                                    }
                                    Key key = Key(posts[index].id);
                                    return PostWidget(key: key, post: posts[index], onPostDeleteAction: (post, msg){
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
                            )
                        );
                      }
                      return LoadingWidget();
                    }
                ),
            )



          ],
        )
    );

  }
}