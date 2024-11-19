import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/layout.dart';
import '../../models/template.dart';
import 'layout_widget.dart';

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
  final Map<int, bool> _isEditingPage = {}; // Track editing state of pages
  bool _isScrollEnabled = true; // Controls the scrolling state

  Future<void> _pickImage(int zoneIndex, Layout layout) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        layout.zones[zoneIndex].imageUrl = image.path;
      });
    }
  }

  Future<void> _showDialogBeforeSelection(int totalZones) async {
    await showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing the dialog by tapping outside
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Optional: rounded corners for the dialog
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Makes the dialog fit the content size
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Image Selection',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16), // Space between title and message
                Text(
                  'You have $totalZones zones.',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8), // Space between the messages
                Text(
                  'Please select $totalZones images.',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16), // Space between the message and the button
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }




  // Allows selecting multiple images and assigns them to zones in order.
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

    final List<XFile>? images = await _picker.pickMultiImage();

    if (images != null && images.isNotEmpty) {
      setState(() {
        int imageIndex = 0;

        for (var page in widget.photoBook.pages) {
          if (page.layout != null) {
            for (var zone in page.layout!.zones) {
              if (imageIndex < images.length) {
                zone.imageUrl = images[imageIndex].path; // Assigns images to zones sequentially.
                imageIndex++;
              } else {
                break;
              }
            }
          }
        }
      });

      // Show message with total zones and selected images.
      _showZoneAndImageInfo(totalZones, images.length);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No images selected.')),
      );
    }
  }


  // Function to display a message with total zones and selected images.
  void _showZoneAndImageInfo(int totalZones, int imageCount) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'You have $totalZones zones and selected $imageCount images.',
          style: const TextStyle(fontSize: 16),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }




  void _toggleEditing(int index) {
    setState(() {
      _isEditingPage[index] = !(_isEditingPage[index] ?? false);

      // Disable scrolling if any page is in editing mode
      _isScrollEnabled = !_isEditingPage.values.contains(true);
    });
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      int totalZones = 0;

      for (var page in widget.photoBook.pages) {
        if (page.layout != null) {
          totalZones += page.layout!.zones.length;
        }
      }

      // Show dialog with information before prompting for image selection
      await _showDialogBeforeSelection(totalZones);

      // After the dialog is dismissed, open the gallery
      await _pickMultipleImages();
    });
  }


  @override
  Widget build(BuildContext context) {
    final pages = widget.photoBook.pages;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.photoBook.title ?? 'Photo Book'),
      ),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (notification) {
          // Disable glow effect for better UX when scrolling is disabled
          notification.disallowIndicator();
          return false;
        },
        child: SingleChildScrollView(
          physics: _isScrollEnabled
              ? const AlwaysScrollableScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          child: Column(
            children: pages.asMap().entries.map((entry) {
              final index = entry.key;
              final page = entry.value;

              // Initialize editing state for the page
              _isEditingPage.putIfAbsent(index, () => false);

              return Padding(
                padding: const EdgeInsets.all(2.0),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        page.layout != null
                            ? Center(
                          child: LayoutWidget(
                            layout: page.layout!,
                            backgroundUrl: page.background,
                            onImageTap: (_isEditingPage[index] ?? false)
                                ? (zoneIndex, layout) {
                              _pickImage(zoneIndex, layout);
                            }
                                : (zoneIndex, layout) {
                              // No-op when editing is disabled
                            },
                            isEditable: (_isEditingPage[index] ?? false), // Pass the updated editable flag
                          ),
                        )
                            : Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Text(
                              'No Layout Selected',
                              style: TextStyle(
                                  color: Colors.black, fontSize: 16),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            (_isEditingPage[index] ?? false)
                                ? Icons.edit_off
                                : Icons.edit,
                            color: (_isEditingPage[index] ?? false)
                                ? Colors.red
                                : Colors.blue,
                          ),
                          onPressed: () => _toggleEditing(index),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Page ${index + 1}',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

}