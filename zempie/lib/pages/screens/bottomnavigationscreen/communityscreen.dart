import 'package:app/Constants/Constants.dart';
import 'package:app/pages/components/loading_widget.dart';
import 'package:app/pages/screens/profile/profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart' hide Trans;
import '../../../Constants/ColorConstants.dart';
import '../../../Constants/FontConstants.dart';
import '../../../Constants/ImageConstants.dart';
import '../../../global/DioClient.dart';
import '../../../models/CommunityModel.dart';
import '../../base/base_state.dart';
import '../../components/CommunityWidget.dart';
import '../../components/CutomTitleBar.dart';
import '../../components/app_text.dart';
import '../communityScreens/community_detal_screen.dart';


class CommunityScreen extends StatefulWidget {
  CommunityScreen({Key? key}) : super(key: key);

  @override
  State<CommunityScreen> createState() => _CommunityScreen();
}

class _CommunityScreen extends BaseState<CommunityScreen> {

  int _selectedIndex = 0;
  int _selectedAllSubIndex = 0;
  int _selectedMySubIndex = 0;
  List<OptionModel> allCommunityTabs=[
    OptionModel(title: "추천" ,isSelect: true.obs),
    OptionModel(title: "신규" ,isSelect: false.obs),
    OptionModel(title: "멤버" ,isSelect: false.obs),
    OptionModel(title: "방문자" ,isSelect: false.obs),
  ];
   List<OptionModel> myCommunityTabs=[
     OptionModel(title: "최근 방문일" ,isSelect: true.obs),
     OptionModel(title: "멤버" ,isSelect: false.obs),
     OptionModel(title: "방문자" ,isSelect: false.obs),
   ];

   bool isInitialLoading = false;

   late Future allRecommandFuture;
   late List<CommunityModel> allRecommands;
   bool hasNextAllRecommand = false;
   int allRecommandPage = 1;
  ScrollController allRecommandController = ScrollController();

  late Future allNewFuture;
  late List<CommunityModel> allNews;
  bool hasNextAllNew = false;
  int allNewPage = 1;
  ScrollController allNewController = ScrollController();

  late Future allMemberFuture;
  late List<CommunityModel> allMembers;
  bool hasNextAllMember = false;
  int allMemberPage = 1;
  ScrollController allMemberController = ScrollController();

  late Future allVisitFuture;
  late List<CommunityModel> allVisits;
  bool hasNextAllVisit = false;
  int allVisitPage = 1;
  ScrollController allVisitController = ScrollController();

  late Future myRecentFuture;
  late List<CommunityModel> myRecents;
  bool hasNextmyRecent = false;
  int myRecentPage = 1;
  ScrollController myRecentController = ScrollController();

  late Future myMemberFuture;
  late List<CommunityModel> myMembers;
  bool hasNextmyMember = false;
  int myMemberPage = 1;
  ScrollController myMemberController = ScrollController();

  late Future myVisitFuture;
  late List<CommunityModel> myVisits;
  bool hasNextmyVisit = false;
  int myVisitPage = 1;
  ScrollController myVisitController = ScrollController();

  Future<void> initCommunities() async {
    setState(() {
      isInitialLoading = true;
    });
    allRecommands = Constants.allRecommands;
    hasNextAllRecommand = Constants.hasNextAllRecommand;

    allNews = Constants.allNews;
    hasNextAllNew = Constants.hasNextAllNew;

    allMembers = Constants.allMembers;
    hasNextAllMember = Constants.hasNextAllMember;

    allVisits = Constants.allVisits;
    hasNextAllVisit = Constants.hasNextAllVisit;

    myRecents = Constants.myRecents;
    hasNextmyRecent = Constants.hasNextmyRecent;

    myMembers = Constants.myMembers;
    hasNextmyMember = Constants.hasNextmyMember;

    myVisits = Constants.myVisits;
    hasNextmyVisit = Constants.hasNextmyVisit;
    setState(() {
      isInitialLoading = false;
    });
  }


