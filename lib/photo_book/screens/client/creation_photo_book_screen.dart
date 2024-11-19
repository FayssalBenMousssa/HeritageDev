import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../models/layout.dart';
import '../../models/zone.dart';
import '../../models/template.dart';
import 'layout_widget.dart';

class CreationPhotoBookScreen extends StatefulWidget {
  final Template photoBook;

  const CreationPhotoBookScreen({
    Key? key,
    required this.photoBook,
  }) : super(key: key);

  @override
  _CreationPhotoBookScreenState createState() =>
      _CreationPhotoBookScreenState();
}

class _CreationPhotoBookScreenState extends State<CreationPhotoBookScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(int zoneIndex, Layout layout) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        layout.zones[zoneIndex].imageUrl = image.path;
      });
    }
  }




  @override
  Widget build(BuildContext context) {
    final pages = widget.photoBook.pages;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.photoBook.title ?? 'Photo Book'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: pages.map((page) {
            return Padding(
              padding: const EdgeInsets.all(2.0), // Add padding around each page
              child: page.layout != null
                  ? Center( // Center the LayoutWidget horizontally
                child: LayoutWidget(
                  layout: page.layout!,
                  backgroundUrl: page.background,
                  onImageTap: _pickImage,
                ),
              )
                  : Container(
                height: 200,
                color: Colors.grey[300],
                child: const Center(
                  child: Text(
                    'No Layout Selected',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}


