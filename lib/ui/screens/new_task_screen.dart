// lib/ui/screens/new_task_screen.dart - Corrected version
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manager_project/data/models/task_model.dart';
import 'package:task_manager_project/data/services/task_service.dart';
import 'package:task_manager_project/data/services/task_refresh_service.dart';
import 'package:task_manager_project/ui/widgets/const_app_bar.dart';

class NewTaskScreenController extends GetxController {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final RxBool isLoading = false.obs;

  Future<void> onTapAddTaskButton() async {
    if (formKey.currentState!.validate()) {
      FocusManager.instance.primaryFocus?.unfocus();

      isLoading.value = true;

      try {
        final task = Task(
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
          status: 'New',
        );

        final response = await TaskService.createTask(task);

        if (response['status'] == 'success') {
          Get.snackbar(
            'Success',
            'Task created successfully!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          titleController.clear();
          descriptionController.clear();

          try {
            if (Get.isRegistered<TaskRefreshService>()) {
              await TaskRefreshService.to.refreshAllTasks();
            }
          } catch (e) {
            debugPrint('Refresh error: $e');
          }

          // Wait a moment for the UI to update and then navigate back
          await Future.delayed(const Duration(milliseconds: 300));
          Get.back(result: true);
        } else {
          Get.snackbar(
            'Error',
            response['message'] ?? 'Failed to create task',
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
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}

class NewTaskScreen extends StatelessWidget {
  const NewTaskScreen({super.key});

  static const String name = '/newTaskScreen';

  @override
  Widget build(BuildContext context) {
    final NewTaskScreenController controller = Get.put(
      NewTaskScreenController(),
    );

    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: ConstAppBar(),
      ),
      body: Center(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Form(
              key: controller.formKey,
              child: Padding(
                padding: const EdgeInsets.all(48.0),
                child: Column(
                  children: [
                    Text(
                      'Add New Task',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: controller.titleController,
                      decoration: const InputDecoration(hintText: 'Subject'),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Subject is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: controller.descriptionController,
                      maxLines: 7,
                      decoration: const InputDecoration(
                        hintText: 'Description',
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Description is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Obx(
                      () => ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.onTapAddTaskButton,
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
    );
  }
}
