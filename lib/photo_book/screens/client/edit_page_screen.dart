import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/layout.dart';
import '../../models/page.dart' as custom;
import 'layout_widget.dart';

class EditPageScreen extends StatefulWidget {
  final custom.Page page;

  const EditPageScreen({Key? key, required this.page}) : super(key: key);

  @override
  _EditPageScreenState createState() => _EditPageScreenState();
}

class _EditPageScreenState extends State<EditPageScreen> {
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
    final custom.Page page = widget.page;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Page'),
      ),
      body: Center(
        child: LayoutWidget(
          layout: page.layout!,
          backgroundUrl: page.background,
          onImageTap: (zoneIndex, layout) {
            _pickImage(zoneIndex, layout);
          },
          isEditable: true,
        ),
      ),
    );
  }
}