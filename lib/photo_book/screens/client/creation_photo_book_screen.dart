import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../authentication/models/user_model.dart';
import '../../models/client_books.dart';
import '../../models/layout.dart';
import '../../models/template.dart';
import 'layout_widget.dart';

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
  final Map<int, bool> _isEditingPage = {};
  bool _isScrollEnabled = true;

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
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Image Selection',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'You have $totalZones zones.',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Please select $totalZones images.',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
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
                zone.imageUrl = images[imageIndex].path;
                imageIndex++;
              } else {
                break;
              }
            }
          }
        }
      });

      _showZoneAndImageInfo(totalZones, images.length);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No images selected.')),
      );
    }
  }

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
      _isScrollEnabled = !_isEditingPage.values.contains(true);
    });
  }

  void _saveAlbum() async {
    final photoBook = widget.photoBook;

    // Map to store updated zones with uploaded image URLs
    Map<String, dynamic> updatedPhotoBookMap = photoBook.toMap();

    // Loop through each page and zone to upload images
    for (var page in photoBook.pages) {
      if (page.layout != null) {
        for (var zone in page.layout!.zones) {
          if (zone.imageUrl.isNotEmpty && zone.imageUrl.startsWith('/data')) {
            // Upload local image to Firebase Storage
            firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
                .ref()
                .child('uploaded_images')
                .child('${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}.jpg');

            try {
              await ref.putFile(File(zone.imageUrl));
              String downloadUrl = await ref.getDownloadURL();

              // Update zone's imageUrl with the Firebase URL
              zone.imageUrl = downloadUrl;
            } catch (e) {
              // Handle upload error
              print('Error uploading image: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to upload image for zone: $e')),
              );
              return; // Exit save operation if upload fails
            }
          }
        }
      }
    }

    // Save the updated photo book to Firestore
    FirebaseFirestore.instance
        .collection('ClientBooks')
        .add(updatedPhotoBookMap)
        .then((docRef) {
      // Optional: Update the ID of the saved document
      FirebaseFirestore.instance
          .collection('ClientBooks')
          .doc(docRef.id)
          .update({'id': docRef.id});

      // Notify user of success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Album is saved successfully!')),
      );
    }).catchError((error) {
      // Handle Firestore save error
      print('Error saving album: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save album: $error')),
      );
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

      await _showDialogBeforeSelection(totalZones);
      await _pickMultipleImages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = widget.photoBook.pages;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.photoBook.title ?? 'Photo Book'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveAlbum, // Save album functionality
          ),
        ],
      ),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (notification) {
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
                            isEditable: (_isEditingPage[index] ?? false),
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


