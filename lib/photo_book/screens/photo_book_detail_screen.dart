import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:heritage/photo_book/models/photo_book.dart';
import 'package:page_flip/page_flip.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PhotoBookDetailScreen extends StatefulWidget {
  final PhotoBook photoBook;

  const PhotoBookDetailScreen({Key? key, required this.photoBook}) : super(key: key);

  @override
  _PhotoBookDetailScreenState createState() => _PhotoBookDetailScreenState();
}

class _PhotoBookDetailScreenState extends State<PhotoBookDetailScreen> {
  final _controller = GlobalKey<PageFlipWidgetState>();
  File? _imageFile;
  Widget? _imagePreview;
  bool _isUploading = false; // Track the upload state

  @override
  void initState() {
    super.initState();
    _loadInitialImage();
  }

  void _loadInitialImage() {
    setState(() {
      _imagePreview = widget.photoBook.coverImageUrl.isNotEmpty
          ? CachedNetworkImage(
        imageUrl: widget.photoBook.coverImageUrl,
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      )
          : Image.asset('assets/logo.png'); // Replace with your default image asset path
    });
  }

  // Method to handle updating cover image URL
  Future<void> _updateCoverImageUrl() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _imagePreview = Image.file(_imageFile!);
        _isUploading = true; // Start uploading
      });

      if (_imageFile != null) {
        firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('photobook_cover_images')
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
        await ref.putFile(_imageFile!);
        String imageUrl = await ref.getDownloadURL();

        try {
          await FirebaseFirestore.instance
              .collection('photoBooks')
              .doc(widget.photoBook.id)
              .update({'coverImageUrl': imageUrl});

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cover image updated successfully')),
          );

          setState(() {
            _imagePreview = CachedNetworkImage(
              imageUrl: imageUrl,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            );
            _isUploading = false; // End uploading
          });
        } catch (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update Firestore: $error')),
          );
          setState(() {
            _isUploading = false; // End uploading in case of error
          });
        }
      }
    }
  }

  Widget _buildCoverImagePage() {
    return SizedBox.expand(
      child: _imagePreview,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.photoBook.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_imagePreview != null) _buildImageThumbnail(),
            Padding(
              padding: const EdgeInsets.all(16.0),
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
                  const SizedBox(height: 16), // Add spacing between Printing Time and button
                ],
              ),
            ),
            Container(
              height: 300,
              margin: const EdgeInsets.all(15.0),
              padding: const EdgeInsets.all(3.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent),
              ),
              child: PageFlipWidget(
                key: _controller,
                backgroundColor: Colors.white,
                lastPage: Container(
                  color: Colors.white,
                  child: const Center(child: Text('Last Page!')),
                ),
                children: <Widget>[
                  _buildCoverImagePage(),
                  for (var i = 0; i < 10; i++) DemoPage(page: i),
                ],
              ),
            ),
          ],
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
        if (_isUploading) // Show CircularProgressIndicator if uploading
          const Positioned.fill(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        Positioned(
          top: 10,
          right: 10,
          child: IconButton(
            onPressed: _updateCoverImageUrl,
            icon: const Icon(Icons.edit),
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}

class DemoPage extends StatelessWidget {
  final int page;
  final Random _random = Random();

  DemoPage({Key? key, required this.page}) : super(key: key);

  Color _getRandomColor() {
    return Color.fromARGB(
      255,
      _random.nextInt(256),
      _random.nextInt(256),
      _random.nextInt(256),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 250,
                  height: 110,
                  color: _getRandomColor(),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 250,
                  height: 110,
                  color: _getRandomColor(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Page $page',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
