import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:page_flip/page_flip.dart';

import '../models/photo_book.dart';
import '../Widget/demo_page.dart';

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

  DateTime? dateStart;
  DateTime? dateEnd;

  Future<void> _selectDate(BuildContext context, {required bool isStartDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          dateStart = picked;
        } else {
          dateEnd = picked;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadInitialImage();
    _tabController = TabController(length: 8, vsync: this); // Updated to 8 for new tab
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
              Tab(text: 'Price'),
              Tab(text: 'Cover Image'),
              Tab(text: 'Description'),
              Tab(text: 'Size'),
              Tab(text: 'Miniature'),
              Tab(text: 'Printing Time'),
              Tab(text: 'Flip Book'),
              Tab(text: 'Cover Finish'), // New tab for Cover Finish
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPriceTab(),
          _buildCoverImageTab(),
          _buildDetailTab('Description: ${widget.photoBook.description}'),
          _buildDetailTab('Size: ${widget.photoBook.size}'),
          _buildDetailTab('Miniature: ${widget.photoBook.miniature}'),
          _buildDetailTab('Printing Time: ${widget.photoBook.printingTime} days'),
          _buildFlipBookTab(),
          _buildCoverFinishTab(), // New tab view for Cover Finish
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

  Widget _buildPriceTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView( // Add SingleChildScrollView here
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Original Value TextFormField with border
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Value',
                  border: InputBorder.none, // Remove internal border
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Value is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  // Save the value here
                },
              ),
            ),

            const SizedBox(height: 20),

            // Date pickers for start and end dates with border
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: dateStart == null
                            ? 'Select Start Date'
                            : 'Start Date: ${dateStart!.toLocal()}'.split(' ')[0],
                        border: InputBorder.none, // Remove internal border
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context, isStartDate: true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: dateEnd == null
                            ? 'Select End Date'
                            : 'End Date: ${dateEnd!.toLocal()}'.split(' ')[0],
                        border: InputBorder.none, // Remove internal border
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context, isStartDate: false),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Generate a group of TextFormField for each size in the PhotoBook
            ...widget.photoBook.size.map((size) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Size: $size',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Print all coverFinish.name and add a TextField for "cover value"
                    ...widget.photoBook.coverFinish.map((coverFinish) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cover Finish: ${coverFinish.name}',
                            style: const TextStyle(fontSize: 14.0),
                          ),
                          const SizedBox(height: 8),

                          // TextField for cover value
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Cover value for ${coverFinish.name}',
                              border: const OutlineInputBorder(), // Add border for better design
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Cover value for ${coverFinish.name} is required';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              // Save the cover value for this coverFinish.name
                            },
                          ),
                          const SizedBox(height: 10),
                        ],
                      );
                    }).toList(),

                    const SizedBox(height: 10),

                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Price for size $size',
                        border: const OutlineInputBorder(), // Add border for better design
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Price for size $size is required';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        // Save the price value for this size
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Page value for size $size',
                        border: const OutlineInputBorder(), // Add border for better design
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Page value for size $size is required';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        // Save the page value for this size
                      },
                    ),
                  ],
                ),
              );
            }).toList(),

            // ElevatedButton to validate
            ElevatedButton(
              onPressed: () {
                // Validate and save all form fields
              },
              child: const Text('Validate'),
            ),
          ],
        ),
      ),
    );
  }




  Widget _buildDetailTab(String content) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        content,
        style: const TextStyle(fontSize: 16),
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

  Widget _buildCoverFinishTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: widget.photoBook.coverFinish.length,
      itemBuilder: (context, index) {
        final coverFinish = widget.photoBook.coverFinish[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          child: ListTile(
            title: Text(coverFinish.name),
            subtitle: Text('Description: ${coverFinish.description}'),
          ),
        );
      },
    );
  }

  Widget _buildImageThumbnail() {
    return InkWell(
      onTap: _updateCoverImageUrl,
      child: Container(
        margin: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: _isUploading
            ? const CircularProgressIndicator() // Show progress indicator during upload
            : const Icon(Icons.camera_alt, size: 30), // Show camera icon
      ),
    );
  }
}
