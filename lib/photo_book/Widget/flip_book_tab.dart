import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore import for fetching layouts
import 'package:heritage/photo_book/models/page.dart' as photobook;
import 'package:heritage/photo_book/models/layout.dart'; // Import for Layout model

class PageDetailWidget extends StatefulWidget {
  final List<photobook.Page> pages; // Correctly referencing the type
  final int numberPageInitial;
  final String photobookId; // Changed to String for Firestore document ID

  const PageDetailWidget({
    super.key,
    required this.pages,
    required this.numberPageInitial,
    required this.photobookId,
  });

  @override
  _PageDetailWidgetState createState() => _PageDetailWidgetState();
}

class _PageDetailWidgetState extends State<PageDetailWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Pages: ${widget.pages.length}', // Display the number of pages
          style: TextStyle(fontSize: 18),
        ),
        Text(
          'Initial Page Number: ${widget.numberPageInitial}',
          style: TextStyle(fontSize: 18),
        ),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Number of squares in each row
              childAspectRatio: 1, // Makes the squares equal in height and width
            ),
            itemCount: widget.pages.length,
            itemBuilder: (context, index) {
              final photobook.Page page = widget.pages[index];
              return GestureDetector(
                onTap: () {
                  // Show image selection dialog with horizontal scrolling
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Scroll and Select an Image'),
                        content: Container(
                          width: double.maxFinite,
                          height: 400, // Height for the PageView
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('layouts')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              final List<DocumentSnapshot> docs = snapshot.data!.docs;

                              return PageView.builder(
                                scrollDirection: Axis.horizontal, // Horizontal scrolling
                                itemCount: docs.length, // Number of items in the scrollable list
                                itemBuilder: (context, layoutIndex) {
                                  Map<String, dynamic> data = docs[layoutIndex].data() as Map<String, dynamic>;
                                  final Layout selectedLayout = Layout.fromMap(data); // Convert Firestore data to Layout

                                  return GestureDetector(
                                      onTap: () {
                                        final pageDocPath = 'photoBooks/${widget.photobookId}';
                                        print("Attempting to access document at: $pageDocPath");

                                        FirebaseFirestore.instance
                                            .collection('photoBooks')
                                            .doc(widget.photobookId)
                                            .get()
                                            .then((doc) {
                                          if (doc.exists) {
                                            List<dynamic> pages = doc['pages'];
                                            var pageToUpdate = pages.firstWhere((p) => p['id'] == page.id, orElse: () => null);

                                            if (pageToUpdate != null) {
                                              // Update the page's layout property
                                              pageToUpdate['layout'] = selectedLayout.toMap();

                                              // Save the updated pages array back to Firestore
                                              doc.reference.update({'pages': pages}).then((_) {
                                                print("Updated photobook.page.layout with: ${selectedLayout.name}");

                                                // Update the local widget.pages list and refresh the UI
                                                setState(() {
                                                  widget.pages[index].layout = selectedLayout;
                                                });

                                              }).catchError((error) {
                                                print("Failed to update layout: $error");
                                              });
                                            } else {
                                              print("Page with ID: ${page.id} not found in the pages array.");
                                            }
                                          } else {
                                            print("Document not found. Please check the document ID.");
                                          }
                                        });

                                        Navigator.of(context).pop(); // Close the dialog
                                      },
                                    
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.grey[300], // Placeholder background color
                                      ),
                                      child: Image.network(
                                        data['miniatureImage'] ?? '',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  margin: const EdgeInsets.all(8.0), // Space between squares
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                  child: page.layout?.miniatureImage != null && page.layout!.miniatureImage!.isNotEmpty
                      ? CachedNetworkImage(
                    imageUrl: page.layout!.miniatureImage!,
                    placeholder: (context, url) => const CircularProgressIndicator(), // Show loading indicator while image loads
                    errorWidget: (context, url, error) => const Icon(Icons.error), // Show error icon if image fails to load
                    fit: BoxFit.cover, // Cover the entire container area
                    fadeInDuration: const Duration(milliseconds: 300),
                    fadeOutDuration: const Duration(milliseconds: 300),
                  )
                      : Container(
                    color: Colors.grey[300], // Background color for empty state
                    child: const Center(
                      child: Text(
                        'No Image', // Fallback text if no image is available
                        style: TextStyle(
                          color: Colors.black, // Text color for fallback
                          fontSize: 16,
                        ),
                      ),
                    ),
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
