import 'package:car_pooling/view/profile_screeen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

import 'find_ride_screen.dart';
import 'map_screen.dart';



class MainHomePage extends StatefulWidget {
  const MainHomePage({Key? key}) : super(key: key);

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {

  // VARIABLES

  // Bottom Bar Controller
  late PersistentTabController _controller;

  // Bottom  Bar Menu List
  List<Widget> _buildScreens() {
    return [
       MapScreen(),
      FindRideScreen(),
       ProfileScreen()
    ];
  }
  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(FontAwesomeIcons.biking),
        title: ("Share Ride"),
        activeColorPrimary:Colors.redAccent,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(FontAwesomeIcons.searchengin),
        title: ("Find Ride"),
        activeColorPrimary:Colors.redAccent,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(FontAwesomeIcons.person),
        title: ("Profile"),
        activeColorPrimary:Colors.redAccent,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),

    ];
  }

  // FUNCTIONS
  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
  }



  @override
  Widget build(BuildContext context) {
    // BOTTOM BAR
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      confineInSafeArea: true,
      backgroundColor: Colors.white, // Default is Colors.white.
      handleAndroidBackButtonPress: true, // Default is true.
      resizeToAvoidBottomInset: true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
      stateManagement: true, // Default is true.
      hideNavigationBarWhenKeyboardShows: true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(10.0),
        colorBehindNavBar: Colors.black,


      ),
      popAllScreensOnTapOfSelectedTab: true,
      popActionScreens: PopActionScreensType.all,
      itemAnimationProperties: const ItemAnimationProperties( // Navigation Bar's items animation properties.
        duration: Duration(milliseconds: 200),
        curve: Curves.ease,
      ),
      screenTransitionAnimation: const ScreenTransitionAnimation( // Screen transition animation on change of selected tab.
        animateTabTransition: true,
        curve: Curves.ease,
        duration: Duration(milliseconds: 200),
      ),
      navBarStyle: NavBarStyle.style11, // Choose the nav bar style with this property.
    );
  }

/*OLD BOTTOM BAR*/
// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     backgroundColor: Colors.black,
//     body: screens[index],
//     bottomNavigationBar: NavigationBarTheme(
//       data: NavigationBarThemeData(
//           indicatorColor: Color(0xC58E8E).withOpacity(0.16),
//           labelTextStyle: MaterialStateProperty.all(
//               GoogleFonts.sora(color: Colors.white.withOpacity(0.5)))),
//       child: NavigationBar(
//         height: 80,
//         backgroundColor: Color(0x1D1010).withOpacity(0.9),
//         labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
//         animationDuration: Duration(milliseconds: 500),
//         selectedIndex: index,
//         onDestinationSelected: (index) => setState(() => this.index = index),
//         destinations: [
//           NavigationDestination(
//             selectedIcon: Icon(Icons.home, color: Colors.white70,size: 30,),
//             icon: Icon(
//               Icons.home_outlined,
//               color: Colors.white30,
//               size: 30,
//
//             ),
//             label: "Home",
//           ),
//           NavigationDestination(
//               selectedIcon: Icon(Icons.search, color: Colors.white70,size: 30,),
//               icon: Icon(
//                 Icons.search_sharp,
//                 color: Colors.white30,
//                 size: 30,
//               ),
//               label: "Search"),
//           NavigationDestination(
//               selectedIcon: Icon(Icons.person, color: Colors.white70,size: 30,),
//               icon: Icon(
//                 Icons.person_outline_outlined,
//                 color: Colors.white30,
//                 size: 30,
//
//               ),
//               label: "Profile"),
//         ],
//       ),
//     ),
//   );
// }
}
