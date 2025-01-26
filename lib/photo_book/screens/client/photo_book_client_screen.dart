import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:heritage/photo_book/models/category.dart';
import 'package:heritage/photo_book/models/template.dart';
import 'creation_photo_book_screen.dart';

class TemplateClientScreen extends StatefulWidget {
  const TemplateClientScreen({Key? key}) : super(key: key);

  @override
  _TemplateClientScreenState createState() => _TemplateClientScreenState();
}

class _TemplateClientScreenState extends State<TemplateClientScreen> {
  Category? selectedCategory;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve the selected category from the arguments
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['category'] != null) {
      selectedCategory = args['category'] as Category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 15), // Smaller icon size
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Row(
          children: [
            SizedBox(width: 0), // Space between icon and text is now 4 pixels
            Text(
              'Photobook pour chaque moment',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0, // Reduce default spacing between leading icon and title
      ),
      body: Column(
        children: [
          _buildCategoryList(),
          Expanded(
            child: _buildPhotoBookGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    final CollectionReference categoriesCollection = FirebaseFirestore.instance.collection('categories');

    return StreamBuilder<QuerySnapshot>(
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

        // Add "All" option at the beginning of the list
        categories.insert(0, Category(id: 'all', categoryName: 'All', imageUrl: ''));

        return Container(
          height: 50,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.grey.withOpacity(0.5), // 50% transparent top border
                width: 1.0, // Thickness of the top border line
              ),
              bottom: BorderSide(
                color: Colors.grey.withOpacity(0.5), // 50% transparent bottom border
                width: 1.0, // Thickness of the bottom border line
              ),
            ),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              Category category = categories[index];
              return _buildCategoryItem(category);
            },
          ),
        );
      },
    );
  }

  Widget _buildCategoryItem(Category category) {
    return GestureDetector(
      onTap: () {
        setState(() {
          // If "All" is selected, set selectedCategory to null
          selectedCategory = category.id == 'all' ? null : category;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Center(
          child: Text(
            category.categoryName,
            style: TextStyle(
              color: selectedCategory?.id == category.id || (category.id == 'all' && selectedCategory == null)
                  ? Colors.blue
                  : Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoBookGrid() {
    final CollectionReference photoBooksCollection = FirebaseFirestore.instance.collection('photoBooks');

    return StreamBuilder<QuerySnapshot>(
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

        List<Template> photoBooks = snapshot.data!.docs
            .map((doc) => Template.fromMap(doc.data() as Map<String, dynamic>))
            .toList();

        // Filter photo books based on the selected category
        if (selectedCategory != null) {
          photoBooks = photoBooks
              .where((photoBook) => photoBook.categories.any((cat) => cat.id == selectedCategory!.id))
              .toList();
        }

        return Padding(
          padding: const EdgeInsets.only(left: 35.0, right: 35.0, top: 30.0), // Add padding here
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: 1.0,
            ),
            itemCount: photoBooks.length,
            itemBuilder: (context, index) {
              Template photoBook = photoBooks[index];
              return _buildPhotoBookItem(photoBook);
            },
          ),
        );
      },
    );
  }

  Widget _buildPhotoBookItem(Template photoBook) {
    return GestureDetector(
      onTap: () => _showTemplateDialog(photoBook),
      child: Card(
        elevation: 0, // Remove shadow by setting elevation to 0
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // Remove border radius
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.zero, // Remove border radius
                child: photoBook.coverImageUrl.isNotEmpty
                    ? Image.network(
                  photoBook.coverImageUrl,
                  fit: BoxFit.cover,
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
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center, // Center the text
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTemplateDialog(Template photoBook) {
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
          insetPadding: const EdgeInsets.all(5),
          child: Container(
            width: 400,
            height: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: PageView(
                    children: randomImageUrls.map((url) {
                      return Image.network(
                        url,
                        fit: BoxFit.cover,
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
                          Navigator.of(context).pop();
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