import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zero/core/global_variables.dart';

class AppColors {
  static const backgroundColor = Color(0xFF1E1E1E);
  static const primaryColor = Color(0xFFFFD700);
  static const textColor = Colors.white;
  static const cardColor = Color(0xFF2A2A2A);
  static const dividerColor = Color(0xFF3A3A3A);
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // final user = FirebaseAuth.instance.currentUser;
  bool _notificationsEnabled = true;
  bool _darkMode = true;
  String _selectedLanguage = 'English';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _darkMode = prefs.getBool('dark_mode') ?? true;
      _selectedLanguage = prefs.getString('language') ?? 'English';
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('dark_mode', _darkMode);
    await prefs.setString('language', _selectedLanguage);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate to login page - You'll need to implement this based on your routing setup
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Settings',
            style: TextStyle(
                color: AppColors.textColor, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Section
                  _buildProfileSection(),

                  const SizedBox(height: 24),

                  // App Settings
                  _buildSectionHeader('App Settings'),
                  _buildSettingsCard([
                    _buildSwitchTile(
                      'Dark Mode',
                      'Use dark theme throughout the app',
                      Icons.dark_mode,
                      _darkMode,
                      (value) {
                        setState(() {
                          _darkMode = value;
                        });
                      },
                    ),
                    const Divider(color: AppColors.dividerColor, height: 1),
                    _buildSwitchTile(
                      'Notifications',
                      'Receive alerts about rentals and updates',
                      Icons.notifications,
                      _notificationsEnabled,
                      (value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                      },
                    ),
                    const Divider(color: AppColors.dividerColor, height: 1),
                    _buildDropdownTile(
                      'Language',
                      'Select your preferred language',
                      Icons.language,
                      _selectedLanguage,
                      ['English', 'Spanish', 'French', 'German'],
                      (value) {
                        setState(() {
                          _selectedLanguage = value!;
                        });
                      },
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Account Settings
                  _buildSectionHeader('Account'),
                  _buildSettingsCard([
                    _buildListTile(
                      'Change Password',
                      'Update your login credentials',
                      Icons.lock,
                      () {
                        // Navigate to change password screen
                      },
                    ),
                    const Divider(color: AppColors.dividerColor, height: 1),
                    _buildListTile(
                      'Driver Information',
                      'Update your personal and vehicle details',
                      Icons.person,
                      () {
                        // Navigate to profile edit screen
                      },
                    ),
                    const Divider(color: AppColors.dividerColor, height: 1),
                    _buildListTile(
                      'Payment Information',
                      'Manage your payment methods',
                      Icons.payment,
                      () {
                        // Navigate to payment methods screen
                      },
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Support & About
                  _buildSectionHeader('Support & About'),
                  _buildSettingsCard([
                    _buildListTile(
                      'Help Center',
                      'Get support and view FAQs',
                      Icons.help,
                      () {
                        // Navigate to help center
                      },
                    ),
                    const Divider(color: AppColors.dividerColor, height: 1),
                    _buildListTile(
                      'Terms of Service',
                      'View our terms and conditions',
                      Icons.description,
                      () {
                        // Show terms of service
                      },
                    ),
                    const Divider(color: AppColors.dividerColor, height: 1),
                    _buildListTile(
                      'Privacy Policy',
                      'Learn how we handle your data',
                      Icons.privacy_tip,
                      () {
                        // Show privacy policy
                      },
                    ),
                    const Divider(color: AppColors.dividerColor, height: 1),
                    _buildListTile(
                      'App Version',
                      '1.0.0',
                      Icons.info,
                      null,
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: AppColors.backgroundColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'SAVE SETTINGS',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: _signOut,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryColor),
                        foregroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'LOG OUT',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.primaryColor.withOpacity(0.5), width: 1),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.primaryColor,
            child: Text(
              currentUser!.userName.isNotEmpty
                  ? currentUser!.userName.substring(0, 1).toUpperCase()
                  : 'A',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.backgroundColor,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentUser!.userName ?? 'www',
                  style: const TextStyle(
                    color: AppColors.textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // const SizedBox(height: 4),
                // Text(
                //   user?.email ?? 'No email',
                //   style: TextStyle(
                //     color: AppColors.textColor.withOpacity(0.7),
                //     fontSize: 14,
                //   ),
                // ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Driver',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primaryColor),
            onPressed: () {
              // Navigate to profile edit
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.primaryColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      color: AppColors.cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildListTile(
      String title, String subtitle, IconData icon, Function()? onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryColor),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppColors.textColor.withOpacity(0.7),
          fontSize: 12,
        ),
      ),
      trailing: onTap != null
          ? const Icon(Icons.chevron_right, color: AppColors.primaryColor)
          : null,
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, IconData icon,
      bool value, Function(bool) onChanged) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppColors.primaryColor),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppColors.textColor.withOpacity(0.7),
          fontSize: 12,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primaryColor,
      inactiveThumbColor: Colors.grey,
    );
  }

  Widget _buildDropdownTile(String title, String subtitle, IconData icon,
      String value, List<String> options, Function(String?) onChanged) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryColor),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppColors.textColor.withOpacity(0.7),
          fontSize: 12,
        ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        dropdownColor: AppColors.cardColor,
        style: const TextStyle(color: AppColors.primaryColor),
        icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryColor),
        underline: Container(
          height: 2,
          color: AppColors.primaryColor,
        ),
        items: options.map<DropdownMenuItem<String>>((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
      ),
    );
  }
}
