import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../models/layout.dart';
import '../../models/zone.dart';


class LayoutListScreenNew extends StatelessWidget {
  const LayoutListScreenNew({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Layout Switcher'),
      ),
      body: LayoutListView(), // The view that fetches the layouts from Firebase
    );
  }
}

class LayoutListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('layouts').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final List<DocumentSnapshot> docs = snapshot.data!.docs;
        return LayoutSwitcher(layouts: docs); // Pass the Firebase layouts to LayoutSwitcher
      },
    );
  }
}

class LayoutSwitcher extends StatefulWidget {
  final List<DocumentSnapshot> layouts; // Pass the list of layouts from Firestore

  const LayoutSwitcher({required this.layouts, super.key});

  @override
  _LayoutSwitcherState createState() => _LayoutSwitcherState();
}

class _LayoutSwitcherState extends State<LayoutSwitcher> {
  int selectedLayoutIndex = 0;

  // Function to switch between layouts
  void switchLayout(int index) {
    setState(() {
      selectedLayoutIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.layouts.isEmpty) {
      return const Center(child: Text("No layouts available"));
    }

    // Parse the Firebase data into your Layout model
    List<Layout> layoutList = widget.layouts.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return Layout.fromMap(data); // Assuming Layout has a fromMap method
    }).toList();

    return Column(
      children: [
        // Display the layout information (name and description)
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                layoutList[selectedLayoutIndex].name,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                layoutList[selectedLayoutIndex].description,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        // Display the currently selected layout inside a card
        Expanded(
          child: Center(
            child: LayoutWidget(layout: layoutList[selectedLayoutIndex]), // The layout content
          ),
        ),

        // Create a row of buttons with miniature images
        Container(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: layoutList.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => switchLayout(index),
                child: Container(
                  margin: const EdgeInsets.all(8.0),
                  child: Image.network(
                    layoutList[index].miniatureImage,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey,
                        child: const Center(child: Text("Image Error")),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Define the LayoutWidget to render the layout inside the card
class LayoutWidget extends StatefulWidget {
  final Layout layout;

  const LayoutWidget({required this.layout, super.key});

  @override
  _LayoutWidgetState createState() => _LayoutWidgetState();
}

class _LayoutWidgetState extends State<LayoutWidget> {
  final ImagePicker _picker = ImagePicker();

  // List of default image URLs
  final List<String> defaultImageUrls = [
    'https://picsum.photos/id/237/800',
    'https://picsum.photos/id/238/800',
    'https://picsum.photos/id/239/800',
    'https://picsum.photos/id/240/800',
    'https://picsum.photos/id/241/800',
    'https://picsum.photos/id/242/800',
    'https://picsum.photos/id/243/800',
    'https://picsum.photos/id/244/800',
    'https://picsum.photos/id/245/800',
    'https://picsum.photos/id/246/800',
  ];

  // Function to pick an image from the gallery or camera
  Future<void> _pickImage(int zoneIndex) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        // Update the image URL for the selected zone (for simplicity using a local file)
        widget.layout.zones[zoneIndex].imageUrl = image.path;
      });
    }
  }

  // Function to calculate the size of the layout based on its zones
  Size _calculateLayoutSize() {
    double maxWidth = 0;
    double maxHeight = 0;

    for (var zone in widget.layout.zones) {
      double zoneRight = zone.left + zone.width;
      double zoneBottom = zone.top + zone.height;

      if (zoneRight > maxWidth) {
        maxWidth = zoneRight;
      }
      if (zoneBottom > maxHeight) {
        maxHeight = zoneBottom;
      }
    }

    return Size(maxWidth, maxHeight);
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the size of the layout
    Size layoutSize = _calculateLayoutSize();

    return Card(
      elevation: 5, // Adds shadow around the entire card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2), // Rounded corners for the card
      ),
      margin: const EdgeInsets.all(16.0), // Margin around the card


      child: Padding(
        padding: const EdgeInsets.all(10.0), // Padding inside the card
        child: SizedBox(
          width: layoutSize.width + 10, // Adding extra width to account for spacing
          height: layoutSize.height + 10, // Adding extra height to account for spacing
          child: Stack(
            children: widget.layout.zones.asMap().entries.map((entry) {
              int zoneIndex = entry.key;
              Zone zone = entry.value;

              return Positioned(
                left: zone.left,
                top: zone.top,
                width: zone.width - 2, // Reducing width slightly for spacing
                height: zone.height - 2, // Reducing height slightly for spacing
                child: GestureDetector(
                  onTap: () => _pickImage(zoneIndex), // Pick image when tapping on the zone
                  child: Container(
                    margin: const EdgeInsets.all(2.0), // Adding margin between images
                    child: ClipPath(
                      clipper: zone.clipper, // Apply the clipper for each shape
                      child: InteractiveViewer(
                        panEnabled: true, // Enable panning
                        boundaryMargin: const EdgeInsets.all(20), // Allow some margin around the image for panning
                        minScale: 0.5, // Minimum zoom scale
                        maxScale: 3.0, // Maximum zoom scale
                        child: (zone.imageUrl.isNotEmpty && File(zone.imageUrl).existsSync())
                            ? Image.file(
                          File(zone.imageUrl), // Display the selected image from the phone
                          fit: BoxFit.cover, // Ensure the image fits the shape
                          errorBuilder: (context, error, stackTrace) {
                            return Container(color: Colors.grey, child: const Center(child: Text("Image Error")));
                          },
                        )
                            : Image.network(
                          defaultImageUrls[zoneIndex % defaultImageUrls.length], // Display the default image from the web
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(color: Colors.grey, child: const Center(child: Text("Image Error")));
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
