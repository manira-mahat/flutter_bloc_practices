class ActivityState {
  final List<Map<String, dynamic>> activities; // Changed from String to dynamic
  final bool isNepali;
  final DateTime selectedEnglishDate;
  final String selectedNepaliDate;
  final List<int>
  triggeredNotifications; // Track which notifications have been triggered

  ActivityState({
    required this.activities,
    required this.isNepali,
    required this.selectedEnglishDate,
    required this.selectedNepaliDate,
    this.triggeredNotifications = const [],
  });

  ActivityState copyWith({
    List<Map<String, dynamic>>? activities,
    bool? isNepali,
    DateTime? selectedEnglishDate,
    String? selectedNepaliDate,
    List<int>? triggeredNotifications,
  }) {
    return ActivityState(
      activities: activities ?? this.activities,
      isNepali: isNepali ?? this.isNepali,
      selectedEnglishDate: selectedEnglishDate ?? this.selectedEnglishDate,
      selectedNepaliDate: selectedNepaliDate ?? this.selectedNepaliDate,
      triggeredNotifications:
          triggeredNotifications ?? this.triggeredNotifications,
    );
  }
}