  Future<void> getAllRecommandNextPage() async {
    if (allRecommandController.position.extentAfter < 200 && !isLoading && hasNextAllRecommand) {
      isLoading = true;
      var allRecommandResponse = DioClient.getCommunityList("created_at", 10, allRecommandPage);
      allRecommandResponse.then(
              (response) {
            List<CommunityModel> allRecommandResult = response.data["result"] == null
                ? [] : response.data["result"].map((json) => CommunityModel.fromJson(json)).toList().cast<CommunityModel>();
            allRecommandPage += 1;
            hasNextAllRecommand = response.data["pageInfo"]?["hasNextPage"] ?? false;
            allRecommands.addAll(allRecommandResult);
          }
      );
      isLoading = false;
    }
  }

  Future<void> getAllNewNextPage() async {
    if (allNewController.position.extentAfter < 200 && !isLoading && hasNextAllNew) {
      isLoading = true;
      var allNewResponse = DioClient.getCommunityList("created_at", 10, allNewPage);
      allNewResponse.then(
              (response) {
            List<CommunityModel> allNewResult = response.data["result"] == null
                ? [] : response.data["result"].map((json) => CommunityModel.fromJson(json)).toList().cast<CommunityModel>();
            allNewPage += 1;
            hasNextAllNew = response.data["pageInfo"]?["hasNextPage"] ?? false;
            allNews.addAll(allNewResult);
          }
      );
      isLoading = false;
    }
  }

  Future<void> getAllMemberNextPage() async {
    if (allMemberController.position.extentAfter < 200 && !isLoading && hasNextAllMember) {
      isLoading = true;
      var allMemberResponse = DioClient.getCommunityList("member_cnt", 10, allMemberPage);
      allMemberResponse.then(
              (response) {
            List<CommunityModel> allMemberResult = response.data["result"] == null
                ? [] : response.data["result"].map((json) => CommunityModel.fromJson(json)).toList().cast<CommunityModel>();
            allMemberPage += 1;
            hasNextAllMember = response.data["pageInfo"]?["hasNextPage"] ?? false;
            allMembers.addAll(allMemberResult);
          }
      );
      isLoading = false;
    }
  }

  Future<void> getAllVisitNextPage() async {
    if (allVisitController.position.extentAfter < 200 && !isLoading && hasNextAllVisit) {
      isLoading = true;
      var allVisitResponse = DioClient.getCommunityList("visit_cnt", 10, allVisitPage);
      allVisitResponse.then(
              (response) {
            List<CommunityModel> allVisitResult = response.data["result"] == null
                ? [] : response.data["result"].map((json) => CommunityModel.fromJson(json)).toList().cast<CommunityModel>();
            allVisitPage += 1;
            hasNextAllVisit = response.data["pageInfo"]?["hasNextPage"] ?? false;
            allVisits.addAll(allVisitResult);
          }
      );
      isLoading = false;
    }
  }

  Future<void> getMyRecentNextPage() async {
    if (myRecentController.position.extentAfter < 200 && !isLoading && hasNextmyRecent) {
      isLoading = true;
      var myRecentResponse = DioClient.getMyCommunityList("created_cnt", 10, myRecentPage);
      myRecentResponse.then(
              (response) {
            List<CommunityModel> myRecentResult = response.data["result"] == null
                ? [] : response.data["result"].map((json) => CommunityModel.fromJson(json)).toList().cast<CommunityModel>();
            myRecentPage += 1;
            hasNextmyRecent = response.data["pageInfo"]?["hasNextPage"] ?? false;
            myRecents.addAll(myRecentResult);
          }
      );
      isLoading = false;
    }
  }

  Future<void> getMyMemberNextPage() async {
    if (myMemberController.position.extentAfter < 200 && !isLoading && hasNextmyMember) {
      isLoading = true;
      var myMemberResponse = DioClient.getMyCommunityList("member_cnt", 10, myMemberPage);
      myMemberResponse.then(
              (response) {
            List<CommunityModel> myMemberResult = response.data["result"] == null
                ? [] : response.data["result"].map((json) => CommunityModel.fromJson(json)).toList().cast<CommunityModel>();
            myMemberPage += 1;
            hasNextmyMember = response.data["pageInfo"]?["hasNextPage"] ?? false;
            myMembers.addAll(myMemberResult);
          }
      );
      isLoading = false;
    }
  }

