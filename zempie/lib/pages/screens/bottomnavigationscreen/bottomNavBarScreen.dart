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

class HomeController{
  late void Function() initHome;
}

class BottomNavBarScreen extends StatefulWidget {
  BottomNavBarScreen({super.key, this.tagString});
  String? tagString;

  @override
  State<BottomNavBarScreen> createState() => _BottomNavBarScreen();
}

class _BottomNavBarScreen extends BaseState<BottomNavBarScreen> {
  final HomeController homeController = HomeController();
  final HomeController discoverController = HomeController();
  final HomeController communityController = HomeController();
   final GlobalKey<NavigatorState> _discoverNavigatorKey = GlobalKey<NavigatorState>();
   final GlobalKey _globalKey = GlobalKey();
   PersistentTabController controller = PersistentTabController();
   late DiscoverScreen discoverScreen;
   late HomeScreen homeScreen;
   late CommunityScreen communityScreen;
   late NotificationScreen notificationScreen;
   String? hashTag;
   int previousIndex = 0;


   List<Widget> _buildScreens() {
     return [
       homeScreen,
       Navigator(
         key: _discoverNavigatorKey,
         initialRoute: "/",
         onGenerateRoute: onDiscoverGenerateRoute,
       ),
       communityScreen,
       // ZemTownScreen(),
       notificationScreen
     ];
   }

   void homeInit(){

   }

   void discoverInit(){

   }

   void communityInit(){

   }

   List<PersistentBottomNavBarItem> _navBarsItems() {
     return [
       PersistentBottomNavBarItem(
           icon: Image.asset(ImageConstants.bottomHome, color: ColorConstants.colorMain, height: 35, width: 35),
           title: "Home",
           activeColorPrimary: ColorConstants.colorMain,
           inactiveColorPrimary: ColorConstants.bottomGrey,
           activeColorSecondary:  ColorConstants.colorMain,
           inactiveIcon: Image.asset(ImageConstants.bottomHomeUnselect, color: ColorConstants.bottomGrey, height: 35, width: 35)
       ),
       PersistentBottomNavBarItem(
         icon: Image.asset(ImageConstants.bottomDiscover, color: ColorConstants.colorMain, height: 35, width: 35),
         title: "Discover",
           activeColorPrimary: ColorConstants.colorMain,
           inactiveColorPrimary: ColorConstants.bottomGrey,
           inactiveIcon: Image.asset(ImageConstants.bottomDiscoverUnselect, color: ColorConstants.bottomGrey, height: 35, width: 35)
       ),

       PersistentBottomNavBarItem(
           icon: Image.asset(ImageConstants.bottomCommunity, color: ColorConstants.colorMain, height: 35, width: 35),
           title: "Community",
           activeColorPrimary: ColorConstants.colorMain,
           inactiveColorPrimary: ColorConstants.bottomGrey,
           inactiveIcon: Image.asset(ImageConstants.bottomCommunityUnselect,color: ColorConstants.bottomGrey, height: 35, width: 35)
       ),
       // PersistentBottomNavBarItem(
       //   icon: SvgPicture.asset(ImageConstants.zemtownIcon, color: ColorConstants.colorMain, height: 35, width: 35),
       //     //SvgPicture.asset(ImageString.educationIcon),
       //     title: "Zemtown",
       //     activeColorPrimary: ColorConstants.colorMain,
       //     inactiveColorPrimary: ColorConstants.bottomGrey,
       //     inactiveIcon: SvgPicture.asset(ImageConstants.zemtownIcon,color: ColorConstants.bottomGrey, height: 35, width: 35)
       // ),
       PersistentBottomNavBarItem(
           icon: Image.asset(ImageConstants.bottomNotification, color: ColorConstants.colorMain, height: 35, width: 35),
           title: "Notification",
           activeColorPrimary: ColorConstants.colorMain,
           inactiveColorPrimary: ColorConstants.bottomGrey,
           inactiveIcon: Image.asset(ImageConstants.bottomNotificationUnselect, color: ColorConstants.bottomGrey)
       ),
     ];
   }

   MaterialPageRoute onDiscoverGenerateRoute(RouteSettings settings) {
     if(settings.name == RouteString.disvoerMain) {
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
     homeScreen = HomeScreen(homeController: homeController,);
    discoverScreen = DiscoverScreen(discoverController: discoverController, hashTag: hashTag, changePage: (route, searchStr){
       _discoverNavigatorKey.currentState?.pushNamed(
           route, arguments: searchStr
       );
     }, onTapLogo: (){
      controller.jumpToTab(0);
    },);
    communityScreen = CommunityScreen(communityController: communityController, onTapLogo: (){
      controller.jumpToTab(0);
    },);
    notificationScreen = NotificationScreen(onTapLogo: (){
      controller.jumpToTab(0);
    },);
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
        navBarHeight: 70,
        onItemSelected: (index){
          print(controller.index);
          if(previousIndex == index){
            if(index == 0){
              homeController.initHome();
            }else if(index == 1){
              discoverController.initHome();
              if(_discoverNavigatorKey.currentState?.canPop() ?? false){
                _discoverNavigatorKey.currentState!.pop();
              }
            }else if(index == 2){
              communityController.initHome();
            }
          }
          previousIndex = index;
        },
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
        navBarStyle: NavBarStyle.style8,
      ),
    );
  }
}
