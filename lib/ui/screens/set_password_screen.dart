import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX
import 'package:task_manager_project/data/services/auth_service.dart';
import 'package:task_manager_project/ui/screens/sign_in.dart';

class SetPasswordController extends GetxController {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final RxBool isLoading = false.obs;

  String email = '';
  String otp = '';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    email = args?['email'] ?? '';
    otp = args?['otp'] ?? '';
  }

  Future<void> onTapConfirmButton() async {
    if (formKey.currentState!.validate()) {
      isLoading.value = true; 

      try {
        final response = await AuthService.resetPassword(
          email,
          otp,
          passwordController.text,
        );

        if (response['status'] == 'success') {
          Get.snackbar(
            'Success',
            'Password reset successful',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          Get.offAllNamed(SignIn.name);
        } else {
          Get.snackbar(
            'Password Reset Failed',
            response['data'] ?? 'Password reset failed',
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

  void backToSignInButton() {
    Get.offAllNamed(SignIn.name);
  }

  @override
  void onClose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}

class SetPasswordScreen extends StatelessWidget {
  const SetPasswordScreen({super.key});
  static const String name = '/setPasswordScreen';

  @override
  Widget build(BuildContext context) {
    final SetPasswordController controller = Get.put(SetPasswordController());

    return Scaffold(
      body: Center(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(48.0),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    children: [
                      Text(
                        'Set Password',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Minimum length password 8 character with letter and number combination',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: controller.passwordController,
                        decoration: const InputDecoration(hintText: 'Password'),
                        obscureText: true,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Password is required';
                          }
                          if (value!.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: controller.confirmPasswordController,
                        decoration: const InputDecoration(
                          hintText: 'Confirm password',
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Confirm password is required';
                          }
                          if (value != controller.passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      Obx(
                        () => ElevatedButton(
                          onPressed: controller.isLoading.value ? null : controller.onTapConfirmButton,
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Confirm'),
                        ),
                      ),
                      const SizedBox(height: 28),
                      RichText(
                        text: TextSpan(
                          text: 'Have account? ',
                          style: const TextStyle(color: Colors.black),
                          children: [
                            TextSpan(
                              text: ' Sign in',
                              style: const TextStyle(color: Colors.green),
                              recognizer: TapGestureRecognizer()
                                ..onTap = controller.backToSignInButton,
                            ),
                          ],
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
