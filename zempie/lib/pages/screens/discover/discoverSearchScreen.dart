import 'package:app/models/PostModel.dart';
import 'package:app/pages/components/CommunityWidget.dart';
import 'package:app/pages/components/GameWidget.dart';
import 'package:app/pages/components/UserListItemWidget.dart';
import 'package:app/pages/components/loading_widget.dart';
import 'package:app/pages/screens/discover/DiscoverGameDetails.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart' hide Trans;
import 'package:screen_brightness/screen_brightness.dart';
import '../../../Constants/ColorConstants.dart';
import '../../../Constants/Constants.dart';
import '../../../Constants/FontConstants.dart';
import '../../../Constants/ImageConstants.dart';
import '../../../Constants/ImageUtils.dart';
import '../../../global/DioClient.dart';
import '../../../models/CommunityModel.dart';
import '../../../models/GameModel.dart';
import '../../../models/User.dart';
import '../../components/app_text.dart';
import '../../base/base_state.dart';
import '../../components/discover_widget.dart';

class DiscoverSearchScreen extends StatefulWidget {
   DiscoverSearchScreen({Key? key, required this.searchStr}) : super(key: key);
   String searchStr;

  @override
  _DiscoverSearchScreenState createState() => _DiscoverSearchScreenState();
}

class _DiscoverSearchScreenState extends BaseState<DiscoverSearchScreen> {
  RxInt _selectedIndex = 0.obs;
  bool isSearchLoading = false;
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();
  ScrollController postScrollController = ScrollController();
  ScrollController userScrollController = ScrollController();
  ScrollController gameScrollController = ScrollController();
  ScrollController communityScrollController = ScrollController();

  String searchQuery = "";

  List<UserModel> users = <UserModel>[];
  bool hasUserNextPage = false;
  int userPage = 0;

  List<GameModel> games = <GameModel>[];
  bool hasGameNextPage = false;
  int gamePage = 0;

  List<CommunityModel> communities = <CommunityModel>[];
  bool hasCommunityNextPage = false;
  int communityPage = 0;

  List<PostModel> posts = <PostModel>[];
  bool hasPostNextPage = false;
  int postPage = 0;

  Future<void> initSearch(String query) async {
    setState(() {
      isSearchLoading = true;
    });
    searchQuery = query;
    var postResponse = DioClient.searchPosts(query, 10, 0);
    postResponse.then(
            (response) {
              List<PostModel> postResults = response.data["result"] == null ? [] : response
                  .data["result"].map((json) => PostModel.fromJson(json)).toList().cast<
                  PostModel>();
              postPage = 1;
              hasPostNextPage = response.data["pageInfo"]?["hasNextPage"] ?? false;
              if(_selectedIndex.value == 0) {
                setState(() {
                  posts = postResults;
                  isSearchLoading = false;
                });
              }else{
                posts = postResults;
              }
            }
    );

    var userResponse = DioClient.searchUsers(query, 10, 0);
    userResponse.then(
            (response) {
          List<UserModel> userResults = response.data["result"] == null ? [] : response
              .data["result"].map((json) => UserModel.fromJson(json)).toList().cast<
              UserModel>();
          userPage = 1;
          hasUserNextPage = response.data["pageInfo"]?["hasNextPage"] ?? false;
          if(_selectedIndex.value == 1) {
            setState(() {
              users = userResults;
              isSearchLoading = false;
            });
          }else{
            users = userResults;
          }
        }
    );

    var gameResponse = DioClient.searchGame(query, 10, 0);
    gameResponse.then(
            (response) {
          List<GameModel> gameResults = response.data["result"] == null ? [] : response
              .data["result"].map((json) => GameModel.fromJson(json)).toList().cast<
              GameModel>();
          gamePage = 1;
          hasGameNextPage = response.data["pageInfo"]?["hasNextPage"] ?? false;
          if(_selectedIndex.value == 2) {
            setState(() {
              games = gameResults;
              isSearchLoading = false;
            });
          }else{
            games = gameResults;
          }
        }
    );

    var communityResponse = DioClient.searchCommunity(query, 10, 0);
    communityResponse.then(
            (response) {
          List<CommunityModel> communityResults = response.data["result"] == null ? [] : response
              .data["result"].map((json) => CommunityModel.fromJson(json)).toList().cast<
              CommunityModel>();
          communityPage = 1;
          hasCommunityNextPage = response.data["pageInfo"]?["hasNextPage"] ?? false;
          if(_selectedIndex.value == 0) {
            setState(() {
              communities = communityResults;
              isSearchLoading = false;
            });
          }else{
            communities = communityResults;
          }
        }
    );
  }

  Future<void> getPostNextPage() async {
    if(!isLoading && postScrollController.position.extentAfter < 200 && _selectedIndex.value == 0 && hasPostNextPage) {
      isLoading = true;
      var postResponse = DioClient.searchPosts(searchQuery, 10, postPage);
      postResponse.then(
              (response) {
            List<PostModel> postResults = response.data["result"] == null ? [] : response
                .data["result"].map((json) => PostModel.fromJson(json)).toList().cast<
                PostModel>();
            postPage += 1;
            hasPostNextPage = response.data["pageInfo"]?["hasNextPage"] ?? false;
            setState(() {
              posts.addAll(postResults);
              isLoading = false;
            });
          }
      );
    }
  }

