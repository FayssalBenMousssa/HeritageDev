import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:page_flip/page_flip.dart';

import '../models/photo_book.dart';

class PhotoBookDetailScreen extends StatefulWidget {
  final PhotoBook photoBook;

  const PhotoBookDetailScreen({Key? key, required this.photoBook}) : super(key: key);

  @override
  _PhotoBookDetailScreenState createState() => _PhotoBookDetailScreenState();
}

class _PhotoBookDetailScreenState extends State<PhotoBookDetailScreen> with SingleTickerProviderStateMixin {
  final _controller = GlobalKey<PageFlipWidgetState>();
  File? _imageFile;
  Widget? _imagePreview;
  bool _isUploading = false; // Track the upload state
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _loadInitialImage();
    _tabController = TabController(length: 7, vsync: this); // Updated to 7 for new tab
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.photoBook.title),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: TabBar(
            controller: _tabController,
            isScrollable: true, // Allow horizontal scrolling
            tabs: const [
              Tab(text: 'Cover Image'),
              Tab(text: 'Description'),
              Tab(text: 'Size'),
              Tab(text: 'Price'),
              Tab(text: 'Miniature'),
              Tab(text: 'Printing Time'),
              Tab(text: 'Flip Book'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCoverImageTab(),
          _buildDetailTab('Description: ${widget.photoBook.description}'),
          _buildDetailTab('Size: ${widget.photoBook.size}'),
          _buildDetailTab('Price: \$${widget.photoBook.price.toStringAsFixed(2)}'),
          _buildDetailTab('Miniature: ${widget.photoBook.miniature}'),
          _buildDetailTab('Printing Time: ${widget.photoBook.printingTime} days'),
          _buildFlipBookTab(),
        ],
      ),
    );
  }

  Widget _buildCoverImageTab() {
    return Column(
      children: [
        Expanded(
          child: Center(child: _imagePreview ?? const SizedBox.shrink()),
        ),
        if (_imagePreview != null) _buildImageThumbnail(),
      ],
    );
  }

  Widget _buildDetailTab(String detail) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          detail,
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildFlipBookTab() {
    return Container(
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

        children: List.generate(
          10,
              (index) => DemoPage(page: index),
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
