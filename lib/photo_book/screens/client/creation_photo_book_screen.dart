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

  void _toggleEditing(int index) {
    setState(() {
      _isEditingPage[index] = !(_isEditingPage[index] ?? false);

      // Disable scrolling if any page is in editing mode
      _isScrollEnabled = !_isEditingPage.values.contains(true);
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