import 'package:app/pages/screens/bottomnavigationscreen/notificationscreen.dart';
import 'package:app/pages/screens/bottomnavigationscreen/zemtownscreen.dart';
import 'package:app/pages/screens/discover/discoverSearchScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart' hide Trans;
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import '../../../Constants/ColorConstants.dart';
import '../../../Constants/FontConstants.dart';
import '../../../Constants/ImageConstants.dart';
import '../../../Constants/RouteString.dart';
import '../../base/base_state.dart';
import '../../components/app_text.dart';
import 'DiscoverScreen.dart';
import 'communityscreen.dart';
import 'homescreen.dart';

class BottomNavBarScreen extends StatefulWidget {
  BottomNavBarScreen({super.key, this.tagString});
  String? tagString;

  @override
  State<BottomNavBarScreen> createState() => _BottomNavBarScreen();
}

class _BottomNavBarScreen extends BaseState<BottomNavBarScreen> {

   final GlobalKey<NavigatorState> _discoverNavigatorKey = GlobalKey<NavigatorState>();
   final GlobalKey _globalKey = GlobalKey();
   PersistentTabController controller = PersistentTabController();
   late DiscoverScreen discoverScreen;
   String? hashTag;

   List<Widget> _buildScreens() {
     return [
       HomeScreen(),
       Navigator(
         key: _discoverNavigatorKey,
         initialRoute: "/",
         onGenerateRoute: onDiscoverGenerateRoute,
       ),
       CommunityScreen(),
       ZemTownScreen(),
       NotificationScreen(),
     ];
   }

   List<PersistentBottomNavBarItem> _navBarsItems() {
     return [
       PersistentBottomNavBarItem(
           icon: SvgPicture.asset(ImageConstants.homeIcon, color: ColorConstants.colorMain, height: Get.height*0.02, width: Get.height*0.02),
           title: "Home",
           activeColorPrimary: ColorConstants.colorMain,
           inactiveColorPrimary: ColorConstants.bottomGrey,
           activeColorSecondary:  ColorConstants.colorMain,
           inactiveIcon: SvgPicture.asset(ImageConstants.homeIcon, color: ColorConstants.bottomGrey, height: Get.height*0.02, width: Get.height*0.02)
       ),
       PersistentBottomNavBarItem(
         icon: SvgPicture.asset(ImageConstants.discoverIcon, color: ColorConstants.colorMain, height: Get.height*0.02, width: Get.height*0.02),
         title: "Discover",
           activeColorPrimary: ColorConstants.colorMain,
           inactiveColorPrimary: ColorConstants.bottomGrey,
           inactiveIcon: SvgPicture.asset(ImageConstants.discoverIcon, color: ColorConstants.bottomGrey, height: Get.height*0.02, width: Get.height*0.02)
       ),

       PersistentBottomNavBarItem(
           icon: SvgPicture.asset(ImageConstants.highlightedCommunity, color: ColorConstants.colorMain, height: Get.height*0.02, width: Get.height*0.02),
           title: "Community",
           activeColorPrimary: ColorConstants.colorMain,
           inactiveColorPrimary: ColorConstants.bottomGrey,
           inactiveIcon: SvgPicture.asset(ImageConstants.communityIcon,color: ColorConstants.bottomGrey, height: Get.height*0.02, width: Get.height*0.02)
       ),
       PersistentBottomNavBarItem(
         icon: SvgPicture.asset(ImageConstants.zemtownIcon, color: ColorConstants.colorMain, height: Get.height*0.02, width: Get.height*0.02),
           //SvgPicture.asset(ImageString.educationIcon),
           title: "Zemtown",
           activeColorPrimary: ColorConstants.colorMain,
           inactiveColorPrimary: ColorConstants.bottomGrey,
           inactiveIcon: SvgPicture.asset(ImageConstants.zemtownIcon,color: ColorConstants.bottomGrey, height: Get.height*0.02, width: Get.height*0.02)
       ),
       PersistentBottomNavBarItem(
           icon: SvgPicture.asset(ImageConstants.notificationIcon, color: ColorConstants.colorMain, height: Get.height*0.02, width: Get.height*0.02),
           title: "Notification",
           activeColorPrimary: ColorConstants.colorMain,
           inactiveColorPrimary: ColorConstants.bottomGrey,
           inactiveIcon: SvgPicture.asset(ImageConstants.notificationIcon, color: ColorConstants.bottomGrey)
       ),
     ];
   }

   MaterialPageRoute onDiscoverGenerateRoute(RouteSettings settings) {
     if(settings.name == RouteString.disvoerMain) {
       // initialLoungeRoute = settings.name!;
       return MaterialPageRoute<dynamic> (
           builder: (context) => discoverScreen, settings: settings);
     }else if(settings.name == RouteString.disvoerSearch) {
       return MaterialPageRoute<dynamic> (
           builder: (context) => DiscoverSearchScreen(searchStr: settings.arguments as String), settings: settings);
     }
     throw Exception("Unknown route : ${settings.name}");
   }

   @override
  void initState() {
     hashTag = widget.tagString;
    discoverScreen = DiscoverScreen(hashTag: hashTag, changePage: (route, searchStr){
       _discoverNavigatorKey.currentState?.pushNamed(
           route, arguments: searchStr
       );
     }, );
    super.initState();
    if(widget.tagString != null){
      controller.jumpToTab(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      bottomNavigationBar:
      PersistentTabView(
        context,
        screens: _buildScreens(),
        items: _navBarsItems(),
        confineInSafeArea: true,
        bottomScreenMargin: 0,
        controller: controller,
        backgroundColor: ColorConstants.colorBg1,
        resizeToAvoidBottomInset: true,
        stateManagement: true,
        hideNavigationBarWhenKeyboardShows: true,
        decoration: NavBarDecoration(
          colorBehindNavBar: Colors.transparent,
        ),
        popAllScreensOnTapOfSelectedTab: true,
        popAllScreensOnTapAnyTabs: true,
        popActionScreens: PopActionScreensType.all,
        itemAnimationProperties: ItemAnimationProperties(
          duration: Duration(milliseconds: 200),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: ScreenTransitionAnimation(
          animateTabTransition: true,
          curve: Curves.ease,
          duration: Duration(milliseconds: 200),
        ),
        navBarStyle: NavBarStyle.style6,
      ),
    );
  }
}
