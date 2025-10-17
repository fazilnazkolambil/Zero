import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zero/appModules/home/drawer_page.dart';
import 'package:zero/appModules/home/home_controller.dart';
import 'package:zero/core/global_variables.dart';

class HomeNavigationPage extends StatelessWidget {
  final HomeController controller = Get.isRegistered()
      ? Get.find<HomeController>()
      : Get.put(HomeController());
  HomeNavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;

    return Scaffold(
        drawer: controller.homePages.length > 4 ? DrawerPage() : null,
        appBar: AppBar(
          leading: controller.homePages.length > 4
              ? Builder(builder: (context) {
                  return IconButton(
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                      icon: const Icon(Icons.menu));
                })
              : null,
          title: Obx(() => Text(
              "${controller.homePages[controller.currentIndex.value]['label']}")),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.wallet))
          ],
        ),
        bottomNavigationBar: controller.homePages.length > 4
            ? null
            : Container(
                height: 65,
                width: w,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    // color: Get.theme.cardColor,
                    border: Border(top: BorderSide(color: Colors.grey[900]!))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    controller.homePages.length,
                    (index) => Obx(
                      () => _buildBottomBarItems(
                        icon: controller.homePages[index]['icon'],
                        label: controller.homePages[index]['label'],
                        isSelected: controller.currentIndex.value == index,
                        onTap: () {
                          controller.currentIndex.value = index;
                        },
                      ),
                    ),
                  ),
                )),
        body: Obx(() {
          return controller.homePages[controller.currentIndex.value]['page'];
        }));
  }

  Widget _buildBottomBarItems(
      {required bool isSelected,
      required IconData icon,
      required String label,
      required void Function() onTap}) {
    Color color = isSelected ? Colors.white : Colors.grey[600]!;
    return Expanded(
      child: InkWell(
        overlayColor: const WidgetStatePropertyAll(Colors.grey),
        borderRadius: BorderRadius.circular(25),
        onTap: onTap,
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: Get.textTheme.bodySmall!.copyWith(color: color),
            )
          ],
        ),
      ),
    );
  }
}
