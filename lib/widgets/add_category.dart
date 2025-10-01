import 'package:flutter/material.dart';
import '../utils/color_utils.dart';

class AddCategoryDialog extends StatefulWidget {
  final List<String?> catList;
  final Function(String title, bool isIncome, String colorHex) onAdd;

  const AddCategoryDialog({super.key, required this.onAdd, required this.catList});

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  bool _isIncome = false;
  late String _colorHex;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF202020),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Add Category", style: TextStyle(color: Colors.white)),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Category Title",
                labelStyle: TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
              validator: (value) =>
                  value == null || value.isEmpty ? "Enter a title" : null,
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Type", style: TextStyle(color: Colors.white)),
                    SizedBox(height: 2),
                    Text(
                      _isIncome ? "Income" : "Expense",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
                Switch(
                  activeColor: Color(0xFF009688),
                  inactiveTrackColor: Color(0xFFBD3E35),
                  inactiveThumbColor: Color(0xFF750e21),
                  trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((
                    states,
                  ) {
                    if (states.contains(WidgetState.selected)) {
                      return null;
                    }
                    return Color(0xFFBD3E35);
                  }),
                  value: _isIncome,
                  onChanged: (val) => setState(() => _isIncome = val),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () {
            _colorHex = getRandomCategoryColorHex(_isIncome, widget.catList);

            if (_formKey.currentState!.validate()) {
              widget.onAdd(_titleController.text, _isIncome, _colorHex);
              Navigator.pop(context);
            }
          },
          child: const Text('OK', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
