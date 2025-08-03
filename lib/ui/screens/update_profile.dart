import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX
import 'package:task_manager_project/data/models/user_model.dart';
import 'package:task_manager_project/data/services/auth_service.dart';
import 'package:task_manager_project/ui/widgets/const_app_bar.dart';

// 1. Create a Controller to manage all state and logic
class UpdateProfileController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadCurrentUser();
  }

  Future<void> loadCurrentUser() async {
    isLoading.value = true;
    try {
      final response = await AuthService.getProfile();
      if (response['status'] == 'success' && response['data'] != null) {
        final userData = response['data'];
        if (userData is List && userData.isNotEmpty) {
          final user = User.fromJson(userData.first);
          emailController.text = user.email;
          firstNameController.text = user.firstName;
          lastNameController.text = user.lastName;
          phoneController.text = user.mobile;
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load user profile: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile() async {
    if (formKey.currentState!.validate()) {
      // Unfocus any active text field to hide the keyboard
      FocusManager.instance.primaryFocus?.unfocus();

      final updatedUser = User(
        email: emailController.text.trim(),
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        mobile: phoneController.text.trim(),
        password: passwordController.text.isEmpty
            ? null
            : passwordController.text,
      );

      isLoading.value = true;

      try {
        final response = await AuthService.updateProfile(updatedUser);
        if (response['status'] == 'success') {
          Get.snackbar(
            'Success',
            'Profile updated successfully!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          // Wait a moment for the UI to update and then navigate back
          await Future.delayed(const Duration(milliseconds: 500));
          Get.back();
        } else {
          Get.snackbar(
            'Error',
            'Failed to update profile: ${response['message']}',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        Get.snackbar(
          'Error',
          'Network error. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

class UpdateProfile extends StatelessWidget {
  const UpdateProfile({super.key});

  static const String name = '/updateProfile';

  @override
  Widget build(BuildContext context) {
    final UpdateProfileController controller = Get.put(
      UpdateProfileController(),
    );

    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: ConstAppBar(),
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: SafeArea(
                  child: SingleChildScrollView(
                    child: Form(
                      key: controller.formKey,
                      child: Padding(
                        padding: const EdgeInsets.all(48.0),
                        child: Column(
                          children: [
                            Text(
                              'Update Profile',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: controller.emailController,
                              decoration: const InputDecoration(
                                hintText: 'Email',
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Email is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: controller.firstNameController,
                              decoration: const InputDecoration(
                                hintText: 'First Name',
                              ),
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'First Name is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: controller.lastNameController,
                              decoration: const InputDecoration(
                                hintText: 'Last Name',
                              ),
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Last Name is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: controller.phoneController,
                              decoration: const InputDecoration(
                                hintText: 'Mobile No.',
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Phone number is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: controller.passwordController,
                              decoration: const InputDecoration(
                                hintText: 'Password',
                              ),
                              obscureText: true,
                            ),
                            const SizedBox(height: 24),
                            Obx(
                              () => ElevatedButton(
                                onPressed: controller.isLoading.value
                                    ? null
                                    : controller.updateProfile,
                                child: controller.isLoading.value
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.arrow_circle_right_outlined,
                                        size: 28,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
