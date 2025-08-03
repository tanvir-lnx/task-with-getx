import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX
import 'package:task_manager_project/data/services/auth_service.dart';
import 'package:task_manager_project/ui/screens/email_validation_screen.dart';
import 'package:task_manager_project/ui/screens/main_nav_bar_holder.dart';
import 'package:task_manager_project/ui/screens/sign_up_screen.dart';

class SignInController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final RxBool isLoading = false.obs;

  Future<void> signIn() async {
    if (formKey.currentState!.validate()) {
      isLoading.value = true; 

      try {
        final response = await AuthService.login(
          emailController.text.trim(),
          passwordController.text,
        );

        if (response['status'] == 'success') {
          Get.offAllNamed(MainNavBarHolder.name);
        } else {
          Get.snackbar(
            'Login Failed',
            response['message'] ?? 'Login failed',
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
        isLoading.value = false;       }
    }
  }

  void goToForgotPassword() {
    Get.toNamed(EmailValidationScreen.name);
  }

  void goToSignUp() {
    Get.toNamed(SignUpScreen.name);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

class SignIn extends StatelessWidget {
  const SignIn({super.key});

  static const String name = '/signIn';

  @override
  Widget build(BuildContext context) {
    final SignInController controller = Get.put(SignInController());

    return Scaffold(
      body: Center(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(48.0),
              child: Form(
                key: controller.formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Get Started With',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: controller.emailController,
                      decoration: const InputDecoration(hintText: 'Email'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.emailAddress,
                      validator: (String? value) {
                        if (value?.isEmpty ?? true) {
                          return 'Enter valid email';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value!)) {
                          return 'Enter valid email format';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: controller.passwordController,
                      decoration: const InputDecoration(hintText: 'Password'),
                      obscureText: true,
                      validator: (String? value) {
                        if (value?.isEmpty ?? true) {
                          return 'Enter valid password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Obx(
                      () => ElevatedButton(
                        onPressed: controller.isLoading.value ? null : controller.signIn,
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
                    const SizedBox(height: 58),
                    TextButton(
                      onPressed: controller.goToForgotPassword,
                      child: const Text('Forgot password?'),
                    ),
                    RichText(
                      text: TextSpan(
                        text: "Don't have account? ",
                        style: const TextStyle(
                          letterSpacing: .4,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                        children: [
                          TextSpan(
                            text: ' Sign up',
                            style: const TextStyle(color: Colors.green),
                            recognizer: TapGestureRecognizer()
                              ..onTap = controller.goToSignUp,
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
