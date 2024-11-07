import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/zone.dart';

class ImageEditorScreen extends StatefulWidget {
  final Zone zone;

  const ImageEditorScreen({Key? key, required this.zone}) : super(key: key);

  @override
  _ImageEditorScreenState createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  final ImagePicker _picker = ImagePicker();
  late String _imageUrl;
  late TransformationController _transformationController;

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.zone.imageUrl;

    // Initialize TransformationController with scale and offset values from the Zone
    _transformationController = TransformationController(
      Matrix4.identity()
        ..scale(widget.zone.scale)
        ..translate(
          widget.zone.offset.dx * widget.zone.width, // Convert percentage to actual offset
          widget.zone.offset.dy * widget.zone.height,
        ),
    );
  }

  Future<void> _pickNewImage() async {
    final XFile? newImage = await _picker.pickImage(source: ImageSource.gallery);
    if (newImage != null) {
      setState(() {
        _imageUrl = newImage.path;
        widget.zone.imageUrl = _imageUrl; // Update the zone's image URL
      });
    }
  }

  void _saveEditedImage() {
    final currentMatrix = _transformationController.value;

    // Set the scale for the zone based on current transformation
    final scale = currentMatrix.getMaxScaleOnAxis();
    widget.zone.scale = scale;

    // Get the translation (offset) and save it as a percentage relative to the zone
    var translation = currentMatrix.getTranslation();
    widget.zone.offset = Offset(
      translation.x / widget.zone.width,
      translation.y / widget.zone.height,
    );

    print("Saving scale: ${widget.zone.scale}, zone-relative offset: ${widget.zone.offset}");

    Navigator.pop(context, widget.zone); // Return the updated zone
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Image'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveEditedImage,
          ),
        ],
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: widget.zone.width / widget.zone.height,
          child: ClipRect(
            child: InteractiveViewer(
              transformationController: _transformationController,
              boundaryMargin: EdgeInsets.zero,
              minScale: 1.0,
              maxScale: 4.0,
              child: Image.file(
                File(_imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickNewImage,
        child: const Icon(Icons.photo),
        tooltip: 'Pick New Image',
      ),
    );
  }
}
