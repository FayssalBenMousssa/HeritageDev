import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/image_editor.dart';

class ImageEditorScreen extends StatelessWidget {
  final ImageEditor controller = Get.put(ImageEditor());

  // List of stickers and their positions on the image
  RxList<StickerWidget> stickers = <StickerWidget>[].obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        return controller.imageFile.value.path.isEmpty
            ? Center(
          child: TextButton(
              onPressed: () => controller.pickImage(),
              child: Text('Pick Image')),
        )
            : Stack(
          children: [
            // Display the image
            Positioned.fill(
              child: Image.file(
                File(controller.imageFile.value.path),
                fit: BoxFit.cover,
              ),
            ),
            // Display stickers
            ...stickers.map((sticker) => sticker).toList(),
            Positioned(
              bottom: 50,
              left: 50,
              child: ElevatedButton(
                onPressed: () {
                  stickers.add(
                    StickerWidget(
                      key: UniqueKey(),
                      image: AssetImage('assets/sticker1.png'), // Your sticker image
                    ),
                  );
                },
                child: Text('Add Sticker'),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class StickerWidget extends StatefulWidget {
  final ImageProvider image;

  StickerWidget({Key? key, required this.image}) : super(key: key);

  @override
  _StickerWidgetState createState() => _StickerWidgetState();
}

class _StickerWidgetState extends State<StickerWidget> {
  // Variables to track the position and size of the sticker
  Offset position = Offset(100, 100);
  double scale = 1.0;
  double rotation = 0.0;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            position += details.delta;
          });
        },
        onScaleUpdate: (details) {
          setState(() {
            scale = details.scale;
            rotation = details.rotation;
          });
        },
        child: Transform.rotate(
          angle: rotation,
          child: Image(
            image: widget.image,
            width: 100 * scale,
            height: 100 * scale,
          ),
        ),
      ),
    );
  }
}
