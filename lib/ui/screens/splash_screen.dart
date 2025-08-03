import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart'; // Import GetX
import 'package:task_manager_project/data/network/network_service.dart';
import 'package:task_manager_project/ui/screens/main_nav_bar_holder.dart';
import 'package:task_manager_project/ui/screens/sign_in.dart';
import 'package:task_manager_project/ui/utils/asset_path.dart';

class SplashScreenController extends GetxController {
  Future<void> moveToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));

    final token = await NetworkService.getToken();

    if (token != null) {
      Get.offAllNamed(MainNavBarHolder.name);
    } else {
      Get.offAllNamed(SignIn.name);
    }
  }

  @override
  void onInit() {
    super.onInit();
    moveToNextScreen();
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SplashScreenController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(AssetPath.logoSvg),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
