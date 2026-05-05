import 'package:flutter/material.dart';

class PermissionBox extends StatelessWidget {
  const PermissionBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: const [
          Icon(Icons.info, color: Colors.blue),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Permission is required to scan and connect your wearable device.",
            ),
          ),
        ],
      ),
    );
  }
}