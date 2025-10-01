import 'package:flutter/material.dart';

class RepeatBillPicker extends StatefulWidget {
  final bool repeatEnabled;
  final String? repeatFrequency; // day, week, month, year
  final int? repeatInterval; // e.g. 1, 2, 3
  final Function(Map<String, dynamic>) onChanged;

  const RepeatBillPicker({
    super.key,
    required this.repeatEnabled,
    required this.repeatFrequency,
    required this.repeatInterval,
    required this.onChanged,
  });

  @override
  State<RepeatBillPicker> createState() => _RepeatBillPickerState();
}

class _RepeatBillPickerState extends State<RepeatBillPicker> {
  late bool enabled;
  String? frequency;
  int? interval;
  late TextEditingController numController;

  final List<String> options = ['day', 'week', 'month', 'year'];

  @override
  void initState() {
    super.initState();
    enabled = widget.repeatEnabled;
    frequency = widget.repeatFrequency ?? 'day';
    interval = widget.repeatInterval ?? 1;
    numController = TextEditingController(text: interval.toString());
  }

  @override
  void dispose() {
    numController.dispose();
    super.dispose();
  }

  Future<void> _openDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        bool tempEnabled = enabled;
        String? tempFrequency = frequency;
        int? tempInterval = interval;

        TextEditingController tempController = TextEditingController(
          text: tempInterval.toString(),
        );

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFF202020),
              title: const Text(
                'Repeat',
                style: TextStyle(color: Colors.white),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<bool>(
                      title: const Text(
                        "Don't repeat",
                        style: TextStyle(color: Colors.white),
                      ),
                      value: false,
                      groupValue: tempEnabled,
                      activeColor: Colors.white,
                      onChanged: (val) {
                        setStateDialog(() {
                          tempEnabled = false;
                        });
                      },
                    ),

                    RadioListTile<bool>(
                      title: const Text(
                        "Repeat",
                        style: TextStyle(color: Colors.white),
                      ),
                      value: true,
                      groupValue: tempEnabled,
                      activeColor: Colors.white,
                      onChanged: (val) {
                        setStateDialog(() {
                          tempEnabled = true;
                        });
                      },
                    ),

                    if (tempEnabled) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Every",
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 50,
                            child: TextField(
                              controller: tempController,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (v) {
                                setStateDialog(() {
                                  tempInterval = int.tryParse(v) ?? 1;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          DropdownButton<String>(
                            dropdownColor: const Color(0xFF292e31),
                            value: tempFrequency,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                            items: options
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              setStateDialog(() {
                                tempFrequency = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'enabled': tempEnabled,
                      'frequency': tempEnabled ? tempFrequency : 'none',
                      'interval': tempEnabled ? tempInterval : null,
                    });
                  },
                  child: const Text("Ok"),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        enabled = result['enabled'];
        frequency = result['frequency'];
        interval = result['interval'];
      });
      widget.onChanged(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _openDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF202020),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFc2c2c2), width: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.repeat_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  enabled ? 'Every $interval $frequency' : 'Non-repeat',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
