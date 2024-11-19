import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/layout.dart';
import '../../models/zone.dart';

class LayoutWidget extends StatelessWidget {
  final Layout layout;
  final String backgroundUrl;
  final Function(int zoneIndex, Layout layout) onImageTap;
  final bool isEditable; // Add the editable flag


  const LayoutWidget({
    Key? key,
    required this.layout,
    required this.backgroundUrl,
    required this.onImageTap,
    required this.isEditable, // Initialize it in the constructor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final layoutSize = _calculateLayoutSize(layout);
    return Padding(
      padding: const EdgeInsets.all(12.0), // Padding around the page
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Container(
          padding: const EdgeInsets.all(8.0), // Padding inside the Card
          width: layoutSize.width + 12,
          height: layoutSize.height + 12 ,
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
                child: Container(
                  margin: const EdgeInsets.all(8.0), // Spacing between zones
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
    // Use the TransformationController stored in the Zone object
    final transformationController = zone.transformationController;

    // Add a listener to capture transformation changes only if editable
    if (isEditable) {
      transformationController.addListener(() {
        final matrix = transformationController.value;

        // Extract current scale and translation
        final newScale = matrix.getMaxScaleOnAxis();
        final newTranslation = matrix.getTranslation();

        // Normalize the translation to calculate offset
        final newOffset = Offset(
          newTranslation.x / (zone.width != 0 ? zone.width : 1.0),
          newTranslation.y / (zone.height != 0 ? zone.height : 1.0),
        );

        // Update the zone state only if changes are detected
        if (newScale != zone.scale || newOffset != zone.offset) {
          zone.scale = newScale;
          zone.offset = newOffset;

          print('${zone.imageUrl} UPDATED: Scale: ${zone.scale}, Offset: ${zone.offset}');
        }
      });
    }

    return Stack(
      children: [
        GestureDetector(
          onLongPress: () {
            if (isEditable) {
              _switchImage(zone);
            }
          },
          child: InteractiveViewer(
            transformationController: transformationController,
            boundaryMargin: EdgeInsets.zero,
            panEnabled: isEditable, // Disable panning if not editable
            minScale: isEditable ? 1.0 : zone.scale, // Disable scaling if not editable
            maxScale: isEditable ? 3.0 : zone.scale, // Disable scaling if not editable
            constrained: true,
            child: Image.file(
              File(zone.imageUrl),
              fit: BoxFit.cover,
              width: zone.width,
              height: zone.height,
            ),
          ),
        ),
        if (isEditable)
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => onImageTap(
                layout.zones.indexOf(zone),
                layout,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4.0,
                      spreadRadius: 2.0,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8.0),
                child: const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
      ],
    );
  }












// Function to handle image switching
  void _switchImage(Zone zone) {

    // Trigger a UI update (if using state management, update the state accordingly)
    print('Image switched for zone: ${zone.imageUrl}');
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