  Future<void> getMyVisitNextPage() async {
    if (myVisitController.position.extentAfter < 200 && !isLoading && hasNextmyVisit) {
      isLoading = true;
      var myVisitResponse = DioClient.getMyCommunityList("visit_cnt", 10, myVisitPage);
      myVisitResponse.then(
              (response) {
            List<CommunityModel> myVisitResult = response.data["result"] == null
                ? [] : response.data["result"].map((json) => CommunityModel.fromJson(json)).toList().cast<CommunityModel>();
            myVisitPage += 1;
            hasNextmyVisit = response.data["pageInfo"]?["hasNextPage"] ?? false;
            myVisits.addAll(myVisitResult);
          }
      );
      isLoading = false;
    }
  }

  @override
  void initState() {
    initCommunities();
    super.initState();
    allRecommandController.addListener(getAllRecommandNextPage);
    allNewController.addListener(getAllNewNextPage);
    allMemberController.addListener(getAllMemberNextPage);
    allVisitController.addListener(getAllVisitNextPage);

    myRecentController.addListener(getMyRecentNextPage);
    myMemberController.addListener(getMyMemberNextPage);
    myVisitController.addListener(getMyVisitNextPage);
  }

    @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: ColorConstants.colorBg1,
        body: Column(
          children: [

            Padding(
                padding: EdgeInsets.only(left: 10, right: 10),

                child: CustomTitleBar(callBack: (){
                  Get.to(ProfileScreen(user: Constants.user));
                },)),
            SizedBox(height: Get.height*0.02),
            TabBar(
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
                Tab(text: '모든 커뮤니티'),
                Tab(text: '내 커뮤니티'),

              ],
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),

            SizedBox(height: 10,),
            Padding(
              padding:EdgeInsets.only(right: Get.width*0.01,left: Get.width*0.01),
              child: SizedBox(
                height: Get.height * 0.04,
                width: Get.width,
                child:
                _selectedIndex == 0 ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: allCommunityTabs.length,
                  itemBuilder: (context, index) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap:(){
                            setState(() {
                              _selectedAllSubIndex = index;
                            });
                          },
                          child:
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: Get.width * 0.01),

                            width: Get.width * 0.22,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color:
                              _selectedAllSubIndex == index ? ColorConstants.gryBox : ColorConstants.colorBg1,
                            ),
                            child: Center(
                              child: AppText(
                                text: allCommunityTabs[index].title!,
                                fontSize: 0.016,
                                color: Colors.white,
                                fontFamily: FontConstants.AppFont,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                        ),
                      ],
                    );
                  },
                ) : Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: myCommunityTabs.length,
                        itemBuilder: (context, index) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                  onTap:(){
                                    setState(() {
                                      _selectedMySubIndex = index;
                                    });
                                  },
                                  child:
                                  Container(
                                    margin: EdgeInsets.symmetric(horizontal: Get.width * 0.01),

                                    width: Get.width * 0.22,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      color: _selectedMySubIndex == index ? ColorConstants.gryBox : ColorConstants.colorBg1,
                                    ),
                                    child: Center(
                                      child: AppText(
                                        text: myCommunityTabs[index].title!,
                                        fontSize: 0.016,
                                        color: Colors.white,
                                        fontFamily: FontConstants.AppFont,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  )
                              ),
                            ],
                          );
                        },
                      )
                    ],
                  )
                )
              ),
            ),
            SizedBox(height: Get.height*0.01,),

            _selectedIndex == 0 ?
                _selectedAllSubIndex == 0 ? allRecommandWidget() :
                    _selectedAllSubIndex == 1 ? allNewWidget() :
                        _selectedAllSubIndex == 2 ? allMemberWidget() :
                            allVisitWidget() :
                _selectedMySubIndex == 0 ? myRecentWidget() :
                _selectedMySubIndex == 1 ? myMemberWidget() :
                myVisitWidget(),

            SizedBox(height: Get.height*0.07,),



          ],
        ),
      ),
    );
  }

  Widget allRecommandWidget() {
    if(isInitialLoading){
      return Expanded(
        child: Center(
          child: LoadingWidget(),
        ),
      );
    }
    if(allRecommands.length == 0){
      return Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 50,bottom: 50),
            child: Center(
              child: AppText(
                text: "커뮤니티가 없습니다",
                fontSize: 14,
                color: ColorConstants.halfWhite,
              ),
            ),
          )
      );
    }
    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = size.width * 0.4 * 1.5; // Adjust the fraction as needed
    final double itemWidth = size.width * 0.4;
    return Expanded(
        child: MediaQuery.removePadding(
            context: context,
            removeBottom: true,
            removeRight: true,
            removeLeft: true,
            removeTop: true,
            child: GridView.builder(
              padding: EdgeInsets.only(top: 20),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              controller: allRecommandController,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 1개의 행에 항목을 3개씩
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: (itemWidth / itemHeight)
              ),
              itemCount: hasNextAllRecommand ? allRecommands.length+1 : allRecommands.length,
              itemBuilder: (context, index) {
                if(allRecommands.length == index){
                  return Padding(
                    padding: EdgeInsets.only(top: 30, bottom: 50),
                    child: LoadingWidget(),
                  );
                }
                Key key = Key("0_0_${allRecommands[index].id}");
                return CommunityWidget(key: key, community: allRecommands[index]);
              },
            )
        )
    );
  }

  Widget allNewWidget() {
    if(isInitialLoading){
      return LoadingWidget();
    }
    if(allNews.length == 0){
      return Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 50,bottom: 50),
            child: Center(
              child: AppText(
                text: "커뮤니티가 없습니다",
                fontSize: 14,
                color: ColorConstants.halfWhite,
              ),
            ),
          )
      );
    }
    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = size.width * 0.4 * 1.5; // Adjust the fraction as needed
    final double itemWidth = size.width * 0.4;
    return Expanded(
        child: MediaQuery.removePadding(
            context: context,
            removeBottom: true,
            removeRight: true,
            removeLeft: true,
            removeTop: true,
            child: GridView.builder(
              padding: EdgeInsets.only(top: 20),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              controller: allNewController,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 1개의 행에 항목을 3개씩
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: (itemWidth / itemHeight)
              ),
              itemCount: hasNextAllNew ? allNews.length+1 : allNews.length,
              itemBuilder: (context, index) {
                if(allNews.length == index){
                  return Padding(
                    padding: EdgeInsets.only(top: 30, bottom: 50),
                    child: LoadingWidget(),
                  );
                }
                Key key = Key("0_1_${allNews[index].id}");
                return CommunityWidget(key: key, community: allNews[index]);
              },
            )
        )
    );
  }

  Widget allMemberWidget() {
    if(isInitialLoading){
      return LoadingWidget();
    }
    if(allMembers.length == 0){
      return Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 50,bottom: 50),
            child: Center(
              child: AppText(
                text: "커뮤니티가 없습니다",
                fontSize: 14,
                color: ColorConstants.halfWhite,
              ),
            ),
          )
      );
    }
    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = size.width * 0.4 * 1.5; // Adjust the fraction as needed
    final double itemWidth = size.width * 0.4;
    return Expanded(
        child: MediaQuery.removePadding(
            context: context,
            removeBottom: true,
            removeRight: true,
            removeLeft: true,
            removeTop: true,
            child: GridView.builder(
              padding: EdgeInsets.only(top: 20),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              controller: allMemberController,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 1개의 행에 항목을 3개씩
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: (itemWidth / itemHeight)
              ),
              itemCount: hasNextAllMember ? allMembers.length+1 : allMembers.length,
              itemBuilder: (context, index) {
                if(allMembers.length == index){
                  return Padding(
                    padding: EdgeInsets.only(top: 30, bottom: 50),
                    child: LoadingWidget(),
                  );
                }
                Key key = Key("0_2_${allMembers[index].id}");
                return CommunityWidget(key: key, community: allMembers[index]);
              },
            )
        )
    );
  }

  Widget allVisitWidget() {
    if(isInitialLoading){
      return LoadingWidget();
    }
    if(allVisits.length == 0){
      return Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 50,bottom: 50),
            child: Center(
              child: AppText(
                text: "커뮤니티가 없습니다",
                fontSize: 14,
                color: ColorConstants.halfWhite,
              ),
            ),
          )
      );
    }
    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = size.width * 0.4 * 1.5; // Adjust the fraction as needed
    final double itemWidth = size.width * 0.4;
    return Expanded(
        child: MediaQuery.removePadding(
            context: context,
            removeBottom: true,
            removeRight: true,
            removeLeft: true,
            removeTop: true,
            child: GridView.builder(
              padding: EdgeInsets.only(top: 20),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              controller: allVisitController,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 1개의 행에 항목을 3개씩
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: (itemWidth / itemHeight)
              ),
              itemCount: hasNextAllVisit ? allVisits.length+1 : allVisits.length,
              itemBuilder: (context, index) {
                if(allVisits.length == index){
                  return Padding(
                    padding: EdgeInsets.only(top: 30, bottom: 50),
                    child: LoadingWidget(),
                  );
                }
                Key key = Key("0_3_${allVisits[index].id}");
                return CommunityWidget(key: key, community: allVisits[index]);
              },
            )
        )
    );
  }

  Widget myRecentWidget() {
    if(isInitialLoading){
      return LoadingWidget();
    }
    if(myRecents.length == 0){
      return Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 50,bottom: 50),
            child: Center(
              child: AppText(
                text: "커뮤니티가 없습니다",
                fontSize: 14,
                color: ColorConstants.halfWhite,
              ),
            ),
          )
      );
    }
    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = size.width * 0.4 * 1.5; // Adjust the fraction as needed
    final double itemWidth = size.width * 0.4;
    return Expanded(
        child: MediaQuery.removePadding(
            context: context,
            removeBottom: true,
            removeRight: true,
            removeLeft: true,
            removeTop: true,
            child: GridView.builder(
              padding: EdgeInsets.only(top: 20),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              controller: myRecentController,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 1개의 행에 항목을 3개씩
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: (itemWidth / itemHeight)
              ),
              itemCount: hasNextmyRecent ? myRecents.length+1 : myRecents.length,
              itemBuilder: (context, index) {
                if(myRecents.length == index){
                  return Padding(
                    padding: EdgeInsets.only(top: 30, bottom: 50),
                    child: LoadingWidget(),
                  );
                }
                Key key = Key("1_0_${myRecents[index].id}");
                return CommunityWidget(key: key, community: myRecents[index]);
              },
            )
        )
    );
  }

  Widget myMemberWidget() {
    if(isInitialLoading){
      return LoadingWidget();
    }
    if(myMembers.length == 0){
      return Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 50,bottom: 50),
            child: Center(
              child: AppText(
                text: "커뮤니티가 없습니다",
                fontSize: 14,
                color: ColorConstants.halfWhite,
              ),
            ),
          )
      );
    }
    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = size.width * 0.4 * 1.5; // Adjust the fraction as needed
    final double itemWidth = size.width * 0.4;
    return Expanded(
        child: MediaQuery.removePadding(
            context: context,
            removeBottom: true,
            removeRight: true,
            removeLeft: true,
            removeTop: true,
            child: GridView.builder(
              padding: EdgeInsets.only(top: 20),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              controller: myMemberController,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 1개의 행에 항목을 3개씩
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: (itemWidth / itemHeight)
              ),
              itemCount: hasNextmyMember ? myMembers.length+1 : myMembers.length,
              itemBuilder: (context, index) {
                if(myMembers.length == index){
                  return Padding(
                    padding: EdgeInsets.only(top: 30, bottom: 50),
                    child: LoadingWidget(),
                  );
                }
                Key key = Key("1_1_${myMembers[index].id}");
                return CommunityWidget(key: key, community: myMembers[index]);
              },
            )
        )
    );
  }

  Widget myVisitWidget() {
    if(isInitialLoading){
      return LoadingWidget();
    }
    if(myVisits.length == 0){
      return Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 50,bottom: 50),
            child: Center(
              child: AppText(
                text: "커뮤니티가 없습니다",
                fontSize: 14,
                color: ColorConstants.halfWhite,
              ),
            ),
          )
      );
    }
    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = size.width * 0.4 * 1.5; // Adjust the fraction as needed
    final double itemWidth = size.width * 0.4;
    return Expanded(
        child: MediaQuery.removePadding(
            context: context,
            removeBottom: true,
            removeRight: true,
            removeLeft: true,
            removeTop: true,
            child: GridView.builder(
              padding: EdgeInsets.only(top: 20),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              controller: myVisitController,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 1개의 행에 항목을 3개씩
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: (itemWidth / itemHeight)
              ),
              itemCount: hasNextmyVisit ? myVisits.length+1 : myVisits.length,
              itemBuilder: (context, index) {
                if(myVisits.length == index){
                  return Padding(
                    padding: EdgeInsets.only(top: 30, bottom: 50),
                    child: LoadingWidget(),
                  );
                }
                Key key = Key("1_2_${myVisits[index].id}");
                return CommunityWidget(key: key, community: myVisits[index]);
              },
            )
        )
    );
  }
}