
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:heritage/photo_book/models/category.dart';
import 'package:heritage/photo_book/models/template.dart';

import '../../models/price.dart';
import 'creation_photo_book_screen.dart';

class TemplateClientScreen extends StatefulWidget {
  const TemplateClientScreen({Key? key}) : super(key: key);

  @override
  _TemplateClientScreenState createState() => _TemplateClientScreenState();
}

class _TemplateClientScreenState extends State<TemplateClientScreen> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final Category? category = args?['category'] as Category?;

    log('--------------------');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Books'),
      ),
      body: StreamBuilder<List<Template>>(
        stream: _getFilteredTemplatesStream(category),
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

          List<Template> _photoBooks = snapshot.data!;

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Number of columns in the grid
              crossAxisSpacing: 10.0, // Space between columns
              mainAxisSpacing: 10.0, // Space between rows
              childAspectRatio: 1.0, // Aspect ratio of each item (1:1)
            ),
            itemCount: _photoBooks.length,
            itemBuilder: (context, index) {
              Template photoBook = _photoBooks[index];
              return _buildTemplateGridItem(photoBook);
            },
          );
        },
      ),
    );
  }

  Stream<List<Template>> _getFilteredTemplatesStream(Category? category) {
    final CollectionReference photoBooksCollection = FirebaseFirestore.instance.collection('photoBooks');

    return photoBooksCollection.snapshots().map((snapshot) {
      List<Template> photoBooks = snapshot.docs
          .map((doc) => Template.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      if (category != null) {
        photoBooks = photoBooks
            .where((photoBook) => photoBook.categories.any((cat) => cat.id == category.id))
            .toList();
      }

      return photoBooks;
    });
  }

  Widget _buildTemplateGridItem(Template photoBook) {
    return GestureDetector(
      onTap: () => _showTemplateDialog(photoBook),
      child: Card(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    photoBook.title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8.0), // Add spacing between title and lowest price
                  Text(
                    getLowestPriceText(photoBook.price), // Use the function here
                    style: const TextStyle(fontSize: 14.0),
                  ),
                ],
              ),
            )

          ],
        ),
      ),
    );
  }


  String getLowestPriceText(List<Price> prices) {
    if (prices.isEmpty) {
      return 'No prices available';
    }

    final lowestPrice = prices.reduce((current, next) =>
    (current.value + current.coverPrice + current.sizePrice) <
        (next.value + next.coverPrice + next.sizePrice)
        ? current
        : next);

    return 'Price begin with: \$${(lowestPrice.value + lowestPrice.coverPrice + lowestPrice.sizePrice).toStringAsFixed(2)}';
  }

  void _showTemplateDialog(Template photoBook) {
    // Define a list of random image URLs
    final List<String> randomImageUrls = [
      'https://www.photobox.fr/product-pictures/PAP_130/product-page-slider/image-slider-1-FR.jpg?d=700x700',
      'https://www.photobox.fr/product-pictures/PAP_130/product-page-slider/image-slider-2-FR.jpg?d=700x700',
      'https://www.photobox.fr/product-pictures/PAP_130/product-page-slider/image-slider-1-FR.jpg?d=700x700',
      'https://www.photobox.fr/product-pictures/PAP_130/product-page-slider/image-slider-2-FR.jpg?d=700x700'
    ];

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(5), // Remove default padding
          child: Container(
            width: 400, // Width of the dialog
            height: 400, // Height of the dialog
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: PageView(
                    children: randomImageUrls.map((url) {
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            url,
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
                        ],
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        photoBook.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => CreationPhotoBookScreen(photoBook: photoBook),
                          ));
                        },
                        child: const Text('Create Photo Book'),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }





}
