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

  // Function to build an interactive zone for a given Zone object
  Widget _buildInteractiveZone(Zone zone) {
    // Create a TransformationController for managing scaling and translation of the InteractiveViewer
    final transformationController = TransformationController(
      Matrix4.identity() // Initialize the matrix with the identity matrix
        ..scale(zone.scale) // Apply the scale factor from the zone
        ..translate(
          // Translate the view based on the zone's offset and size
          zone.offset.dx * zone.width,
          zone.offset.dy * zone.height,
        ),
    );

    return Stack(
      children: [
        // GestureDetector to handle long press for switching images
        GestureDetector(
          onLongPress: () {
            // Action to switch the image
            _switchImage(zone);
          },
          child: InteractiveViewer(
            transformationController: transformationController, // Set the transformation controller
            boundaryMargin: EdgeInsets.zero, // No boundary margin (restrict movement to the image edges)
            minScale: 1.0, // Minimum zoom scale (default size)
            maxScale: 3.0, // Maximum zoom scale (up to 3x)
            constrained: true, // Ensure the child remains within the bounds of the parent
            child: Image.file(
              File(zone.imageUrl), // Load the image from the file path provided in the zone
              fit: BoxFit.cover, // Scale the image to cover the entire available space
              width: zone.width, // Set the width of the image based on the zone
              height: zone.height, // Set the height of the image based on the zone
            ),
          ),
        ),
        // Show the edit icon only if the page is editable
        if (isEditable)
          Positioned(
            top: 4, // Position 4 pixels from the top of the InteractiveViewer
            right: 4, // Position 4 pixels from the right of the InteractiveViewer
            child: GestureDetector(
              onTap: () => onImageTap(
                layout.zones.indexOf(zone), // Get the index of the zone
                layout, // Pass the layout containing all zones
              ), // Define the tap action for the edit icon
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300), // Smooth transition for any UI changes
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7), // Semi-transparent black background for better visibility
                  shape: BoxShape.circle, // Make the background a circular shape
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2), // Slight shadow for a raised effect
                      blurRadius: 4.0, // Blur radius for the shadow
                      spreadRadius: 2.0, // Spread radius for the shadow
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8.0), // Padding around the icon for easier clicking
                child: const Icon(
                  Icons.edit, // Icon for the edit button
                  color: Colors.white, // White color for visibility against the dark background
                  size: 16, // Slightly larger icon for better visibility
                ),
              ),
            ),
          ),
      ],
    );
  }



// Function to handle image switching
  void _switchImage(Zone zone) {
    // Example implementation for switching images
    // Replace this logic with actual image-swapping logic based on your app's requirements
    String newImageUrl = "path/to/your/new/image.jpg"; // New image path (hardcoded or dynamic)
    zone.imageUrl = newImageUrl;

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





