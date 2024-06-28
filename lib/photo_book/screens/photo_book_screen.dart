import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heritage/photo_book/models/photo_book.dart'; // Adjust paths as per your project structure
import 'package:heritage/photo_book/screens/add_photo_book_screen.dart'; // Assuming you have this screen
//import 'package:heritage/photo_book/screens/edit_photo_book_screen.dart'; // Assuming you have this screen
import 'package:cached_network_image/cached_network_image.dart';

class PhotoBookScreen extends StatefulWidget {
  const PhotoBookScreen({Key? key}) : super(key: key);

  @override
  _PhotoBookScreenState createState() => _PhotoBookScreenState();
}

class _PhotoBookScreenState extends State<PhotoBookScreen> {
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
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          List<PhotoBook> photoBooks = snapshot.data!.docs
              .map((doc) => PhotoBook.fromMap(doc.data() as Map<String, dynamic>))
              .toList();

          return ListView.builder(
            itemCount: photoBooks.length,
            itemBuilder: (context, index) {
              PhotoBook photoBook = photoBooks[index];
              return _buildDismissiblePhotoBookListItem(photoBook);
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

  Widget _buildDismissiblePhotoBookListItem(PhotoBook photoBook) {
    return Dismissible(
      key: Key(photoBook.id.toString()),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDeleteConfirmationDialog();
      },
      onDismissed: (direction) {
        deletePhotoBook(photoBook.id.toString());
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
              // Cover Image
              Container(
                width: 100,
                height: 100,
                child: CachedNetworkImage(
                  imageUrl: photoBook.coverImageUrl,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  fit: BoxFit.cover,
                  fadeInDuration: const Duration(milliseconds: 300),
                  fadeOutDuration: const Duration(milliseconds: 300),
                ),
              ),
              SizedBox(width: 16.0),
              // Title
              Expanded(
                child: Text(photoBook.title),
              ),
              SizedBox(width: 16.0),
              // Edit Icon
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => navigateToEditPhotoBookScreen(photoBook),
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
   /* Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPhotoBookScreen(photoBook: photoBook),
      ),
    );*/
  }

  void deletePhotoBook(String photoBookId) {
    photoBooksCollection.doc(photoBookId).delete();
  }
}
