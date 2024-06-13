import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:heritage/photo_book/models/category.dart';
import 'package:heritage/photo_book/screens/add_category_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  CategoryScreenState createState() => CategoryScreenState();
}

class CategoryScreenState extends State<CategoryScreen> {
  CollectionReference categoriesCollection = FirebaseFirestore.instance.collection('categories');

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
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(),
              ),
            );
          }

          List<Category> categories = snapshot.data!.docs.map((doc) {
            return Category.fromMap(doc.data() as Map<String, dynamic>);
          }).toList();
//
          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              Category category = categories[index];
              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.0), // Set the border radius here
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2.0), // Set the padding values here
                  child: ListTile(
                    title: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0), // Set the bottom padding here
                      child: Text(category.categoryName),
                    ),
                    leading: SizedBox(
                      width: 56,
                      child: category.imageUrl.isNotEmpty
                          ? FadeInImage.assetNetwork(
                        placeholder: 'assets/loading.gif',
                        image: category.imageUrl,
                        fit: BoxFit.cover,
                        fadeInDuration: const Duration(milliseconds: 300),
                        fadeOutDuration: const Duration(milliseconds: 300),
                        placeholderErrorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                      )
                          : Container(),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => showDeleteConfirmationDialog(category.id),
                    ),
                  ),
                ),
              );
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

  void navigateToAddCategoryScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddCategoryScreen()),
    );
  }

  void deleteCategory(String categoryId) {
    categoriesCollection.doc(categoryId).delete();
  }

  void showDeleteConfirmationDialog(String categoryId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Category'),
          content: const Text('Are you sure you want to delete this category?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                deleteCategory(categoryId);
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
