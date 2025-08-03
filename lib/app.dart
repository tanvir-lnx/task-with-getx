// lib/app.dart - Updated with TaskRefreshService initialization
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manager_project/data/services/task_refresh_service.dart';
import 'package:task_manager_project/ui/screens/email_validation_screen.dart';
import 'package:task_manager_project/ui/screens/main_nav_bar_holder.dart';
import 'package:task_manager_project/ui/screens/new_task_screen.dart';
import 'package:task_manager_project/ui/screens/pin_verification_screen.dart';
import 'package:task_manager_project/ui/screens/set_password_screen.dart';
import 'package:task_manager_project/ui/screens/sign_in.dart';
import 'package:task_manager_project/ui/screens/sign_up_screen.dart';
import 'package:task_manager_project/ui/screens/splash_screen.dart';
import 'package:task_manager_project/ui/screens/update_profile.dart';

class TaskManagerApplication extends StatelessWidget {
  const TaskManagerApplication({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the TaskRefreshService
    Get.put(TaskRefreshService(), permanent: true);

    return GetMaterialApp(
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
        ),
        inputDecorationTheme: InputDecorationTheme(
          fillColor: Colors.white,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          hintStyle: const TextStyle(color: Colors.grey),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            fixedSize: const Size.fromWidth(double.maxFinite),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: Colors.grey),
        ),
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const SplashScreen()),
        GetPage(name: SignIn.name, page: () => const SignIn()),
        GetPage(name: SignUpScreen.name, page: () => const SignUpScreen()),
        GetPage(
          name: EmailValidationScreen.name,
          page: () => const EmailValidationScreen(),
        ),
        GetPage(
          name: PinVerificationScreen.name,
          page: () => const PinVerificationScreen(),
        ),
        GetPage(
          name: SetPasswordScreen.name,
          page: () => const SetPasswordScreen(),
        ),
        GetPage(
          name: MainNavBarHolder.name,
          page: () => const MainNavBarHolder(),
        ),
        GetPage(name: NewTaskScreen.name, page: () => const NewTaskScreen()),
        GetPage(name: UpdateProfile.name, page: () => const UpdateProfile()),
      ],
    );
  }
}
