import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zero/appModules/auth/auth_controller.dart';
import 'package:zero/appModules/home/home_controller.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';

class DrawerPage extends StatelessWidget {
  final HomeController controller = Get.find<HomeController>();
  DrawerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Get.theme.cardColor,
      width: MediaQuery.of(context).size.width * 0.75,
      child: ListView(
        children: [
          DrawerHeader(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Get.theme.primaryColor,
                      radius: 30,
                      child: Center(
                          child: Text(
                        currentUser!.fullName[0].toUpperCase(),
                        style: Get.textTheme.headlineSmall,
                      )),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentUser!.fullName,
                            style: Get.textTheme.bodyLarge!,
                          ),
                          Text(
                            currentUser!.email ?? '- N/A -',
                            style: Get.textTheme.bodySmall!,
                          )
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            child: ListView.builder(
              itemCount: controller.homePages.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                bool isSelected = controller.currentIndex.value == index;
                return ListTile(
                  onTap: () => controller.changeIndex(index),
                  title: Text(controller.homePages[index]['label']),
                  titleTextStyle: Get.textTheme.bodyLarge!.copyWith(
                      color: isSelected ? ColorConst.primaryColor : null,
                      fontWeight: isSelected ? FontWeight.bold : null),
                );
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => Get.dialog(
                barrierDismissible: false,
                AlertDialog(
                  title: const Text('Logout?'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('No, cancel')),
                    TextButton(
                        onPressed: () async =>
                            Get.put(AuthController()).logoutUser(),
                        child: const Text('Yes, confirm')),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}
