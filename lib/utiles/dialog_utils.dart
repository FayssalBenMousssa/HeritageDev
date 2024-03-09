import 'package:flutter/material.dart';

class DialogUtils {
  static void showCustomDialog(BuildContext context, String title, String message, IconData icon, Color color) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(color: Colors.black),
          ),
          content: SingleChildScrollView(
            child: Row(
              children: [
                Icon(
                  icon,
                  color: color,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.black),
                    maxLines: null, // Allow the text to span multiple lines
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
