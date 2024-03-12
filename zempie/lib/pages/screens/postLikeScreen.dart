import 'package:app/global/DioClient.dart';
import 'package:app/models/CommunityModel.dart';
import 'package:app/models/GameModel.dart';
import 'package:app/models/PostModel.dart';
import 'package:app/pages/components/loading_widget.dart';
import 'package:app/pages/screens/communityScreens/nicknameScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart' hide Trans;
import '../../../Constants/ColorConstants.dart';
import '../../../Constants/FontConstants.dart';
import '../../../Constants/ImageConstants.dart';
import '../../../models/User.dart';
import '../base/base_state.dart';
import '../components/UserListItemWidget.dart';
import '../components/app_text.dart';

class PostLikeScreen extends StatefulWidget {
  PostLikeScreen({Key? key, required this.post}) : super(key: key);
  PostModel post;

  @override
  State<PostLikeScreen> createState() => _PostLikeScreen();
}

class _PostLikeScreen extends BaseState<PostLikeScreen> {

  late PostModel post;

  late List<PostLikeModel> users;
  late Future userFuture;
  int userPage = 0;
  bool hasUserNextPage = false;
  bool isLoading = false;
  ScrollController userScrollController = ScrollController();

  Future<List<PostLikeModel>> initUsers() async{
    var response = await DioClient.getPostLikeUsers(post.id, post.likeCount, 0);
    List<PostLikeModel> userResults = response.data == null ? [] : response
        .data.map((json) => PostLikeModel.fromJson(json)).toList().cast<
        PostLikeModel>();
    userPage = 1;
    hasUserNextPage = false;
    users = userResults;

    return users;
  }

  Future<void> getUserNextPage() async {
    if (!isLoading && userScrollController.position.extentAfter < 200 && hasUserNextPage) {
      var response = await DioClient.getPostLikeUsers(post.id, 20, userPage);
      List<PostLikeModel> userResults = response.data["result"] == null ? [] : response
          .data["result"].map((json) => PostLikeModel.fromJson(json)).toList().cast<
          PostLikeModel>();
      userPage += 1;
      hasUserNextPage = response.data["pageInfo"]?["hasNextPage"] ?? false;
      setState(() {
        users.addAll(userResults);
      });
      isLoading = true;
    }
  }

  @override
  void initState() {
    post = widget.post;
    userFuture = initUsers();
    super.initState();
    userScrollController.addListener(getUserNextPage);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: ColorConstants.colorBg1,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
                top: Get.height * 0.06,
                left: Get.width * 0.05,
                right: Get.width * 0.05,
                bottom: 15),
            child:Row(
              children: [
                GestureDetector(
                  onTap:(){
                    Get.back();
                  },
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  width: Get.width * 0.01,
                ),
                AppText(
                  text: "좋아요",
                  fontSize: 16,
                  color: Colors.white,
                  fontFamily: FontConstants.AppFont,
                  fontWeight: FontWeight.w700,
                ),
                AppText(
                  text: " ${post.likeCount}",
                  fontSize: 16,
                  color: ColorConstants.yellow,
                  fontFamily: FontConstants.AppFont,
                  fontWeight: FontWeight.w700,
                ),
              ],
            ),
          ),

          FutureBuilder(
            future: userFuture,
            builder: (context, snapshot){
              if(snapshot.hasData){
                if(users.isEmpty){
                  return Expanded(
                      child: Center(
                        child: AppText(
                          text: "좋아요가 없습니다",
                          fontSize: 13,
                          color: ColorConstants.halfWhite,
                        ),
                      )
                  );
                }

                return Expanded(
                    child: MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      removeLeft: true,
                      removeRight: true,
                      removeBottom: true,
                      child: ListView.builder(
                          controller: userScrollController,
                          itemCount: hasUserNextPage ? users.length+1 : users.length,
                          shrinkWrap: true,
                          padding: EdgeInsets.only(top: 15,left: 10, right: 10),
                          itemBuilder: (context,index){
                            if(users.length == index){
                              return Padding(
                                padding: EdgeInsets.only(top: 30, bottom: 50),
                                child: LoadingWidget(),
                              );
                            }
                            Key key = Key(users[index].id.toString());
                            return UserListItemWidget(key: key, user: users[index].user, isShowAction: true, deleteUser: (){
                              setState(() {
                                users.removeAt(index);
                              });
                            },);
                          }),
                    )
                );
              }
              return Expanded(
                child: Center(
                  child: LoadingWidget(),
                ),
              );
            },
          )

        ],
      ),
    );
  }
}
