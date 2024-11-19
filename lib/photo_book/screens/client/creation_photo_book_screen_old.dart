import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../models/layout.dart';
import '../../models/zone.dart';
import '../../models/template.dart';

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
  final PageController _pageController = PageController(); // Controller for navigating pages
  int _currentPageIndex = 0;

  Future<void> _pickImage(int zoneIndex, Layout layout) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        layout.zones[zoneIndex].imageUrl = image.path;
      });
    }
  }

  void _nextPage() {
    if (_currentPageIndex < widget.photoBook.pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPageIndex++;
      });
    }
  }

  void _previousPage() {
    if (_currentPageIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPageIndex--;
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
      body: PageView.builder(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Disable user scrolling
        itemCount: pages.length,
        itemBuilder: (context, index) {
          final page = pages[index];
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: page.layout != null
                ? LayoutWidget(
              layout: page.layout!,
              backgroundUrl: page.background,
              onImageTap: _pickImage,
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
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            onPressed: _previousPage,
            heroTag: 'previousPage',
            child: const Icon(Icons.arrow_back),
          ),
          FloatingActionButton(
            onPressed: _pickAllImagesForAllZones,
            heroTag: 'selectImages',
            child: const Icon(Icons.image),
          ),
          FloatingActionButton(
            onPressed: _nextPage,
            heroTag: 'nextPage',
            child: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAllImagesForAllZones() async {
    final totalZones = widget.photoBook.pages.fold<int>(
      0,
          (sum, page) => sum + (page.layout?.zones.length ?? 0),
    );

    if (totalZones == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No zones available to assign images.')),
      );
      return;
    }

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        for (var page in widget.photoBook.pages) {
          if (page.layout != null) {
            for (var zone in page.layout!.zones) {
              zone.imageUrl = image.path;
            }
          }
        }
      });
    }
  }
}


class LayoutWidget extends StatelessWidget {
  final Layout layout;
  final String backgroundUrl;
  final Function(int zoneIndex, Layout layout) onImageTap;

  const LayoutWidget({
    Key? key,
    required this.layout,
    required this.backgroundUrl,
    required this.onImageTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final layoutSize = _calculateLayoutSize(layout);

    return Center(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(10.0),
        child: Container(
          width: layoutSize.width,
          height: layoutSize.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: backgroundUrl.isNotEmpty
                  ? NetworkImage(backgroundUrl)
                  : const AssetImage('assets/placeholder.jpg') as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: layout.zones.map((zone) {
              return Positioned(
                left: zone.left,
                top: zone.top,
                width: zone.width,
                height: zone.height,
                child: GestureDetector(
                  onTap: () => onImageTap(layout.zones.indexOf(zone), layout),
                  child: _buildInteractiveZone(zone),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveZone(Zone zone) {
    final transformationController = TransformationController(
      Matrix4.identity()
        ..scale(zone.scale)
        ..translate(
          zone.offset.dx * zone.width,
          zone.offset.dy * zone.height,
        ),
    );

    return InteractiveViewer(
      transformationController: transformationController,
      boundaryMargin: EdgeInsets.all(20),
      minScale: 1.0,
      maxScale: 3.0,
      constrained: true,
      onInteractionUpdate: (details) {
        final matrix = transformationController.value;

        // Update the scale
        zone.scale = matrix.getMaxScaleOnAxis();

        // Get the current translation
        final translation = matrix.getTranslation();

        // Update the offset in percentages (relative to the zone dimensions)
        zone.offset = Offset(
          translation.x / zone.width / zone.scale,
          translation.y / zone.height / zone.scale,
        );
      },
      onInteractionEnd: (details) {
        final matrix = transformationController.value;

        // Finalize the offset in percentages (relative to the zone dimensions)
        final translation = matrix.getTranslation();

        zone.offset = Offset(
          translation.x / zone.width / zone.scale,
          translation.y / zone.height / zone.scale,
        );

        // Debug log (optional)
        print('Updated Zone Offset: ${zone.offset}');
      },
      child: ClipPath(
        clipper: zone.clipper,
        child: zone.imageUrl.isNotEmpty
            ? Image.file(
          File(zone.imageUrl),
          fit: BoxFit.cover,
        )
            : Container(
          color: Colors.black.withOpacity(0.2),
          child: const Center(
            child: Icon(
              Icons.add_photo_alternate,
              color: Colors.white,
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


