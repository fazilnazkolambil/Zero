import 'package:flutter/material.dart';

enum UserRole {
  driver,
  admin,
}

class WelcomePage extends StatelessWidget {
  final UserRole userRole;
  final String userName;
  final Map<String, dynamic> userData;

  const WelcomePage({
    Key? key,
    required this.userRole,
    required this.userName,
    required this.userData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: userRole == UserRole.driver
                  ? _buildDriverContent(context)
                  : _buildAdminContent(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: userRole == UserRole.driver ? Colors.blue : Colors.indigo,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white.withOpacity(0.9),
                child: Icon(
                  userRole == UserRole.driver
                      ? Icons.directions_car
                      : Icons.admin_panel_settings,
                  color:
                      userRole == UserRole.driver ? Colors.blue : Colors.indigo,
                  size: 30,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      userRole == UserRole.driver ? 'Driver' : 'Administrator',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white),
                onPressed: () {
                  // Handle notifications
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (userRole == UserRole.driver) _buildDriverHeaderStats(),
          if (userRole == UserRole.admin) _buildAdminHeaderStats(),
        ],
      ),
    );
  }

  Widget _buildDriverHeaderStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatCard(
            'Today\'s Trips', '${userData['todayTrips'] ?? 0}', Icons.route),
        _buildStatCard(
            'Today\'s Earnings',
            '\$${userData['todayEarnings']?.toStringAsFixed(2) ?? '0.00'}',
            Icons.attach_money),
        _buildStatCard('Rating',
            '${userData['rating']?.toStringAsFixed(1) ?? '0.0'}', Icons.star),
      ],
    );
  }

  Widget _buildAdminHeaderStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatCard('Active Drivers', '${userData['activeDrivers'] ?? 0}',
            Icons.people),
        _buildStatCard(
            'Today\'s Revenue',
            '\$${userData['todayRevenue']?.toStringAsFixed(2) ?? '0.00'}',
            Icons.attach_money),
        _buildStatCard(
            'Open Issues', '${userData['openIssues'] ?? 0}', Icons.warning),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Quick Actions'),
          const SizedBox(height: 10),
          _buildDriverQuickActions(context),
          const SizedBox(height: 25),
          _buildSectionTitle('Your Stats'),
          const SizedBox(height: 10),
          _buildDriverStats(),
          const SizedBox(height: 25),
          _buildSectionTitle('Recent Activity'),
          const SizedBox(height: 10),
          _buildDriverRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildDriverQuickActions(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      childAspectRatio: 1.1,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      children: [
        _buildActionCard('Start Shift', Icons.play_circle, Colors.green, () {
          // Handle start shift
        }),
        _buildActionCard('End Shift', Icons.stop_circle, Colors.red, () {
          // Handle end shift
        }),
        _buildActionCard('My Profile', Icons.person, Colors.blue, () {
          // Navigate to profile
        }),
        _buildActionCard('Earnings', Icons.account_balance_wallet, Colors.amber,
            () {
          // Navigate to earnings
        }),
        _buildActionCard('Support', Icons.headset_mic, Colors.purple, () {
          // Navigate to support
        }),
        _buildActionCard('Settings', Icons.settings, Colors.grey, () {
          // Navigate to settings
        }),
      ],
    );
  }

  Widget _buildDriverStats() {
    final trips = userData['totalTrips'] ?? 0;
    final targetTrips = userData['targetTrips'] ?? 100;
    final tripCompletion = trips / (targetTrips > 0 ? targetTrips : 1);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDriverStatItem('Total Trips', trips.toString()),
                _buildDriverStatItem(
                    'Total Shifts', (userData['totalShifts'] ?? 0).toString()),
                _buildDriverStatItem('Total Earnings',
                    '\$${(userData['totalEarnings'] ?? 0).toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 15),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Trip Completion',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: tripCompletion > 1 ? 1 : tripCompletion,
                minHeight: 15,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  tripCompletion >= 1 ? Colors.green : Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${trips.toString()} / ${targetTrips.toString()} trips',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDriverRecentActivity() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3, // Show last 3 activities
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: const Icon(Icons.directions_car, color: Colors.blue),
            ),
            title: Text('Trip #${12345 - index}'),
            subtitle: Text(
                '${DateTime.now().subtract(Duration(hours: index * 5)).toString().substring(0, 16)} • \$${(25.50 - index * 3.25).toStringAsFixed(2)}'),
            trailing: Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.grey.shade500),
            onTap: () {
              // Navigate to trip details
            },
          );
        },
      ),
    );
  }

  Widget _buildAdminContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Dashboard'),
          const SizedBox(height: 10),
          _buildAdminDashboardCards(),
          const SizedBox(height: 25),
          _buildSectionTitle('Quick Access'),
          const SizedBox(height: 10),
          _buildAdminQuickAccess(context),
          const SizedBox(height: 25),
          _buildSectionTitle('Recent Issues'),
          const SizedBox(height: 10),
          _buildAdminRecentIssues(),
        ],
      ),
    );
  }

  Widget _buildAdminDashboardCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildAdminDashboardCard(
                'Active Drivers',
                '${userData['activeDrivers'] ?? 0}',
                Icons.people,
                Colors.blue,
                '${userData['totalDrivers'] ?? 0} total',
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildAdminDashboardCard(
                'Today\'s Trips',
                '${userData['todayTrips'] ?? 0}',
                Icons.route,
                Colors.green,
                '${userData['completionRate'] ?? 0}% completion',
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildAdminDashboardCard(
                'Revenue',
                '\$${userData['todayRevenue']?.toStringAsFixed(2) ?? '0.00'}',
                Icons.attach_money,
                Colors.amber,
                'Today',
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildAdminDashboardCard(
                'Issues',
                '${userData['openIssues'] ?? 0}',
                Icons.warning,
                userData['openIssues'] > 3 ? Colors.red : Colors.orange,
                '${userData['resolvedIssues'] ?? 0} resolved',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdminDashboardCard(
      String title, String value, IconData icon, Color color, String subtitle) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminQuickAccess(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      childAspectRatio: 1.1,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      children: [
        _buildActionCard('Drivers', Icons.people, Colors.indigo, () {
          // Navigate to drivers list
        }),
        _buildActionCard('Trips', Icons.map, Colors.green, () {
          // Navigate to trips
        }),
        _buildActionCard('Revenue', Icons.insert_chart, Colors.amber, () {
          // Navigate to revenue reports
        }),
        _buildActionCard('Issues', Icons.support_agent, Colors.red, () {
          // Navigate to issues
        }),
        _buildActionCard('Vehicles', Icons.directions_car, Colors.blue, () {
          // Navigate to vehicles
        }),
        _buildActionCard('Settings', Icons.settings, Colors.grey, () {
          // Navigate to settings
        }),
      ],
    );
  }

  Widget _buildActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminRecentIssues() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3, // Show last 3 issues
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      index == 0 ? Colors.red.shade100 : Colors.orange.shade100,
                  child: Icon(
                    index == 0 ? Icons.priority_high : Icons.warning,
                    color: index == 0 ? Colors.red : Colors.orange,
                  ),
                ),
                title: Text(
                  index == 0
                      ? 'Vehicle Breakdown'
                      : index == 1
                          ? 'Payment Issue'
                          : 'App Technical Problem',
                ),
                subtitle: Text(
                  'Driver ID: DRV-${10042 + index} • ${DateTime.now().subtract(Duration(hours: index * 3)).toString().substring(0, 16)}',
                ),
                trailing: Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.grey.shade500),
                onTap: () {
                  // Navigate to issue details
                },
              );
            },
          ),
          InkWell(
            onTap: () {
              // Navigate to all issues
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: Text(
                'View All Issues',
                style: TextStyle(
                  color: Colors.indigo.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

// Example usage
class WelcomePageExample extends StatelessWidget {
  const WelcomePageExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sample driver data
    final driverData = {
      'totalTrips': 128,
      'targetTrips': 150,
      'totalEarnings': 1250.50,
      'totalShifts': 42,
      'todayTrips': 5,
      'todayEarnings': 85.75,
      'rating': 4.8,
    };

    // Sample admin data
    final adminData = {
      'activeDrivers': 42,
      'totalDrivers': 50,
      'todayTrips': 187,
      'completionRate': 94,
      'todayRevenue': 3250.75,
      'openIssues': 4,
      'resolvedIssues': 12,
    };

    // Switch between driver and admin views
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Welcome Page Preview'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Driver View'),
              Tab(text: 'Admin View'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            WelcomePage(
              userRole: UserRole.driver,
              userName: 'John Doe',
              userData: driverData,
            ),
            WelcomePage(
              userRole: UserRole.admin,
              userName: 'Admin User',
              userData: adminData,
            ),
          ],
        ),
      ),
    );
  }
}
