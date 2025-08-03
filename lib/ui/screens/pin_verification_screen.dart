import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:get/get.dart'; // Import GetX
import 'package:task_manager_project/data/services/auth_service.dart';
import 'package:task_manager_project/ui/screens/main_nav_bar_holder.dart';
import 'package:task_manager_project/ui/screens/set_password_screen.dart';
import 'package:task_manager_project/ui/screens/sign_in.dart';

class PinVerificationController extends GetxController {
  String flow = 'signup';
  String email = '';
  final RxString otp = ''.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    flow = args?['flow'] ?? 'signup';
    email = args?['email'] ?? '';
  }

  Future<void> onTapVerifyButton() async {
    if (otp.value.length != 6) {
      Get.snackbar(
        'Error',
        'Please enter a 6-digit OTP',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true; 
    try {
      if (flow == 'reset_password') {
        final response = await AuthService.verifyOtp(email, otp.value);

        if (response['status'] == 'success') {
          Get.toNamed(
            SetPasswordScreen.name,
            arguments: {
              'email': email,
              'otp': otp.value,
            },
          );
        } else {
          Get.snackbar(
            'Verification Failed',
            response['data'] ?? 'Invalid OTP',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        Get.offAllNamed(MainNavBarHolder.name);
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

  void backToSignInButton() {
    Get.offAllNamed(SignIn.name);
  }
}

class PinVerificationScreen extends StatelessWidget {
  const PinVerificationScreen({super.key});
  static const String name = '/pinVerificationScreen';

  @override
  Widget build(BuildContext context) {
    final PinVerificationController controller = Get.put(PinVerificationController());

    return Scaffold(
      body: Center(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(48.0),
              child: Column(
                children: [
                  Text(
                    'Pin Verification',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Text(
                    'A 6 digit verification code has been sent to your email address',
                  ),
                  const SizedBox(height: 24),
                  PinCodeTextField(
                    backgroundColor: Colors.transparent,
                    appContext: context,
                    length: 6,
                    keyboardType: TextInputType.number,
                    pinTheme: PinTheme(shape: PinCodeFieldShape.box),
                    onChanged: (value) {
                      controller.otp.value = value;
                    },
                    onCompleted: (value) {
                      controller.otp.value = value;
                    },
                  ),
                  const SizedBox(height: 24),
                  Obx(
                    () => ElevatedButton(
                      onPressed: controller.isLoading.value ? null : controller.onTapVerifyButton,
                      child: controller.isLoading.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Verify'),
                    ),
                  ),
                  const SizedBox(height: 30),
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
    );
  }
}
