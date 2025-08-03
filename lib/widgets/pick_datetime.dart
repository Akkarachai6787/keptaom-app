import 'package:flutter/material.dart';

class DateTimePicker {
  static Future<DateTime?> show({
    required BuildContext context,
    required DateTime initialDateTime,
  }) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDateTime,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Color(0xFF292e31),
              onPrimary: Colors.white,
              surface: const Color(0xFF202020),
              onSurface: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.white),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return null;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDateTime),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: const Color(0xFF202020),
              hourMinuteTextColor: Colors.white,
              dialHandColor: const Color(0xFF1C1F21),
              dialBackgroundColor: const Color(0xFF292e31),
              dayPeriodTextColor: Colors.white,
              entryModeIconColor: Colors.white,
            ),
            colorScheme: ColorScheme.dark(
              primary: const Color(0xFF292e31),
              onPrimary: Colors.white,
              surface: const Color(0xFF202020),
              onSurface: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.white),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null) return null;

    return DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
  }
}

class MonthYearPicker {
  static Future<Map<String, dynamic>?> show({
    required BuildContext context,
    required DateTime initialDate,
    int startYear = 2000,
    int? endYear,
  }) async {
    final now = DateTime.now();
    endYear ??= now.year;

    if (initialDate.isAfter(now)) {
      initialDate = now;
    }

    int selectedYear = initialDate.year;
    int selectedMonth = initialDate.month;

    final List<String> monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF202020),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select month and year',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${monthNames[selectedMonth - 1]} $selectedYear',
                    style: const TextStyle(color: Colors.white, fontSize: 26),
                  ),
                ],
              ),
              content: SizedBox(
                height: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DropdownButton<int>(
                      dropdownColor: const Color(0xFF292e31),
                      value: selectedMonth,
                      items: List.generate(12, (index) {
                        final month = index + 1;

                        if (selectedYear == now.year && month > now.month) {
                          return null;
                        }
                        return DropdownMenuItem(
                          value: month,
                          child: Text(
                            monthNames[index],
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).whereType<DropdownMenuItem<int>>().toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedMonth = value);
                        }
                      },
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<int>(
                      dropdownColor: const Color(0xFF292e31),
                      value: selectedYear,
                      items: List.generate(endYear! - startYear + 1, (index) {
                        final year = startYear + index;
                        if (year > now.year) return null;
                        return DropdownMenuItem(
                          value: year,
                          child: Text(
                            year.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).whereType<DropdownMenuItem<int>>().toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedYear = value;
                            if (selectedYear == now.year &&
                                selectedMonth > now.month) {
                              selectedMonth = now.month;
                            }
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop({
                      'year': selectedYear,
                      'month': selectedMonth,
                      'monthString': monthNames[selectedMonth - 1],
                    });
                  },
                  child: const Text('OK', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
