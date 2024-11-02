import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CustomImagePicker extends StatefulWidget {
  final int maxImages;
  final Function(List<String>) onImagesSelected;

  const CustomImagePicker({
    Key? key,
    required this.maxImages,
    required this.onImagesSelected,
  }) : super(key: key);

  @override
  _CustomImagePickerState createState() => _CustomImagePickerState();
}

class _CustomImagePickerState extends State<CustomImagePicker> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  List<XFile>? _galleryImages;

  @override
  void initState() {
    super.initState();
    _fetchGalleryImages();
  }

  Future<void> _fetchGalleryImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    setState(() {
      _galleryImages = images;
    });
  }

  void _toggleSelection(XFile image) {
    setState(() {
      if (_selectedImages.contains(image)) {
        _selectedImages.remove(image);
      } else if (_selectedImages.length < widget.maxImages) {
        _selectedImages.add(image);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Images'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: () {
              List<String> selectedPaths = _selectedImages.map((e) => e.path).toList();
              widget.onImagesSelected(selectedPaths);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: _galleryImages == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Select up to ${widget.maxImages} images',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1,
              ),
              itemCount: _galleryImages!.length,
              itemBuilder: (context, index) {
                final image = _galleryImages![index];
                final isSelected = _selectedImages.contains(image);
                return GestureDetector(
                  onTap: () => _toggleSelection(image),
                  child: GridTile(
                    child: Stack(
                      children: [
                        Image.file(
                          File(image.path),
                          fit: BoxFit.cover,
                        ),
                        if (isSelected)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              color: Colors.black54,
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
