import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../models/page.dart' as photobook;
import '../../models/layout.dart';
import '../../models/template.dart';
import '../../models/zone.dart';
import 'custom_image_picker.dart';
import 'image_editor_screen.dart';

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
  int selectedPageIndex = 0;
  int? draggedZoneIndex;

  @override
  void initState() {
    super.initState();
    _printZonesInfo();
  }

  void _printZonesInfo() {
    int totalZones = 0;

    for (int i = 0; i < widget.photoBook.pages.length; i++) {
      final page = widget.photoBook.pages[i];
      if (page.layout != null) {
        int numberOfZones = page.layout!.zones.length;
        print('Page ${i + 1} has $numberOfZones zones.');
        totalZones += numberOfZones;
      } else {
        print('Page ${i + 1} has no layout assigned.');
      }
    }

    print('Total number of zones in all pages: $totalZones');
  }

  Future<void> _pickImage(int zoneIndex, Layout layout) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        layout.zones[zoneIndex].imageUrl = image.path;
      });
    }
  }

  void _swapImagesBetweenZones(int fromZoneIndex, int toZoneIndex) {
    setState(() {
      final layout = widget.photoBook.pages[selectedPageIndex].layout!;
      String tempImage = layout.zones[toZoneIndex].imageUrl;
      layout.zones[toZoneIndex].imageUrl = layout.zones[fromZoneIndex].imageUrl;
      layout.zones[fromZoneIndex].imageUrl = tempImage;
    });
  }

  // New function to handle zone updates
  void _updateZone(Zone updatedZone, Layout layout) {
    setState(() {
      int index = layout.zones.indexWhere((zone) => zone == updatedZone);
      if (index != -1) {
        layout.zones[index] = updatedZone;
      }
    });
  }

  Future<void> _pickMultipleImages() async {
    int totalZones = 0;

    for (var page in widget.photoBook.pages) {
      if (page.layout != null) {
        totalZones += page.layout!.zones.length;
      }
    }

    if (totalZones == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No zones available to assign images.')),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomImagePicker(
          maxImages: totalZones,
          onImagesSelected: (selectedPaths) {
            setState(() {
              int imageIndex = 0;

              for (var page in widget.photoBook.pages) {
                if (page.layout != null) {
                  for (var zone in page.layout!.zones) {
                    if (imageIndex < selectedPaths.length) {
                      zone.imageUrl = selectedPaths[imageIndex];
                      imageIndex++;
                    } else {
                      break;
                    }
                  }
                }
              }
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<photobook.Page> pages = widget.photoBook.pages;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.photoBook.title ?? 'Photo Book'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                height: 400,
                child: pages[selectedPageIndex].layout != null
                    ? LayoutWidget(
                  layout: pages[selectedPageIndex].layout!,
                  backgroundUrl: pages[selectedPageIndex].background,
                  onImageTap: _pickImage,
                  onImageDrop: _swapImagesBetweenZones,
                  onDragStart: (zoneIndex) {
                    draggedZoneIndex = zoneIndex;
                  },
                  onZoneUpdated: _updateZone, // Pass the update function
                )
                    : Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Text(
                      'No Layout Selected',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: pages.length,
              itemBuilder: (context, index) {
                final photobook.Page page = pages[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedPageIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: index == selectedPageIndex
                            ? Colors.blue
                            : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: page.layout?.miniatureImage != null
                              ? Image.network(
                            page.layout!.miniatureImage!,
                            fit: BoxFit.cover,
                          )
                              : Container(
                            color: Colors.grey[100],
                            child: const Center(
                              child: Text('No Image'),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Page ${index + 1}'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _pickMultipleImages,
              child: const Text('Select Images for All Zones'),
            ),
          ),
        ],
      ),
    );
  }
}







class LayoutWidget extends StatelessWidget {
  final Layout layout;
  final String backgroundUrl;
  final Function(int zoneIndex, Layout layout) onImageTap;
  final Function(int fromZoneIndex, int toZoneIndex) onImageDrop;
  final Function(int zoneIndex) onDragStart;
  final Function(Zone updatedZone, Layout layout) onZoneUpdated;

  const LayoutWidget({
    Key? key,
    required this.layout,
    required this.backgroundUrl,
    required this.onImageTap,
    required this.onImageDrop,
    required this.onDragStart,
    required this.onZoneUpdated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size layoutSize = _calculateLayoutSize(layout);
    const double backgroundPadding = 10.0;
    return Center(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(10.0),
        child: Container(
          width: layoutSize.width + 2 * backgroundPadding,
          height: layoutSize.height + 2 * backgroundPadding,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(backgroundUrl),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: layout.zones.map((zone) {
              print("Initial Zone Info - Scale: ${zone.scale}, Offset: ${zone.offset}"); // Debugging
              return Positioned(
                left: zone.left + backgroundPadding,
                top: zone.top + backgroundPadding,
                width: zone.width,
                height: zone.height,
                child: DragTarget<int>(
                  onAccept: (fromZoneIndex) {
                    onImageDrop(fromZoneIndex, layout.zones.indexOf(zone));
                  },
                  builder: (context, candidateData, rejectedData) {
                    return GestureDetector(
                      onTap: () => onImageTap(layout.zones.indexOf(zone), layout),
                      onPanStart: (_) => onDragStart(layout.zones.indexOf(zone)),
                      onLongPress: () async {
                        final updatedZone = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageEditorScreen(zone: zone),
                          ),
                        );
                        if (updatedZone != null) {
                          onZoneUpdated(updatedZone, layout);
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.all(4.0),
                        color: Colors.grey[100],
                        child: zone.imageUrl.isNotEmpty
                            ? Draggable<int>(
                          data: layout.zones.indexOf(zone),
                          feedback: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: AspectRatio(
                              aspectRatio: zone.width / zone.height,
                              child: _buildTransformedImage(zone),
                            ),
                          ),
                          childWhenDragging: Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Text('Dragging...'),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: AspectRatio(
                              aspectRatio: zone.width / zone.height,
                              child: _buildTransformedImage(zone),
                            ),
                          ),
                        )
                            : Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Text(
                              'No Image',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildTransformedImage(Zone zone) {
    // Calculate pixel offset from percentage values
    final offsetX = ((zone.offset.dx / 100) * zone.width); // Convert percentage back to pixels
    final offsetY = ((zone.offset.dy / 100) * zone.height);

    print("Applying transformation in _buildTransformedImage - "
        "Saved Offset Percentage: X = ${zone.offset.dx.toStringAsFixed(2)}%, Y = ${zone.offset.dy.toStringAsFixed(2)}%, "
        "Scale: ${zone.scale.toStringAsFixed(2)}x, "
        "Calculated Pixel Offset - X: ${offsetX.toStringAsFixed(2)}, Y: ${offsetY.toStringAsFixed(2)}");

    return AspectRatio(
      aspectRatio: zone.width / zone.height,
      child: ClipRect(
        child: Transform.translate(
          offset: Offset(offsetX, offsetY),
          child: Transform.scale(
            scale: zone.scale,
            alignment: Alignment.center,
            child: Image.file(
              File(zone.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }



  Size _calculateLayoutSize(Layout layout) {
    double maxWidth = 0;
    double maxHeight = 0;

    for (Zone zone in layout.zones) {
      maxWidth = max(maxWidth, zone.left + zone.width);
      maxHeight = max(maxHeight, zone.top + zone.height);
    }

    return Size(maxWidth, maxHeight);
  }
}










