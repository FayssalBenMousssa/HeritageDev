import 'package:flutter/material.dart';
import 'package:heritage/photo_book/models/photo_book.dart'; // Adjust import as per your project structure

class AddPhotoBookScreen extends StatelessWidget {
  const AddPhotoBookScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Photo Book'),
      ),
      body: AddPhotoBookForm(),
    );
  }
}

class AddPhotoBookForm extends StatefulWidget {
  const AddPhotoBookForm({Key? key}) : super(key: key);

  @override
  _AddPhotoBookFormState createState() => _AddPhotoBookFormState();
}

class _AddPhotoBookFormState extends State<AddPhotoBookForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  // Add controllers or variables for other fields as needed

  String _coverImageUrl = ''; // Initialize with an empty string

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(labelText: 'Title'),
          ),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(labelText: 'Description'),
          ),
          // Add more fields as per your PhotoBook model

          ElevatedButton(
            onPressed: () {
              // Validate and save the form
              _savePhotoBook(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _savePhotoBook(BuildContext context) {
    // Validate form fields
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      // Show error or handle validation as needed
      return;
    }

    // Create a PhotoBook object
    PhotoBook newPhotoBook = PhotoBook(
      id: "test 001", // Example: Replace with actual logic to generate ID
      pages: [], // Example: Initialize with an empty list or as needed
      title: _titleController.text,
      form: '', // Example: Add logic to capture form type
      description: _descriptionController.text,
      type: '', // Example: Add logic to capture type
      size: '', // Example: Add logic to capture size
      paperFinish: '', // Example: Add logic to capture paper finish
      coverFinish: '', // Example: Add logic to capture cover finish
      price: 0.0, // Example: Initialize with default value
      miniature: 0.0, // Example: Initialize with default value
      printingTime: 0.0, // Example: Initialize with default value
      categories: [], // Example: Initialize with an empty list or as needed
      coverImageUrl: _coverImageUrl, // Assign cover image URL captured from previous screen
    );

    // Optionally, save newPhotoBook to Firestore or perform other operations
    // For example:
    // FirebaseFirestore.instance.collection('photoBooks').add(newPhotoBook.toMap());

    // Navigate back to previous screen or perform other navigation logic
    Navigator.pop(context);
  }
}
