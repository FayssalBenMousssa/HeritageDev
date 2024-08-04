import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:heritage/photo_book/models/category.dart';
import 'package:heritage/photo_book/models/photo_book.dart';

class PhotoBookClientScreen extends StatefulWidget {
  const PhotoBookClientScreen({Key? key}) : super(key: key);

  @override
  _PhotoBookClientScreenState createState() => _PhotoBookClientScreenState();
}

class _PhotoBookClientScreenState extends State<PhotoBookClientScreen> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final Category? category = args?['category'] as Category?;

    log('--------------------');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Books'),
      ),
      body: StreamBuilder<List<PhotoBook>>(
        stream: _getFilteredPhotoBooksStream(category),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No photo books found'),
            );
          }

          List<PhotoBook> _photoBooks = snapshot.data!;

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Number of columns in the grid
              crossAxisSpacing: 10.0, // Space between columns
              mainAxisSpacing: 10.0, // Space between rows
              childAspectRatio: 1.0, // Aspect ratio of each item (1:1)
            ),
            itemCount: _photoBooks.length,
            itemBuilder: (context, index) {
              PhotoBook photoBook = _photoBooks[index];
              return _buildPhotoBookGridItem(photoBook);
            },
          );
        },
      ),
    );
  }

  Stream<List<PhotoBook>> _getFilteredPhotoBooksStream(Category? category) {
    final CollectionReference photoBooksCollection = FirebaseFirestore.instance.collection('photoBooks');

    return photoBooksCollection.snapshots().map((snapshot) {
      List<PhotoBook> photoBooks = snapshot.docs
          .map((doc) => PhotoBook.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      if (category != null) {
        photoBooks = photoBooks
            .where((photoBook) => photoBook.categories.any((cat) => cat.id == category.id))
            .toList();
      }

      return photoBooks;
    });
  }

  Widget _buildPhotoBookGridItem(PhotoBook photoBook) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8.0)),
              child: photoBook.coverImageUrl.isNotEmpty
                  ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    photoBook.coverImageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      } else {
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                          ),
                        );
                      }
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.error, color: Colors.red),
                      );
                    },
                  ),
                  // Optionally, you can add an overlay or additional UI here
                ],
              )
                  : Container(
                color: Colors.grey,
                child: const Center(
                  child: Text(
                    'No Image',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              photoBook.title,
              style: TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
