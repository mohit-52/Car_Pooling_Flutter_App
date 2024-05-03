import 'package:car_pooling/welcome/welcome_page_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:liquid_swipe/liquid_swipe.dart';

import 'model_welcome.dart';



class WelcomeController extends GetxController {

  final controller = LiquidController();
  RxInt currentPage = 0.obs;

  final pages = [
    WelcomePageWidget(
      model: WelcomeModel(
        image: "assets/images/auth_image.jpg",
        title: "gfhvgfycyjcf",
        subtitle: "mOnBoardingSubTitle1",
        counterText: "mOnBoardingCounter1",
        bgColor: Colors.white,
      ),
    ),
    WelcomePageWidget(
      model: WelcomeModel(
        image:  "assets/images/logo.png",
        title: "mOnBoardingTitle2",
        subtitle: "mOnBoardingSubTitle2",
        counterText: "mOnBoardingCounter2",
        bgColor: Colors.white,
      ),
    ),
    WelcomePageWidget(
      model: WelcomeModel(
        image: "assets/images/auth_image2.jpg",
        title: "mOnBoardingTitle3",
        subtitle: "mOnBoardingSubTitle3",
        counterText: "mOnBoardingCounter3",
        bgColor: Colors.white,
      ),
    ),
  ];

  onPageChangedCallback(int activePageIndex) {
    currentPage.value = activePageIndex;
  }
  animateToNextSlide() {
    int nextPage = controller.currentPage + 1;
    controller.animateToPage(page: nextPage);
  }
  skip() => controller.jumpToPage(page: 2);
}

