import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manager_project/controllers/widgets/const_app_bar_controller.dart';

class ConstAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ConstAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final ConstAppBarController controller = Get.put(ConstAppBarController());

    return AppBar(
      backgroundColor: Colors.green,
      title: Row(
        children: [
          GestureDetector(
            onTap: controller.onTapProfile,
            child: Obx(
              () => CircleAvatar(
                radius: 25,
                backgroundColor: Colors.white,
                child: Text(
                  controller.isLoading.value
                      ? 'U'
                      : (controller.currentUser.value?.firstName.isNotEmpty ==
                                true
                            ? controller.currentUser.value!.firstName[0]
                                  .toUpperCase()
                            : 'U'),
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.isLoading.value
                        ? 'Loading...'
                        : '${controller.currentUser.value?.firstName ?? ''} ${controller.currentUser.value?.lastName ?? ''}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    controller.isLoading.value
                        ? 'Loading...'
                        : controller.currentUser.value?.email ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: controller.onTapSignOutButton,
          icon: const Icon(Icons.logout_outlined, size: 25),
        ),
      ],
    );
  }
}
