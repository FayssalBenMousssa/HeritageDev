import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:heritage/photo_book/models/photo_book.dart';
import 'package:heritage/photo_book/screens/add_photo_book_screen.dart';
import 'package:heritage/photo_book/screens/edit_photo_book_screen.dart'; // Import EditPhotoBookScreen
import 'package:heritage/photo_book/screens/photo_book_detail_screen.dart';

class PhotoBookScreen extends StatefulWidget {
  const PhotoBookScreen({Key? key}) : super(key: key);

  @override
  _PhotoBookScreenState createState() => _PhotoBookScreenState();
}

class _PhotoBookScreenState extends State<PhotoBookScreen> {
  final CollectionReference photoBooksCollection =
  FirebaseFirestore.instance.collection('photoBooks');

  List<PhotoBook> _photoBooks = [];

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
     log(arguments.toString()) ;
    log('--------------------') ;
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
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No photo books found'),
            );
          }

          try {
            _photoBooks = snapshot.data!.docs
                .map((doc) {

              return PhotoBook.fromMap(doc.data() as Map<String, dynamic>);
            })
                .toList();
          } catch (e) {
            return Center(
              child: Text('Error processing data: $e'),
            );
          }

          return ListView.builder(
            itemCount: _photoBooks.length,
            itemBuilder: (context, index) {
              PhotoBook photoBook = _photoBooks[index];
              return _buildDismissiblePhotoBookListItem(photoBook, index);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => navigateToAddPhotoBookScreen(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDismissiblePhotoBookListItem(PhotoBook photoBook, int index) {
    return Dismissible(
      key: Key(photoBook.id.toString()),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDeleteConfirmationDialog();
      },
      onDismissed: (direction) {
        deletePhotoBook(photoBook.id.toString());
        setState(() {
          _photoBooks.removeAt(index); // Remove the item from the list
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${photoBook.title} deleted')),
        );
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              SizedBox(width: 16.0),
              Expanded(
                child: Text(photoBook.title),
              ),
              Expanded(
                child: Text(
                  photoBook.size.isNotEmpty ? photoBook.size[0].name ?? 'Default Name' : 'List is empty',
                ),
              ),

              SizedBox(width: 16.0),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => navigateToEditPhotoBookScreen(photoBook),
              ),
              IconButton(
                icon: const Icon(Icons.info),
                onPressed: () => navigateToDetailPhotoBookScreen(photoBook),
              ),
            ],
          ),
        ),
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
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void navigateToAddPhotoBookScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPhotoBookScreen()),
    );
  }

  void navigateToEditPhotoBookScreen(PhotoBook photoBook) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPhotoBookScreen(photoBook: photoBook),
      ),
    );
  }

  void navigateToDetailPhotoBookScreen(PhotoBook photoBook) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoBookDetailScreen(photoBook: photoBook),
      ),
    );
  }

  void deletePhotoBook(String photoBookId) {
    photoBooksCollection.doc(photoBookId).delete();
  }
}
