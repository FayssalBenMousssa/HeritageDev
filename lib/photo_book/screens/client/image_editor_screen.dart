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
          widget.zone.offset.dx * widget.zone.width,
          widget.zone.offset.dy * widget.zone.height,
        ),
    );

    // Add a listener to track changes
    _transformationController.addListener(_onTransformationChanged);
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformationChanged);
    _transformationController.dispose();
    super.dispose();
  }

  void _onTransformationChanged() {
    final currentMatrix = _transformationController.value;
    final translation = currentMatrix.getTranslation();

    // Calculate percentage offsets
    final leftPercentage = (translation.x / widget.zone.width) * 100 ;
    final topPercentage = (translation.y / widget.zone.height) * 100 ;

    // Calculate the current scale as a percentage of the default scale (1.0)
    final scale = currentMatrix.getMaxScaleOnAxis();

    print("Current transformation - Left: ${leftPercentage.toStringAsFixed(2)}%, "
        "Top: ${topPercentage.toStringAsFixed(2)}%, "
        "Scale: ${scale.toStringAsFixed(2)}");
  }

  void _saveEditedImage() {
    final currentMatrix = _transformationController.value;

    // Extract and save scale as a percentage
    final scale = currentMatrix.getMaxScaleOnAxis();
    widget.zone.scale = scale;

    // Calculate and save offset as percentages
    final translation = currentMatrix.getTranslation();
    widget.zone.offset = Offset(
      (translation.x / widget.zone.width) * 100, // Percentage of width
      (translation.y / widget.zone.height) * 100, // Percentage of height
    );

    print("Saved values - Scale: ${widget.zone.scale.toStringAsFixed(2)}x, "
        "Offset: ${widget.zone.offset.dx.toStringAsFixed(2)}%, "
        "${widget.zone.offset.dy.toStringAsFixed(2)}%");

    Navigator.pop(context, widget.zone);
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
              maxScale: 1.5,
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
        tooltip: 'Pick New Image',
        child: const Icon(Icons.photo),
      ),
    );
  }
}