  Future<void> getUserNextPage() async {
    if(!isLoading && userScrollController.position.extentAfter < 200 && _selectedIndex.value == 1 && hasUserNextPage) {
      isLoading = true;
      var userResponse = DioClient.searchUsers(searchQuery, 10, userPage);
      userResponse.then(
              (response) {
            List<UserModel> userResults = response.data["result"] == null ? [] : response
                .data["result"].map((json) => UserModel.fromJson(json)).toList().cast<
                UserModel>();
            userPage += 1;
            hasUserNextPage = response.data["pageInfo"]?["hasNextPage"] ?? false;
            setState(() {
              users.addAll(userResults);
              isLoading = false;
            });
          }
      );
    }
  }

  Future<void> getGameNextPage() async {
    if(!isLoading && gameScrollController.position.extentAfter < 200 && _selectedIndex.value == 2 && hasGameNextPage) {
      isLoading = true;
      var gameResponse = DioClient.searchGame(searchQuery, 10, gamePage);
      gameResponse.then(
              (response) {
            List<GameModel> gameResults = response.data["result"] == null ? [] : response
                .data["result"].map((json) => GameModel.fromJson(json)).toList().cast<
                GameModel>();
            gamePage += 1;
            hasGameNextPage = response.data["pageInfo"]?["hasNextPage"] ?? false;
            setState(() {
              games.addAll(gameResults);
              isLoading = false;
            });
          }
      );
    }
  }

  Future<void> getCommunityNextPage() async {
    if(!isLoading && communityScrollController.position.extentAfter < 200 && _selectedIndex.value == 3 && hasCommunityNextPage) {
      isLoading = false;
      var communityResponse = DioClient.searchCommunity(searchQuery, 10, communityPage);
      communityResponse.then(
              (response) {
            List<CommunityModel> communityResults = response.data["result"] == null ? [] : response
                .data["result"].map((json) => CommunityModel.fromJson(json)).toList().cast<
                CommunityModel>();
            communityPage += 1;
            hasCommunityNextPage = response.data["pageInfo"]?["hasNextPage"] ?? false;
            setState(() {
              communities.addAll(communityResults);
              isLoading = false;
            });
          }
      );
    }
  }

