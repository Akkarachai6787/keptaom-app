import 'package:flutter/material.dart';

class SnackBarWidget extends StatelessWidget {
  final bool isError;
  final String message;

  const SnackBarWidget({
    super.key,
    required this.isError,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
        children: [
          isError
              ? const Icon(Icons.error, color: Colors.red)
              : Icon(Icons.check_circle_outline, color: Colors.teal),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isError ? Colors.red : Colors.white,
              ),
            ),
          ),
        ],
    );
  }
}
