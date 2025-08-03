import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manager_project/data/models/task_model.dart';
import 'package:task_manager_project/data/services/task_service.dart';
import 'package:task_manager_project/ui/screens/NavScreens/canceled_task_screen.dart';
import 'package:task_manager_project/ui/screens/NavScreens/completed_task_screen.dart';
import 'package:task_manager_project/ui/screens/NavScreens/in_progress_task_screen.dart';
import 'package:task_manager_project/ui/screens/NavScreens/new_task_nav_screen.dart';
import 'package:task_manager_project/ui/screens/new_task_screen.dart';
import 'package:task_manager_project/ui/widgets/const_app_bar.dart';

class MainNavBarHolderController extends GetxController {
  final RxInt selectedIndex = 0.obs;
  final RxList<TaskStatusCount> taskCounts = <TaskStatusCount>[].obs;
  final RxBool isLoadingCounts = true.obs;

  late List<Widget> navScreens;

  @override
  void onInit() {
    super.onInit();
    _initializeScreens();
    ever(selectedIndex, (_) => _refreshCurrentScreen());
  }

  @override
  void onReady() {
    super.onReady();
    loadTaskCounts();
  }

  void _initializeScreens() {
    navScreens = [
      const NewTaskNavScreen(),
      const CompletedTaskScreen(),
      const CanceledTaskScreen(),
      const InProgressTaskScreen(),
    ];
  }

  void _refreshCurrentScreen() {
    try {
      switch (selectedIndex.value) {
        case 0:
          Get.find<NewTaskNavScreenController>().loadTasks();
          break;
        case 1:
          Get.find<CompletedTaskScreenController>().loadTasks();
          break;
        case 2:
          Get.find<CanceledTaskScreenController>().loadTasks();
          break;
        case 3:
          Get.find<InProgressTaskScreenController>().loadTasks();
          break;
      }
    } catch (e) {
      debugPrint('Controller not found: $e');
    }
  }

  Future<void> loadTaskCounts() async {
    try {
      final response = await TaskService.getTaskStatusCount();

      if (response['status'] == 'success' && response['data'] != null) {
        final List<dynamic> data = response['data'];
        taskCounts.value = data
            .map((item) => TaskStatusCount.fromJson(item))
            .toList();
      } else {
        taskCounts.value = [];
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load task counts: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      taskCounts.value = [];
    } finally {
      isLoadingCounts.value = false;
    }
  }

  int getCountForStatus(String status) {
    final count = taskCounts.firstWhere(
      (element) => element.status == status,
      orElse: () => TaskStatusCount(status: status, count: 0),
    );
    return count.count;
  }

  void onFloatingActionButtonPressed() async {
    final result = await Get.toNamed(NewTaskScreen.name);
    if (result == true) {
      await loadTaskCounts();

      await refreshAllScreens();

      if (selectedIndex.value != 0) {
        selectedIndex.value = 0;
      }
    }
  }

  Future<void> refreshAllScreens() async {
    try {
      if (Get.isRegistered<NewTaskNavScreenController>()) {
        await Get.find<NewTaskNavScreenController>().loadTasks();
      }

      if (Get.isRegistered<CompletedTaskScreenController>()) {
        await Get.find<CompletedTaskScreenController>().loadTasks();
      }

      if (Get.isRegistered<CanceledTaskScreenController>()) {
        await Get.find<CanceledTaskScreenController>().loadTasks();
      }

      if (Get.isRegistered<InProgressTaskScreenController>()) {
        await Get.find<InProgressTaskScreenController>().loadTasks();
      }
    } catch (e) {
      debugPrint('Error refreshing screens: $e');
    }
  }

  void onBottomNavBarTap(int index) {
    selectedIndex.value = index;
  }
}

class MainNavBarHolder extends StatelessWidget {
  const MainNavBarHolder({super.key});
  static const String name = '/main-na-bar-holder';

  @override
  Widget build(BuildContext context) {
    final MainNavBarHolderController controller = Get.put(
      MainNavBarHolderController(),
      permanent: true,
    );

    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: ConstAppBar(),
      ),
      body: Obx(
        () => IndexedStack(
          index: controller.selectedIndex.value,
          children: controller.navScreens,
        ),
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: controller.selectedIndex.value,
          onTap: controller.onBottomNavBarTap,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.add_task),
              label: 'New (${controller.getCountForStatus('New')})',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.task_alt),
              label: 'Completed (${controller.getCountForStatus('Completed')})',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.cancel),
              label: 'Canceled (${controller.getCountForStatus('Canceled')})',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.access_time),
              label: 'Progress (${controller.getCountForStatus('Progress')})',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.onFloatingActionButtonPressed,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