  @override
  void initState() {
    searchController.text = widget.searchStr;
    super.initState();
    initSearch(widget.searchStr);
    postScrollController.addListener(getPostNextPage);
    userScrollController.addListener(getUserNextPage);
    gameScrollController.addListener(getGameNextPage);
    communityScrollController.addListener(getCommunityNextPage);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: ColorConstants.colorBg1,
        body: Column(
          children: [
            SizedBox(height: Get.height * 0.07),
            Padding(
              padding: EdgeInsets.only(
                  right: Get.width * 0.04, left: Get.width * 0.04),
              child: Row(
                children: [
                  GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Icon(Icons.arrow_back_ios, color: Colors.white)),
                  Flexible(child: Padding(
                    padding: EdgeInsets.only(
                        right: Get.width * 0.02, left: Get.width * 0.02),
                    child: Container(
                        decoration: BoxDecoration(
                          color: ColorConstants.searchBackColor,
                          borderRadius:
                          BorderRadius.circular(6.0), // Adjust the value as needed
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: TextFormField(
                                controller: searchController,
                                onFieldSubmitted: (text){
                                  isSearchLoading = true;
                                  initSearch(text);
                                },
                                onChanged: (text){
                                },
                                style: TextStyle(
                                    color: ColorConstants.white,
                                    fontFamily: FontConstants.AppFont,
                                    fontSize: 16
                                ),
                                textInputAction: TextInputAction.search,
                                decoration: InputDecoration(
                                  hintText: 'search_hint'.tr(),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 12.0), // Adjust vertical padding
                                  border: InputBorder.none,
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: SvgPicture.asset(ImageConstants.searchIcon,
                                      color: Colors.white,
                                    ),
                                  ),
                                  // Align hintText to center
                                  hintStyle: TextStyle(
                                      color: ColorConstants.halfWhite,
                                      fontFamily: FontConstants.AppFont,
                                      fontSize: 16),
                                  // alignLabelWithHint: true,
                                ),
                              ),
                            ),

                            Obx(() => _selectedIndex.value == 1 ?
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
                                          height: Get.width * 0.4 + 180,
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

                                              SvgPicture.asset(
                                                ImageConstants.appLogo,
                                                height: 20,),

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
                              child: ImageUtils.setImage(ImageConstants.searchQR, 20, 20),
                            ) : Container()
                            ),

                            SizedBox(width: 10,)
                          ],
                        )
                    ),
                  ),)
                ],
              ),
            ),

            SizedBox(height: Get.height * 0.014),
            TabBar(
              indicatorColor: ColorConstants.yellow,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorWeight: 2,
              labelColor: Colors.white,
              dividerColor: ColorConstants.tabDividerColor,
              unselectedLabelColor: ColorConstants.tabTextColor,
              labelStyle: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700),
              tabs: [
                Tab(text: 'post'.tr()),
                Tab(text: 'user'.tr()),
                Tab(text: 'game'.tr()),
                Tab(text: 'community'.tr()),
              ],
              onTap: (index) {
                setState(() {
                  _selectedIndex.value = index;
                });
              },
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: TabBarView(
                  children: [
                    postWidget(),
                    userPost(), // Placeholder for User tab
                    gameWidget(), // Placeholder for Game tab
                    communityWidget(), // Placeholder for Community tab
                  ],
                ),
              )
            ),
          ],
        ),
      ),
    );
  }

  Widget userPost(){
    if(isSearchLoading){
      return LoadingWidget();
    }
    if(users.length == 0){
      return Padding(
        padding: EdgeInsets.only(top: 50,bottom: 50),
        child: Center(
          child: AppText(
            text: "유저가 없습니다",
            fontSize: 14,
            color: ColorConstants.halfWhite,
          ),
        ),
      );
    }
    return MediaQuery.removePadding(
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
              return  UserListItemWidget(key: key, user: users[index], deleteUser: (){
                setState(() {
                  users.removeAt(index);
                });
              },);
            }),
      );
  }

  Widget postWidget() {
    if(isSearchLoading){
      return LoadingWidget();
    }
    if(posts.length == 0){
      return Padding(
        padding: EdgeInsets.only(top: 50,bottom: 50),
        child: Center(
          child: AppText(
            text: "포스트가 없습니다",
            fontSize: 14,
            color: ColorConstants.halfWhite,
          ),
        ),
      );
    }
    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = size.width * 0.4 * 1.7; // Adjust the fraction as needed
    final double itemWidth = size.width * 0.4;
    return MediaQuery.removePadding(
      context: context,
      removeBottom: true,
      removeRight: true,
      removeLeft: true,
      removeTop: true,
      child: GridView.builder(
        padding: EdgeInsets.only(top: 20),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        controller: postScrollController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 1개의 행에 항목을 3개씩
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: (itemWidth / itemHeight)
        ),
        itemCount: hasPostNextPage ? posts.length+1 : posts.length,
        itemBuilder: (context, index) {
          if(posts.length == index){
            return Padding(
              padding: EdgeInsets.only(top: 30, bottom: 50),
              child: LoadingWidget(),
            );
          }
          Key key = Key(posts[index].id.toString());
          return DiscoverWidget(key: key, post: posts[index]);
        },
      )
    );
  }

  Widget gameWidget(){
    if(isSearchLoading){
      return LoadingWidget();
    }
    if(games.length == 0){
      return Padding(
        padding: EdgeInsets.only(top: 50,bottom: 50),
        child: Center(
          child: AppText(
            text: "게임이 없습니다",
            fontSize: 14,
            color: ColorConstants.halfWhite,
          ),
        ),
      );
    }
    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = size.width * 0.4 * 1.45; // Adjust the fraction as needed
    final double itemWidth = size.width * 0.4;
    return MediaQuery.removePadding(
      context: context,
      removeBottom: true,
      removeRight: true,
      removeLeft: true,
      removeTop: true,
      child: GridView.builder(
        padding: EdgeInsets.only(top: 20),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        controller: gameScrollController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 1개의 행에 항목을 3개씩
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
            childAspectRatio: (itemWidth / itemHeight)
        ),
        itemCount: hasGameNextPage ? games.length+1 : games.length,
        itemBuilder: (context, index) {
          if(games.length == index){
            return Padding(
              padding: EdgeInsets.only(top: 30, bottom: 50),
              child: LoadingWidget(),
            );
          }
          Key key = Key(games[index].id.toString());
          return GameWidget(key: key, game: games[index]);
        },
      )
    );
  }

  Widget communityWidget(){
    if(isSearchLoading){
      return LoadingWidget();
    }

    if(communities.length == 0){
      return Padding(
        padding: EdgeInsets.only(top: 50,bottom: 50),
        child: Center(
          child: AppText(
            text: "커뮤니티가 없습니다",
            fontSize: 14,
            color: ColorConstants.halfWhite,
          ),
        ),
      );
    }
    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = size.width * 0.4 * 1.5; // Adjust the fraction as needed
    final double itemWidth = size.width * 0.4;
    return MediaQuery.removePadding(
        context: context,
        removeBottom: true,
        removeRight: true,
        removeLeft: true,
        removeTop: true,
        child: GridView.builder(
          padding: EdgeInsets.only(top: 20),
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          controller: communityScrollController,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 1개의 행에 항목을 3개씩
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: (itemWidth / itemHeight)
          ),
          itemCount: hasCommunityNextPage ? communities.length+1 : communities.length,
          itemBuilder: (context, index) {
            if(communities.length == index){
              return Padding(
                padding: EdgeInsets.only(top: 30, bottom: 50),
                child: LoadingWidget(),
              );
            }
            Key key = Key(communities[index].id.toString());
            return CommunityWidget(key:key, community: communities[index], onSubscribe: (community){},);
          },
        )
    );
  }

}
