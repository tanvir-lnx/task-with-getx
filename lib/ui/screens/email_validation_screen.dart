import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX
import 'package:task_manager_project/data/services/auth_service.dart';
import 'package:task_manager_project/ui/screens/pin_verification_screen.dart';
import 'package:task_manager_project/ui/screens/sign_in.dart';

class EmailValidationController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final RxBool isLoading = false.obs;

  Future<void> onTapSendOtpButton() async {
    if (formKey.currentState!.validate()) {
      isLoading.value = true; 
      try {
        final response = await AuthService.verifyEmailForReset(emailController.text.trim());

        if (response['status'] == 'success') {
          Get.toNamed(
            PinVerificationScreen.name,
            arguments: {
              'flow': 'reset_password',
              'email': emailController.text.trim(),
            },
          );
        } else {
          Get.snackbar(
            'Email Verification Failed',
            response['data'] ?? 'Email verification failed',
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

  void onTapBackToSignInButton() {
    Get.offAllNamed(SignIn.name);
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}

class EmailValidationScreen extends StatelessWidget {
  const EmailValidationScreen({super.key});

  static const String name = '/emailValidationScreen';

  @override
  Widget build(BuildContext context) {
    final EmailValidationController controller = Get.put(EmailValidationController());

    return Scaffold(
      body: Center(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(48.0),
              child: Form(
                key: controller.formKey,
                child: Column(
                  children: [
                    Text(
                      'Your Email Address',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Text(
                      'A 6 digit verification code will be sent to your email address',
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: controller.emailController,
                      decoration: const InputDecoration(hintText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Email is required';
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                          return 'Enter valid email format';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Obx(
                      () => ElevatedButton(
                        onPressed: controller.isLoading.value ? null : controller.onTapSendOtpButton,
                        child: controller.isLoading.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.arrow_circle_right_outlined, size: 28),
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
                              ..onTap = controller.onTapBackToSignInButton,
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
    );
  }
}
