import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heritage/photo_book/models/page.dart' as photobook;
import 'package:heritage/photo_book/models/layout.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';

class PageDetailWidget extends StatefulWidget {
  final List<photobook.Page> pages;
  final int numberPageInitial;
  final String photobookId;

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
  final ImagePicker _picker = ImagePicker();

  Future<void> _changeBackground(photobook.Page page, int index) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      try {
        final firebase_storage.Reference ref = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('uploaded_images')
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

        final firebase_storage.UploadTask uploadTask = ref.putFile(File(image.path));
        final firebase_storage.TaskSnapshot snapshot = await uploadTask;
        final String imageUrl = await snapshot.ref.getDownloadURL();

        setState(() {
          widget.pages[index].background = imageUrl;
        });

        FirebaseFirestore.instance.collection('photoBooks').doc(widget.photobookId).update({
          'pages': widget.pages.map((page) => page.toMap()).toList(),
        });

        print("Background updated successfully.");
      } catch (e) {
        print("Error updating background: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Pages: ${widget.pages.length}',
          style: TextStyle(fontSize: 18),
        ),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
            ),
            itemCount: widget.pages.length,
            itemBuilder: (context, index) {
              final photobook.Page page = widget.pages[index];
              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Select Layout or Change Background'),
                        content: Container(
                          width: double.maxFinite,
                          height: 400,
                          child: Column(
                            children: [
                              ElevatedButton(
                                onPressed: () => _changeBackground(page, index),
                                child: const Text("Change Background"),
                              ),
                              Expanded(
                                child: StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance.collection('layouts').snapshots(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    }

                                    final List<DocumentSnapshot> docs = snapshot.data!.docs;

                                    return PageView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: docs.length,
                                      itemBuilder: (context, layoutIndex) {
                                        Map<String, dynamic> data =
                                        docs[layoutIndex].data() as Map<String, dynamic>;
                                        final Layout selectedLayout = Layout.fromMap(data);

                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              widget.pages[index].layout = selectedLayout;
                                            });

                                            FirebaseFirestore.instance
                                                .collection('photoBooks')
                                                .doc(widget.photobookId)
                                                .update({
                                              'pages': widget.pages.map((page) => page.toMap()).toList(),
                                            });

                                            Navigator.of(context).pop();
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(horizontal: 8.0),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              color: Colors.grey[300],
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
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: page.background.isNotEmpty
                                    ? page.background
                                    : 'https://via.placeholder.com/150', // Placeholder if no background
                                placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: page.layout?.miniatureImage != null
                                  ? CachedNetworkImage(
                                imageUrl: page.layout!.miniatureImage!,
                                placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                                fit: BoxFit.cover,
                              )
                                  : Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Text(
                                    'No Layout',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Page ${index + 1} of ${widget.pages.length}',
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
