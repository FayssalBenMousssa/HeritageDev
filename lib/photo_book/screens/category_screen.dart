import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:heritage/photo_book/models/category.dart'; // Adjust paths as per your project structure
import 'package:heritage/photo_book/screens/add_category_screen.dart'; // Assuming you have these screens
import 'package:heritage/photo_book/screens/edit_category_screen.dart'; // Assuming you have these screens

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final CollectionReference categoriesCollection =
  FirebaseFirestore.instance.collection('categories');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: categoriesCollection.snapshots(),
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

          List<Category> categories = snapshot.data!.docs
              .map((doc) => Category.fromMap(doc.data() as Map<String, dynamic>))
              .toList();

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              Category category = categories[index];
              return _buildDismissibleCategoryListItem(category);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => navigateToAddCategoryScreen(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDismissibleCategoryListItem(Category category) {
    return Dismissible(
      key: Key(category.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDeleteConfirmationDialog();
      },
      onDismissed: (direction) {
        deleteCategory(category.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${category.categoryName} deleted')),
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
              // Image
              Container(
                width: 100,
                height: 100,
                child: category.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                  imageUrl: category.imageUrl,
                  placeholder: (context, url) =>
                      CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      Icon(Icons.error),
                  fit: BoxFit.cover,
                  fadeInDuration: const Duration(milliseconds: 300),
                  fadeOutDuration: const Duration(milliseconds: 300),
                )
                    : Container(),
              ),
              SizedBox(width: 16.0),
              // Name
              Expanded(
                child: Text(category.categoryName),
              ),
              SizedBox(width: 16.0),
              // Edit Icon
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => navigateToEditCategoryScreen(category),
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
          title: const Text('Delete Category'),
          content: const Text('Are you sure you want to delete this category?'),
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

  void navigateToAddCategoryScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddCategoryScreen()),
    );
  }

  void navigateToEditCategoryScreen(Category category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCategoryScreen(category: category),
      ),
    );
  }

  void deleteCategory(String categoryId) {
    categoriesCollection.doc(categoryId).delete();
  }
}

