import 'package:app/Constants/Constants.dart';
import 'package:app/global/DioClient.dart';
import 'package:app/models/CommunityModel.dart';
import 'package:app/models/GameModel.dart';
import 'package:app/pages/components/loading_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart' hide Trans;
import '../../../Constants/ColorConstants.dart';
import '../../../Constants/FontConstants.dart';
import '../../../Constants/ImageConstants.dart';
import '../../../models/User.dart';
import '../../base/base_state.dart';
import '../../components/UserListItemWidget.dart';
import '../../components/app_text.dart';

class ProfileFollowMemberScreen extends StatefulWidget {
  ProfileFollowMemberScreen({Key? key, required this.user, this.isFollowing = true, required this.changeFollowCnt}) : super(key: key);
  UserModel user;
  bool isFollowing;
  Function(UserModel) changeFollowCnt;

  @override
  State<ProfileFollowMemberScreen> createState() => _ProfileFollowMemberScreen();
}

class _ProfileFollowMemberScreen extends BaseState<ProfileFollowMemberScreen> {

  late UserModel user;

  late List<UserModel> users;
  late Future userFuture;
  int userPage = 0;
  bool hasUserNextPage = false;
  bool isLoading = false;
  ScrollController userScrollController = ScrollController();

  Future<List<UserModel>> initUsers() async{
    late var response;
    if(widget.isFollowing) {
      response = await DioClient.getUserFollowings(user.id, 20, 0);
    }else{
      response = await DioClient.getUserFollowers(user.id, 20, 0);
    }
    List<UserModel> userResults = response.data["result"] == null ? [] : response
        .data["result"].map((json) => UserModel.fromJson(json)).toList().cast<
        UserModel>();
    userPage = 1;
    hasUserNextPage = response.data["pageInfo"]?["hasNextPage"] ?? false;
    users = userResults;

    return users;
  }

  Future<void> getUserNextPage() async {
    if (!isLoading && userScrollController.position.extentAfter < 200 && hasUserNextPage) {
      late var response;
      if(widget.isFollowing) {
        response = await DioClient.getUserFollowings(user.id, 20, userPage);
      }else{
        response = await DioClient.getUserFollowers(user.id, 20, userPage);
      }
      List<UserModel> userResults = response.data["result"] == null ? [] : response
          .data["result"].map((json) => UserModel.fromJson(json)).toList().cast<
          UserModel>();
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
    user = widget.user;
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
                  text: widget.isFollowing ? "팔로잉" : "팔로워",
                  fontSize: 16,
                  color: Colors.white,
                  fontFamily: FontConstants.AppFont,
                  fontWeight: FontWeight.w700,
                ),
                AppText(
                  text: " ${widget.isFollowing ? user.followingCnt : user.followerCnt}",
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
                          text: widget.isFollowing ? "팔로잉이 없습니다" : "팔로워가 없습니다",
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
                            return UserListItemWidget(key: key, user: users[index], isShowAction: true, deleteUser: (){
                              setState(() {
                                if(users[index].isFollowing && user.id == Constants.user.id) {
                                  user.followingCnt -= 1;
                                  users.removeAt(index);
                                  widget.changeFollowCnt(user);
                                }
                              },);
                            }, followUser: (){
                              if(user.id == Constants.user.id) {
                                setState(() {
                                  user.followingCnt += 1;
                                  widget.changeFollowCnt(user);
                                });
                              }
                            }, unFollowUser: (){
                              if(user.id == Constants.user.id) {
                                setState(() {
                                  user.followingCnt -= 1;
                                  widget.changeFollowCnt(user);
                                });
                              }
                            },
                            );
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
