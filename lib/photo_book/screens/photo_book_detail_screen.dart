import 'dart:io';

import 'package:flutter/material.dart';
import 'package:heritage/photo_book/models/photo_book.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';

class PhotoBookDetailScreen extends StatefulWidget {
  final PhotoBook photoBook;

  const PhotoBookDetailScreen({Key? key, required this.photoBook}) : super(key: key);

  @override
  _PhotoBookDetailScreenState createState() => _PhotoBookDetailScreenState();
}

class _PhotoBookDetailScreenState extends State<PhotoBookDetailScreen> {
  File? _coverImageFile;
  Image? _coverImagePreview;

  @override
  void initState() {
    super.initState();
    _loadCoverImage();
  }

  Future<void> _loadCoverImage() async {
    if (widget.photoBook.coverImageUrl.isNotEmpty) {
      setState(() {
        _coverImagePreview = Image.network(widget.photoBook.coverImageUrl);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.photoBook.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.photoBook.title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Description: ${widget.photoBook.description}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Size: ${widget.photoBook.size}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Price: \$${widget.photoBook.price.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Miniature: ${widget.photoBook.miniature}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Printing Time: ${widget.photoBook.printingTime} days',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              if (_coverImagePreview != null) _buildImageThumbnail(),
              ElevatedButton(
                onPressed: _selectAndSaveImage,
                child: const Text('Change and Save Cover Image'),
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
            aspectRatio: 1.0,
            child: _coverImagePreview!,
          ),
        ),
      ],
    );
  }

  Future<void> _selectAndSaveImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _coverImageFile = File(pickedFile.path);
        _coverImagePreview = Image.file(_coverImageFile!);
      });

      await _saveCoverImage();
    }
  }

  Future<void> _saveCoverImage() async {
    if (_coverImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a cover image')),
      );
      return;
    }

    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('photo_book_covers')
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

    await ref.putFile(_coverImageFile!);
    String coverImageUrl = await ref.getDownloadURL();

    // Update photo book's cover image URL in Firestore
    FirebaseFirestore.instance
        .collection('photoBooks')
        .doc(widget.photoBook.id)
        .update({'coverImageUrl': coverImageUrl})
        .then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cover image saved successfully')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save cover image: $error')),
      );
    });
  }
}
