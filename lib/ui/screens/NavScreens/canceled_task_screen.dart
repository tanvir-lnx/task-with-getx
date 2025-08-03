import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manager_project/data/models/task_model.dart';
import 'package:task_manager_project/data/services/task_service.dart';
import 'package:task_manager_project/ui/screens/main_nav_bar_holder.dart';
import 'package:task_manager_project/ui/widgets/task_card.dart';

class CanceledTaskScreenController extends GetxController {
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
      final response = await TaskService.getTasksByStatus('Canceled');

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
    if (updatedTask.status != 'Canceled') {
      tasks.removeWhere((task) => task.id == updatedTask.id);
    } else {
      // If still canceled, update or add task in the list
      final index = tasks.indexWhere((task) => task.id == updatedTask.id);
      if (index != -1) {
        tasks[index] = updatedTask;
      } else {
        tasks.add(updatedTask);
      }
    }
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

class CanceledTaskScreen extends StatelessWidget {
  const CanceledTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CanceledTaskScreenController controller = Get.put(
      CanceledTaskScreenController(),
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
                          Icon(Icons.cancel, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No canceled tasks found',
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
                      chipColor: Colors.red,
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