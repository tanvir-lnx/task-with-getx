import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manager_project/data/models/user_model.dart';
import 'package:task_manager_project/data/services/auth_service.dart';
import 'package:task_manager_project/ui/screens/sign_in.dart';
import 'package:task_manager_project/ui/screens/update_profile.dart';

class ConstAppBarController extends GetxController {
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    isLoading.value = true;
    try {
      final response = await AuthService.getProfile();

      if (response['status'] == 'success' && response['data'] != null) {
        final userData = response['data'];
        if (userData is List && userData.isNotEmpty) {
          currentUser.value = User.fromJson(userData.first);
        } else {
          currentUser.value = null;
        }
      } else {
        currentUser.value = null;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load user profile: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      currentUser.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  void onTapSignOutButton() async {
    await AuthService.logout();
    Get.offAllNamed(SignIn.name);
  }

  // Updated method to reload profile on return
  void onTapProfile() async {
    await Get.toNamed(UpdateProfile.name);
    loadUserProfile();
  }
}
