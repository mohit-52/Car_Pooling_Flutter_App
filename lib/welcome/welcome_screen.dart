import 'package:car_pooling/auth/on_boarding_screen.dart';
import 'package:car_pooling/welcome/welcome_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class WelcomeScreen extends StatelessWidget {
  WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final obcontroller = WelcomeController();
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          LiquidSwipe(
            liquidController: obcontroller.controller,
            onPageChangeCallback: obcontroller.onPageChangedCallback,
            pages: obcontroller.pages,
            slideIconWidget: const Icon(Icons.arrow_back_ios),
            enableLoop: false,
          ),
          Positioned(
            bottom: 60,
            child: OutlinedButton(
              onPressed: () {
                if (obcontroller.currentPage.value == 2) {
                  Get.to(() => OnBoardingScreen());
                } else {
                  obcontroller.animateToNextSlide();
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white, side: BorderSide(color: Color(0xff000000)),
                shape: CircleBorder(),
                padding: const EdgeInsets.all(20),
              ),
              child: Container(
                padding: EdgeInsets.all(20.0),
                decoration: const BoxDecoration(
                  color: Color(0xff000000),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                ),
              ),
            ),
          ),
          Positioned(
            top: 30,
            right: 10,
            child: TextButton(
              onPressed: () => obcontroller.skip(),
              child: const Text(
                'Skip',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          Obx(
                () => Positioned(
              bottom: 15,
              child: AnimatedSmoothIndicator(
                activeIndex: obcontroller.currentPage.value,
                count: 3,
                effect: const WormEffect(
                  activeDotColor: Color(0xff000000),
                  dotHeight: 5.0,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
