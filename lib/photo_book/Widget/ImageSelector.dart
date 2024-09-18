import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class ImageSelector extends StatefulWidget {
  final Function(String imageUrl) onImageSaved;
  final String? initialImageUrl; // Add initial image URL parameter

  const ImageSelector({Key? key, required this.onImageSaved, this.initialImageUrl}) : super(key: key);

  @override
  _ImageSelectorState createState() => _ImageSelectorState();
}

class _ImageSelectorState extends State<ImageSelector> {
  File? _imageFile;
  Image? _imagePreview;
  String? _imageError;

  @override
  void initState() {
    super.initState();

    // Load the initial image if available, otherwise show a default image
    if (widget.initialImageUrl != null && widget.initialImageUrl!.isNotEmpty) {
      _imagePreview = Image.network(widget.initialImageUrl!);
    } else {
      _imagePreview = Image.asset('assets/logo.png'); // Default asset
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_imagePreview != null) _buildImageThumbnail(),
        if (_imageError != null)
          Text(
            _imageError!,
            style: TextStyle(color: Colors.red),
          ),
        ElevatedButton(
          onPressed: _selectImage,
          child: const Text('Select Image'),
        ),
        if (_imageFile != null)
          ElevatedButton(
            onPressed: _saveImage,
            child: const Text('Save Image'),
          ),
      ],
    );
  }

  Widget _buildImageThumbnail() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Card(
          child: AspectRatio(
            aspectRatio: 1.0, // Keep the aspect ratio square
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

  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _imagePreview = Image.file(_imageFile!);
        _imageError = null;
      });
    } else {
      setState(() {
        _imageError = 'No image selected';
      });
    }
  }

  Future<void> _saveImage() async {
    if (_imageFile == null) {
      setState(() {
        _imageError = 'Please select an image first';
      });
      return;
    }

    try {
      // Upload the image to Firebase Storage
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('uploaded_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      // Use SettableMetadata to provide metadata
      firebase_storage.SettableMetadata metadata = firebase_storage.SettableMetadata(
        contentType: 'image/jpeg', // Set the correct content type
        customMetadata: {'example': 'metadata'}, // Optional metadata
      );

      await ref.putFile(_imageFile!, metadata);

      // Get the download URL of the uploaded image
      String downloadUrl = await ref.getDownloadURL();

      // Call the callback to pass the image URL back to the parent widget
      widget.onImageSaved(downloadUrl);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image uploaded successfully')),
      );
    } catch (e) {
      setState(() {
        _imageError = 'Failed to upload image: $e';
      });
    }
  }
}


