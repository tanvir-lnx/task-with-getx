import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manager_project/data/models/task_model.dart';
import 'package:task_manager_project/data/services/task_service.dart';
import 'package:task_manager_project/ui/screens/main_nav_bar_holder.dart';
import 'package:task_manager_project/ui/widgets/task_card.dart';

class NewTaskNavScreenController extends GetxController {
  final RxList<Task> tasks = <Task>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  Future<void> loadTasks() async {
    isLoading.value = true;

    try {
      final response = await TaskService.getTasksByStatus('New');

      if (response['status'] == 'success' && response['data'] != null) {
        final List<dynamic> data = response['data'];
        tasks.value = data.map((item) => Task.fromJson(item)).toList();
      } else {
        tasks.value = [];
        Get.snackbar(
          'Error',
          'Failed to load tasks.',
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
      tasks.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  void onTaskUpdate(Task updatedTask) {
    loadTasks(); 
    _refreshMainNavCounts();
  }

  void onTaskUpdateCallback() {
    loadTasks();
    _refreshMainNavCounts();
  }

  void _refreshMainNavCounts() {
    try {
      Get.find<MainNavBarHolderController>().loadTaskCounts();
    } catch (_) {
    }
  }
}

class NewTaskNavScreen extends StatelessWidget {
  const NewTaskNavScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      NewTaskNavScreenController(),
      permanent: true,
    );

    return Scaffold(
      body: Obx(
        () => RefreshIndicator(
          onRefresh: controller.loadTasks,
          child: controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : controller.tasks.isEmpty
              ? ListView(
                  children: const [
                    SizedBox(height: 200),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.task_alt, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No new tasks found',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  itemCount: controller.tasks.length,
                  itemBuilder: (context, index) {
                    return TaskCard(
                      task: controller.tasks[index],
                      chipColor: Colors.blue,
                      onUpdate: controller.onTaskUpdate, 
                      onUpdateCallback: controller.onTaskUpdateCallback,
                    );
                  },
                ),
        ),
      ),
    );
  }
}