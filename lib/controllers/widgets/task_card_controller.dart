// lib/controllers/widgets/task_card_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manager_project/data/models/task_model.dart';
import 'package:task_manager_project/data/services/task_service.dart';

class TaskCardController extends GetxController {
  final Task task;
  final VoidCallback? onUpdate;
  final RxBool isUpdatingStatus = false.obs;

  TaskCardController({required this.task, this.onUpdate});

  Future<void> handleStatusChange(String newStatus) async {
    if (isUpdatingStatus.value) return; // Prevent multiple simultaneous updates

    isUpdatingStatus.value = true;
    try {
      final response = await TaskService.updateTaskStatus(task.id!, newStatus);

      if (response['status'] == 'success') {
        Get.snackbar(
          'Success',
          'Task status updated to $newStatus',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        // Call the update callback
        onUpdate?.call();
      } else {
        Get.snackbar(
          'Error',
          'Failed to update task status',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Network error. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isUpdatingStatus.value = false;
    }
  }

  Future<void> deleteTask() async {
    if (isUpdatingStatus.value) {
      return; // Prevent multiple simultaneous operations
    }

    final bool? confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      isUpdatingStatus.value = true;
      try {
        final response = await TaskService.deleteTask(task.id!);
        if (response['status'] == 'success') {
          Get.snackbar(
            'Success',
            'Task deleted successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
          onUpdate?.call();
        } else {
          Get.snackbar(
            'Error',
            'Failed to delete task',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        }
      } catch (e) {
        Get.snackbar(
          'Error',
          'Network error. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } finally {
        isUpdatingStatus.value = false;
      }
    }
  }
}
