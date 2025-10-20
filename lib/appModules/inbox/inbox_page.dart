import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zero/appModules/inbox/inbox_controller.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/models/invitation_model.dart';

class InboxPage extends StatelessWidget {
  InboxPage({super.key});
  final InboxController controller = Get.isRegistered()
      ? Get.find<InboxController>()
      : Get.put(InboxController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: controller.inboxList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No new messages',
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              color: ColorConst.primaryColor,
              onRefresh: () => controller.fetchInbox(),
              child: Obx(
                () {
                  if (controller.isLoading.value) {
                    return const Center(child: CupertinoActivityIndicator());
                  }
                  return ListView.builder(
                    itemCount: controller.inboxList.length,
                    itemBuilder: (context, index) {
                      final invitation = controller.inboxList[index];
                      return invitationCard(invitation);
                    },
                  );
                },
              ),
            ),
    );
  }

  Widget invitationCard(InvitationModel invitation) {
    switch (invitation.status) {
      case 'PENDING':
        return Card(
          margin: const EdgeInsets.all(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      child: Icon(
                          invitation.fleet != null
                              ? Icons.directions_car
                              : Icons.person,
                          color: Colors.grey),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(invitation.fleet!.fleetName,
                              style: Get.textTheme.bodyLarge),
                          const SizedBox(height: 4),
                          Text(
                              invitation.fleet != null
                                  ? 'Fleet invitation'
                                  : 'Join request',
                              style: Get.textTheme.bodySmall!
                                  .copyWith(color: Colors.grey)),
                        ],
                      ),
                    ),
                    Text(
                      CustomWidgets().formatTimestamp(invitation.timestamp),
                      style:
                          Get.textTheme.bodySmall!.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
                const Divider(color: Colors.white10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                        Icons.location_on, invitation.fleet!.officeAddress),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.phone, invitation.fleet!.contactNumber),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.directions_car,
                      '${invitation.fleet!.vehicles == null ? 0 : invitation.fleet!.vehicles!.length} vehicles',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Obx(
                  () => Row(
                    children: [
                      Expanded(
                        child: controller.isDeclining.value
                            ? const Center(
                                child: CupertinoActivityIndicator(),
                              )
                            : ElevatedButton.icon(
                                onPressed: () => controller.declineRequest(
                                    invitationId: invitation.id),
                                icon: const Icon(Icons.close),
                                label: const Text('Decline'),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: controller.isAccepting.value
                            ? const Center(
                                child: CupertinoActivityIndicator(),
                              )
                            : OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.green),
                                onPressed: () => controller.acceptRequest(
                                    invitationId: invitation.id,
                                    fleet: invitation.fleet!),
                                icon: const Icon(Icons.check),
                                label: const Text('Accept'),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      case 'DECLINED':
        return Card(
          margin: const EdgeInsets.all(12),
          color: Colors.red.withValues(alpha: 0.1),
          child: ListTile(
            leading: CircleAvatar(
              radius: 25,
              child: Icon(
                  invitation.fleet != null
                      ? Icons.directions_car
                      : Icons.person,
                  color: Colors.grey),
            ),
            title: Text(invitation.fleet!.fleetName),
            subtitle: Text(invitation.fleet != null
                ? 'Fleet invitation'
                : 'Driver request'),
            trailing: Text(
              'Declined',
              style: Get.textTheme.bodySmall!.copyWith(color: Colors.red),
            ),
          ),
        );
      default:
        return Card(
          color: Colors.green.withValues(alpha: 0.1),
          margin: const EdgeInsets.all(12),
          child: ListTile(
            leading: CircleAvatar(
              radius: 25,
              child: Icon(
                  invitation.fleet != null
                      ? Icons.directions_car
                      : Icons.person,
                  color: Colors.grey),
            ),
            title: Text(invitation.fleet!.fleetName),
            subtitle: Text(invitation.fleet != null
                ? 'Fleet invitation'
                : 'Driver request'),
            trailing: Text(
              'Accepted',
              style: Get.textTheme.bodySmall!.copyWith(color: Colors.green),
            ),
          ),
        );
    }
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 20),
        Expanded(
          child: Text(
            text,
            style: Get.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
