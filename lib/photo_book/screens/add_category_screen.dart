import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heritage/photo_book/models/category.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddCategoryScreen extends StatelessWidget {
  const AddCategoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Category'),
      ),
      body: const AddCategoryForm(),
    );
  }
}

class AddCategoryForm extends StatefulWidget {
  const AddCategoryForm({super.key});

  @override
  AddCategoryFormState createState() => AddCategoryFormState();
}

class AddCategoryFormState extends State<AddCategoryForm> {
  String categoryName = '';
  File? _imageFile;
  Image? _imagePreview;
  String? categoryError;
  String? imageError;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Material(
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (_imagePreview != null) _buildImageThumbnail(),

              TextField(
                onChanged: (value) {
                  setState(() {
                    categoryName = value;
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
                onPressed: () => _addCategory(context),
                child: const Text('Add'),
              ),
            ],
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

  @override
  void initState() {
    super.initState();
    _imagePreview = Image.asset('assets/logo.png'); // Replace with your default image asset path
  }

  void _addCategory(BuildContext context) async {
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

    if (_imageFile == null) {
      setState(() {
        imageError = 'Image is required';
      });
      return;
    } else {
      setState(() {
        imageError = null;
      });
    }

    // Check if category name already exists
    final querySnapshot = await FirebaseFirestore.instance
        .collection('categories')
        .where('categoryName', isEqualTo: categoryName)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        categoryError = 'Category name already exists. Please choose a different name.';
      });
      return;
    }

    Category newCategory = Category(
      id: '',
      categoryName: categoryName,
      imageUrl: '',
    );

    // Upload image to Firebase Storage
    if (_imageFile != null) {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('category_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(_imageFile!);
      String imageUrl = await ref.getDownloadURL();
      newCategory.imageUrl = imageUrl;
    }

    Map<String, dynamic> categoryData = newCategory.toMap();

    FirebaseFirestore.instance
        .collection('categories')
        .add(categoryData)
        .then((docRef) {
      // Update the ID of the newly added category
      String categoryId = docRef.id;
      FirebaseFirestore.instance
          .collection('categories')
          .doc(categoryId)
          .update({'id': categoryId});

      // Show Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Category added'))
      );

      // Navigate back to the list of categories
      Navigator.pop(context); // Assuming this pops back to the list of categories
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


