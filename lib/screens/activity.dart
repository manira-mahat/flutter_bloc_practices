import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/activity_cubit.dart';
import '../cubit/activity_state.dart';
import 'activity_form.dart';

class Activity extends StatelessWidget {
  const Activity({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF5100),
        title: const Text(
          "Wedding Day Activities",
          style: TextStyle(
            color: Colors.white ,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications,
              size: 30,
              color: Colors.white,
            ),
            onPressed: () {
              _showNotificationsSheet(context);
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF5100),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<ActivityCubit>(),
                child: const ActivityForm(),
              ),
            ),
          );
        },
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),

      body: BlocBuilder<ActivityCubit, ActivityState>(
        builder: (context, state) {
          if (state.activities.isEmpty) {
            return const Center(
              child: Text(
                "No activities yet.\nAdd some!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFFF5100),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.activities.length,
            itemBuilder: (context, index) {
              final activity = state.activities[index];
              final isLast = index == state.activities.length - 1;

              return buildActivityItem(activity, isLast);
            },
          );
        },
      ),
    );
  }

  Widget buildActivityItem(Map<String, dynamic> activity, bool isLast) {
    // Changed from String to dynamic
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.orange,
              size: 26,
            ),
            if (!isLast)
              Container(height: 50, width: 1, color: Color(0xFFFF5100)),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        activity['title'] ?? "",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    // Show reminder icon if enabled
                    if (activity['hasReminder'] == true)
                      const Icon(
                        Icons.notifications_active,
                        color: Colors.orange,
                        size: 20,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      activity['date'] ?? "",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                if (activity['location']?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          activity['location'] ?? "",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  activity['description'] ?? "",
                  style: const TextStyle(color: Colors.black87),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showNotificationsSheet(BuildContext context) {
    // Check and mark notifications that should have triggered based on time
    _checkAndMarkTriggeredNotifications(context);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Notifications",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  // Notification list
                  Expanded(
                    child: BlocBuilder<ActivityCubit, ActivityState>(
                      builder: (context, state) {
                        // Filter activities that have triggered notifications
                        final notificationItems = state.activities
                            .where((activity) => 
                                activity['hasReminder'] == true && 
                                activity['notificationId'] != null &&
                                state.triggeredNotifications.contains(activity['notificationId']))
                            .toList();

                        if (notificationItems.isEmpty) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.notifications_none,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  "No notifications yet",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          controller: controller,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: notificationItems.length,
                          itemBuilder: (context, index) {
                            final activity = notificationItems[index];
                            return _buildNotificationItem(activity);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> activity) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFFF5100),
          child: const Icon(
            Icons.notifications_active,
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          activity['title'] ?? "",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  activity['date'] ?? "",
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            if (activity['location']?.isNotEmpty ?? false) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      activity['location'] ?? "",
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: const Icon(
          Icons.circle,
          size: 12,
          color: Color(0xFFFF5100),
        ),
      ),
    );
  }

  // Check which notifications should have triggered based on their scheduled time
  void _checkAndMarkTriggeredNotifications(BuildContext context) {
    final cubit = context.read<ActivityCubit>();
    final state = cubit.state;
    final now = DateTime.now();

    for (var activity in state.activities) {
      if (activity['hasReminder'] == true && 
          activity['notificationId'] != null &&
          activity['dateTime'] != null) {
        
        // Calculate notification time (10 minutes before event)
        final eventTime = activity['dateTime'] as DateTime;
        final notificationTime = eventTime.subtract(const Duration(minutes: 10));
        
        // If notification time has passed, mark it as triggered
        if (notificationTime.isBefore(now) && 
            !state.triggeredNotifications.contains(activity['notificationId'])) {
          cubit.markNotificationTriggered(activity['notificationId']);
        }
      }
    }
  }
}
