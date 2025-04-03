import 'package:flutter/material.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';

class DrawerPage extends StatelessWidget {
  const DrawerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: ColorConst.boxColor,
      width: w * 0.7,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: ColorConst.primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[300],
                  child: Text(
                    currentUser!.userName.toString()[0],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: ColorConst.boxColor,
                    ),
                  ),
                ),
                SizedBox(height: h * 0.01),
                Text(
                  currentUser!.userName,
                  style: TextStyle(
                    color: ColorConst.boxColor,
                    fontSize: w * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: h * 0.01),
                Row(
                  children: [
                    Icon(Icons.phone, size: 16, color: Colors.grey[700]),
                    SizedBox(width: w * 0.03),
                    Text(
                      currentUser!.mobileNumber.toString(),
                      style: TextStyle(
                        fontSize: w * 0.04,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.person_outline,
              color: ColorConst.primaryColor,
            ),
            title: const Text('Profile Info',
                style: TextStyle(color: Colors.grey)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.notifications_none_outlined,
              color: ColorConst.primaryColor,
            ),
            title: const Text('Notifications',
                style: TextStyle(color: Colors.grey)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.help_outline,
              color: ColorConst.primaryColor,
            ),
            title: const Text('Help & Support',
                style: TextStyle(color: Colors.grey)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.description_outlined,
              color: ColorConst.primaryColor,
            ),
            title: const Text('Terms & Conditions',
                style: TextStyle(color: Colors.grey)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          SizedBox(height: h * 0.2),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: ColorConst.primaryColor,
            ),
            title: const Text('Logout', style: TextStyle(color: Colors.grey)),
            // onTap: () => _logOutDialog(),
          ),
          Center(
            child: Text(
              'App Version: $version',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          )
        ],
      ),
    );
    ;
  }
}
