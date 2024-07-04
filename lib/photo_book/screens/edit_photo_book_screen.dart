import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heritage/photo_book/models/photo_book.dart';

class EditPhotoBookScreen extends StatefulWidget {
  final PhotoBook photoBook;

  const EditPhotoBookScreen({Key? key, required this.photoBook}) : super(key: key);

  @override
  _EditPhotoBookScreenState createState() => _EditPhotoBookScreenState();
}

class _EditPhotoBookScreenState extends State<EditPhotoBookScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;


  @override
  void initState() {
    super.initState();
    _title = widget.photoBook.title;

  }

  void _updatePhotoBook() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      FirebaseFirestore.instance
          .collection('photoBooks')
          .doc(widget.photoBook.id)
          .update({
        'title': _title,

      }).then((_) {
        Navigator.pop(context);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update photo book: $error')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Photo Book'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (value) => _title = value ?? '',
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updatePhotoBook,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
