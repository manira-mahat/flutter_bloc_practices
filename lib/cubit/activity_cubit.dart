import 'package:flutter_bloc/flutter_bloc.dart';
import 'activity_state.dart';

class ActivityCubit extends Cubit<ActivityState> {
  ActivityCubit()
    : super(
        ActivityState(
          activities: [],
          isNepali: false,
          selectedEnglishDate: DateTime.now(),
          selectedNepaliDate: "",
        ),
      );

  /// Toggle English/Nepali
  void toggleCalendar(bool value) {
    emit(state.copyWith(isNepali: value));
  }

  /// Select English Date
  void selectEnglishDate(DateTime date) {
    emit(state.copyWith(selectedEnglishDate: date));
  }

  /// Select Nepali Date (string)
  void selectNepaliDate(String nepaliDate) {
    emit(state.copyWith(selectedNepaliDate: nepaliDate));
  }

  /// Add Activity to list - Updated to accept Map with dynamic values
  void addActivity(Map<String, dynamic> activity) {
    final updated = List<Map<String, dynamic>>.from(state.activities)
      ..add(activity);

    emit(state.copyWith(activities: updated));
  }

  /// Mark a notification as triggered
  void markNotificationTriggered(int notificationId) {
    if (!state.triggeredNotifications.contains(notificationId)) {
      final updated = List<int>.from(state.triggeredNotifications)
        ..add(notificationId);
      emit(state.copyWith(triggeredNotifications: updated));
    }
  }
}
