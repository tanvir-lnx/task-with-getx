// lib/data/services/task_refresh_service.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manager_project/ui/screens/main_nav_bar_holder.dart';
import 'package:task_manager_project/ui/screens/NavScreens/new_task_nav_screen.dart';
import 'package:task_manager_project/ui/screens/NavScreens/completed_task_screen.dart';
import 'package:task_manager_project/ui/screens/NavScreens/canceled_task_screen.dart';
import 'package:task_manager_project/ui/screens/NavScreens/in_progress_task_screen.dart';

class TaskRefreshService extends GetxService {
  static TaskRefreshService get to => Get.find();

  // Refresh all task-related screens and counts
  Future<void> refreshAllTasks() async {
    await Future.wait([
      _refreshMainNavCounts(),
      _refreshAllScreens(),
    ]);
  }

  // Refresh only the task counts in the main navigation
  Future<void> refreshTaskCounts() async {
    await _refreshMainNavCounts();
  }

  // Refresh a specific screen by status
  Future<void> refreshScreenByStatus(String status) async {
    try {
      switch (status.toLowerCase()) {
        case 'new':
          if (Get.isRegistered<NewTaskNavScreenController>()) {
            await Get.find<NewTaskNavScreenController>().loadTasks();
          }
          break;
        case 'completed':
          if (Get.isRegistered<CompletedTaskScreenController>()) {
            await Get.find<CompletedTaskScreenController>().loadTasks();
          }
          break;
        case 'canceled':
          if (Get.isRegistered<CanceledTaskScreenController>()) {
            await Get.find<CanceledTaskScreenController>().loadTasks();
          }
          break;
        case 'progress':
          if (Get.isRegistered<InProgressTaskScreenController>()) {
            await Get.find<InProgressTaskScreenController>().loadTasks();
          }
          break;
      }
    } catch (e) {
      debugPrint( e.toString());
    }
  }

  Future<void> _refreshMainNavCounts() async {
    try {
      if (Get.isRegistered<MainNavBarHolderController>()) {
        await Get.find<MainNavBarHolderController>().loadTaskCounts();
      }
    } catch (e) {
      debugPrint( e.toString());
    }
  }

  Future<void> _refreshAllScreens() async {
    final futures = <Future>[];

    if (Get.isRegistered<NewTaskNavScreenController>()) {
      futures.add(Get.find<NewTaskNavScreenController>().loadTasks());
    }
    
    if (Get.isRegistered<CompletedTaskScreenController>()) {
      futures.add(Get.find<CompletedTaskScreenController>().loadTasks());
    }
    
    if (Get.isRegistered<CanceledTaskScreenController>()) {
      futures.add(Get.find<CanceledTaskScreenController>().loadTasks());
    }
    
    if (Get.isRegistered<InProgressTaskScreenController>()) {
      futures.add(Get.find<InProgressTaskScreenController>().loadTasks());
    }

    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
  }
}