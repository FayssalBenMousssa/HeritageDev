import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../models/page.dart' as photobook;
import '../../models/layout.dart';
import '../../models/template.dart';
import '../../models/zone.dart';

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
  Map<String, dynamic>? draggedZoneInfo;

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

  void _onImageDrop(int fromZoneIndex, int fromPageIndex, int toZoneIndex, int toPageIndex) {
    setState(() {
      String tempImage = widget.photoBook.pages[toPageIndex].layout!.zones[toZoneIndex].imageUrl;
      widget.photoBook.pages[toPageIndex].layout!.zones[toZoneIndex].imageUrl =
          widget.photoBook.pages[fromPageIndex].layout!.zones[fromZoneIndex].imageUrl;
      widget.photoBook.pages[fromPageIndex].layout!.zones[fromZoneIndex].imageUrl = tempImage;
    });
  }

  Future<void> _pickMultipleImages() async {
    int totalZones = 0;

    for (var page in widget.photoBook.pages) {
      if (page.layout != null) {
        totalZones += page.layout!.zones.length;
      }
    }

    final List<XFile>? images = await _picker.pickMultiImage();

    if (images != null && images.isNotEmpty) {
      setState(() {
        int imageIndex = 0;

        for (var page in widget.photoBook.pages) {
          if (page.layout != null) {
            for (var zone in page.layout!.zones) {
              if (imageIndex < images.length && imageIndex < totalZones) {
                zone.imageUrl = images[imageIndex].path;
                imageIndex++;
              } else {
                break;
              }
            }
          }
        }
      });
    }
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
          if (pages[selectedPageIndex].layout != null)
            Expanded(
              child: LayoutWidget(
                layout: pages[selectedPageIndex].layout!,
                backgroundUrl: pages[selectedPageIndex].background, // Pass each page's background URL
                onImageTap: _pickImage,
                onImageDrop: (fromZoneIndex, toZoneIndex) {
                  if (draggedZoneInfo != null) {
                    _onImageDrop(
                      draggedZoneInfo!['zoneIndex'],
                      draggedZoneInfo!['pageIndex'],
                      toZoneIndex,
                      selectedPageIndex,
                    );
                    draggedZoneInfo = null;
                  }
                },
                onDragStart: (zoneIndex) {
                  draggedZoneInfo = {
                    'zoneIndex': zoneIndex,
                    'pageIndex': selectedPageIndex
                  };
                },
              ),
            )
          else
            Container(
              height: 250,
              color: Colors.grey[300],
              child: const Center(
                child: Text(
                  'No Layout Selected',
                  style: TextStyle(color: Colors.black, fontSize: 16),
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

  const LayoutWidget({
    Key? key,
    required this.layout,
    required this.backgroundUrl,
    required this.onImageTap,
    required this.onImageDrop,
    required this.onDragStart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size layoutSize = _calculateLayoutSize(layout);

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      margin: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(backgroundUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SizedBox(
            width: layoutSize.width + 10,
            height: layoutSize.height - 50,
            child: Stack(
              children: layout.zones.asMap().entries.map((entry) {
                int zoneIndex = entry.key;
                Zone zone = entry.value;

                return Positioned(
                  left: zone.left,
                  top: zone.top,
                  width: zone.width - 2,
                  height: zone.height - 2,
                  child: DragTarget<int>(
                    onAccept: (fromZoneIndex) {
                      onImageDrop(fromZoneIndex, zoneIndex);
                    },
                    builder: (context, candidateData, rejectedData) {
                      return GestureDetector(
                        onTap: () => onImageTap(zoneIndex, layout),
                        onPanStart: (_) => onDragStart(zoneIndex),
                        child: Container(
                          margin: const EdgeInsets.all(2.0),
                          color: Colors.grey[100],
                          child: zone.imageUrl.isNotEmpty
                              ? Draggable<int>(
                            data: zoneIndex,
                            feedback: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.file(
                                File(zone.imageUrl),
                                width: zone.width,
                                height: zone.height,
                                fit: BoxFit.cover,
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
                              child: InteractiveViewer(
                                panEnabled: true,
                                minScale: 0.5,
                                maxScale: 3.0,
                                child: Image.file(
                                  File(zone.imageUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          )
                              : const Center(
                            child: Text('Tap to add image'),
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
      ),
    );
  }

  Size _calculateLayoutSize(Layout layout) {
    double maxWidth = 0;
    double maxHeight = 0;

    for (Zone zone in layout.zones) {
      maxWidth = max(maxWidth, zone.width + zone.left);
      maxHeight = max(maxHeight, zone.height + zone.top);
    }

    return Size(maxWidth, maxHeight);
  }
}
