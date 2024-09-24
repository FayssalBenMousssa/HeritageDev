
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:heritage/photo_book/models/template.dart';
import 'package:heritage/photo_book/screens/template/add_template_screen.dart';
import 'package:heritage/photo_book/screens/template/edit_template_screen.dart';
import 'package:heritage/photo_book/screens/template/template_detail_screen.dart';

class TemplateScreen extends StatefulWidget {
  const TemplateScreen({super.key});

  @override
  TemplateScreenState createState() => TemplateScreenState();
}

class TemplateScreenState extends State<TemplateScreen> {
  final CollectionReference photoBooksCollection =
  FirebaseFirestore.instance.collection('photoBooks');

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Books'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: photoBooksCollection.snapshots(),
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

          if (!snapshot.hasData || snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No photo books found'),
            );
          }

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1, // 1 item per line
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 2, // Adjust the aspect ratio for height and width
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              Template photoBook = Template.fromMap(doc.data() as Map<String, dynamic>);
              return _buildTemplateGridItem(photoBook, doc.id);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => navigateToAddTemplateScreen(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTemplateGridItem(Template photoBook, String docId) {
    return Dismissible(
      key: Key(docId),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        final shouldDelete = await showDeleteConfirmationDialog();

        if (shouldDelete == true) {
          log("User confirmed deletion");
          deleteTemplate(docId);
          // Use context after the async operation completes
          _showDeletionSnackbar(photoBook.title); // Call a method to show the snackbar
        } else {
          log("User canceled deletion");
        }

        return shouldDelete; // This will ensure the item is dismissed only if true
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: () => navigateToDetailTemplateScreen(photoBook),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0), // Add left margin
                child: Container(
                  width: 100, // Smaller width for the image
                  height: 100, // Set the height to match the smaller image
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                    image: DecorationImage(
                      image: photoBook.coverImageUrl.isNotEmpty
                          ? NetworkImage(photoBook.coverImageUrl) as ImageProvider
                          : const AssetImage('assets/logo.png') as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        photoBook.title,
                        style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: photoBook.price.map((price) {
                          double bookprice = price.value + price.coverPrice + price.sizePrice;
                          return Text(
                            'Prices: \$${bookprice.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 14.0),
                            overflow: TextOverflow.ellipsis,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => navigateToEditTemplateScreen(photoBook),
              ),
            ],
          ),
        ),
      ),
    );
  }

// New method to show the SnackBar
  void _showDeletionSnackbar(String title) {
    if (context.mounted) { // Ensure context is still mounted
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$title deleted')),
      );
    }
  }










  void navigateToAddTemplateScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTemplateScreen()),
    );
  }

  void navigateToEditTemplateScreen(Template photoBook) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTemplateScreen(photoBook: photoBook),
      ),
    );
  }

  void navigateToDetailTemplateScreen(Template photoBook) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TemplateDetailScreen(photoBook: photoBook),
      ),
    );
  }

  Future<bool?> showDeleteConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Photo Book'),
          content: const Text('Are you sure you want to delete this photo book?'),
          actions: [
            TextButton(
              onPressed: () {
                log("Delete action canceled");
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                log("Delete action confirmed");
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void deleteTemplate(String photoBookId) {
    log("deleteTemplate called with ID: $photoBookId");
    photoBooksCollection.doc(photoBookId).delete().then((_) {
      log("Photo book with ID: $photoBookId deleted");
    }).catchError((error) {
      log("Failed to delete photo book: $error");
    });
  }

}
