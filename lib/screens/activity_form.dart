import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_practices/cubit/activity_cubit.dart';
import 'package:flutter_bloc_practices/widegts/custom_textformfield.dart';
import 'package:flutter_bloc_practices/services/notification_service.dart'; // Add this import
import 'package:nepali_date_picker/nepali_date_picker.dart';

class ActivityForm extends StatefulWidget {
  const ActivityForm({super.key});
  @override
  State<ActivityForm> createState() => _ActivityFormState();
}

class _ActivityFormState extends State<ActivityForm> {
  final _formKey = GlobalKey<FormState>();
  bool setReminder = false;
  bool delayedEnd = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  NepaliDateTime? fromDate;
  DateTime? selectedDateTime;

  Future<void> _pickDateTime() async {
    final selectedType = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Calendar Type"),
        content: const Text("Choose which calendar you want to use:"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, "english"),
            child: const Text("English"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, "nepali"),
            child: const Text("Nepali"),
          ),
        ],
      ),
    );

    if (selectedType == null) return;

    if (selectedType == "english") {
      final pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (pickedDate == null) return;

      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime == null) return;

      final selected = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      setState(() {
        selectedDateTime = selected;
        _dateController.text =
            "${selected.day}-${selected.month}-${selected.year}  ${pickedTime.format(context)}";
      });
    } else {
      final pickedDate = await showAdaptiveDatePicker(
        context: context,
        initialDate: NepaliDateTime.now(),
        firstDate: NepaliDateTime(2000),
        lastDate: NepaliDateTime(2100),
        language: Language.nepali,
      );
      if (pickedDate == null) return;

      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime == null) return;

      final selected = NepaliDateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      selectedDateTime = selected.toDateTime();

      setState(() {
        fromDate = selected;
        _dateController.text = selected.format("MMMM d, yyyy h:mm aa");
      });
    }
  }

  // FIXED: Now actually calls NotificationService
  Future<int?> _scheduleNotification(
    DateTime activityTime,
    String title,
    String description,
  ) async {
    final notificationTime = activityTime.subtract(const Duration(minutes: 10));

    // Check if notification time is in the future
    if (notificationTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Activity time is too soon for a 10-minute reminder!"),
        ),
      );
      return null;
    }

    try {
      // Generate unique ID based on timestamp
      final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(
        100000,
      );

      await NotificationService().scheduleNotification(
        id: notificationId,
        title: 'Upcoming Activity: $title',
        body: 'Your activity "$title" starts in 10 minutes!',
        eventTime: activityTime,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Reminder set for ${notificationTime.hour}:${notificationTime.minute.toString().padLeft(2, '0')}",
          ),
        ),
      );

      return notificationId; // Return the ID
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to schedule reminder: $e")),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Add Activity"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                CustomTextformfield(
                  controller: _titleController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter activity title';
                    }
                    return null;
                  },
                  labelText: "Title",
                  hintText: "Enter Activity Name",
                ),
                CustomTextformfield(
                  controller: _descriptionController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter activity description';
                    }
                    return null;
                  },
                  labelText: "Description",
                  hintText: "Enter Description",
                  maxLines: 3,
                ),

                CustomTextformfield(
                  controller: _dateController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select date and time';
                    }
                    return null;
                  },
                  readOnly: true,
                  onTap: _pickDateTime,
                  labelText: "Date & Time",
                  hintText: "Select Date and Time",
                ),
                CustomTextformfield(
                  controller: _locationController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter location';
                    }
                    return null;
                  },
                  labelText: "Location",
                  hintText: "Enter Location",
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Text(
                      "Set Reminder",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    _buildSwitch("", setReminder, (val) {
                      setState(() => setReminder = val);
                    }),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Text(
                      "Delayed End",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    _buildSwitch("", delayedEnd, (val) {
                      setState(() => delayedEnd = val);
                    }),
                  ],
                ),
                const SizedBox(height: 120),
                SizedBox(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 81, 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 24,
                      ),
                    ),
                    onPressed: () async {
                      // Made async
                      if (_formKey.currentState!.validate()) {
                        if (selectedDateTime == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please select date and time"),
                            ),
                          );
                          return;
                        }

                        // Schedule notification and get ID
                        int? notificationId;
                        if (setReminder) {
                          notificationId = await _scheduleNotification(
                            selectedDateTime!,
                            _titleController.text,
                            _descriptionController.text,
                          );
                        }

                        // FIXED: Store DateTime and notification ID in activity
                        final newActivity = {
                          'title': _titleController.text,
                          'date': _dateController.text,
                          'description': _descriptionController.text,
                          'location': _locationController.text,
                          'dateTime': selectedDateTime, // Store actual DateTime
                          'hasReminder': setReminder,
                          'notificationId':
                              notificationId, // Store notification ID
                        };

                        // Add activity to cubit
                        context.read<ActivityCubit>().addActivity(newActivity);

                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      "Add Activity",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitch(String title, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color.fromARGB(255, 255, 81, 0),
        ),
      ],
    );
  }
}
