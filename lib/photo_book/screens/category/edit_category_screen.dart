import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:heritage/photo_book/models/category.dart';
import 'package:image_picker/image_picker.dart';

class EditCategoryScreen extends StatefulWidget {
  final Category category;

  const EditCategoryScreen({super.key, required this.category});

  @override
  EditCategoryScreenState createState() => EditCategoryScreenState();
}

class EditCategoryScreenState extends State<EditCategoryScreen> {
  late TextEditingController _categoryNameController;
  File? _imageFile;
  Image? _imagePreview;
  String? categoryError;
  String? imageError;

  @override
  void initState() {
    super.initState();
    _categoryNameController = TextEditingController(text: widget.category.categoryName)
      ..selection = TextSelection.fromPosition(TextPosition(offset: widget.category.categoryName.length));
    _imagePreview = widget.category.imageUrl.isNotEmpty
        ? Image.network(widget.category.imageUrl)
        : Image.asset('assets/logo.png'); // Replace with your default image asset path
  }

  @override
  void dispose() {
    _categoryNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Category'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Material(
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (_imagePreview != null) _buildImageThumbnail(),
                TextField(
                  controller: _categoryNameController,
                  onChanged: (value) {
                    setState(() {
                      categoryError = null;
                    });
                  },
                ),
                if (categoryError != null)
                  Text(
                    categoryError!,
                    style: TextStyle(color: Colors.red),
                  ),
                ElevatedButton(
                  onPressed: () => _editCategory(context),
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageThumbnail() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Card(
          child: AspectRatio(
            aspectRatio: 1.0, // Set the aspect ratio to 1:1
            child: _imagePreview!,
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: IconButton(
            onPressed: _selectImage,
            icon: const Icon(Icons.edit),
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  void _editCategory(BuildContext context) async {
    String categoryName = _categoryNameController.text;
    if (categoryName.isEmpty) {
      setState(() {
        categoryError = 'Category name is required';
      });
      return;
    } else {
      setState(() {
        categoryError = null;
      });
    }

    // Check if category name already exists
    final querySnapshot = await FirebaseFirestore.instance
        .collection('categories')
        .where('categoryName', isEqualTo: categoryName)
        .get();

    if (querySnapshot.docs.isNotEmpty && querySnapshot.docs.first.id != widget.category.id) {
      setState(() {
        categoryError = 'Category name already exists. Please choose a different name.';
      });
      return;
    }

    String? imageUrl;
    if (_imageFile != null) {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('category_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(_imageFile!);
      imageUrl = await ref.getDownloadURL();
    }

    Category updatedCategory = Category(
      id: widget.category.id,
      categoryName: categoryName,
      imageUrl: imageUrl ?? widget.category.imageUrl,
    );

    FirebaseFirestore.instance
        .collection('categories')
        .doc(widget.category.id)
        .update(updatedCategory.toMap())
        .then((_) {
      // Show Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Category updated successfully')),
      );
      Navigator.pop(context); // Navigate back to the previous screen
    });
  }

  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _imagePreview = Image.file(_imageFile!);
        imageError = null;
      });
    }
  }
}
