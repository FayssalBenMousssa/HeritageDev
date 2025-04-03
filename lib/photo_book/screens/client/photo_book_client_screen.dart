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
          return const Center(
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
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4), // Reduced horizontal padding
        margin: const EdgeInsets.symmetric(horizontal: 2), // Reduced horizontal margin
        child: Center(
          child: Text(
            category.categoryName.toUpperCase(),
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
    // Use photoBook.miniature and photoBook.coverImageUrl for the images
    final List<String> photoBookImages = [
      photoBook.miniature,
      photoBook.coverImageUrl,
    ];

    // Track the current page index
    int currentPageIndex = 0;

    // Track selected values for TAILLE and COUVERTURE
    String? selectedTaille;
    String? selectedCouverture;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: const EdgeInsets.all(5),
              child: Container(
                width: 500, // Increased width for bigger images
                height: 600, // Increased height for bigger images and details
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: PageView(
                        onPageChanged: (index) {
                          setState(() {
                            currentPageIndex = index; // Update the current page index
                          });
                        },
                        children: photoBookImages.map((url) {
                          return Image.network(
                            url,
                            fit: BoxFit.cover,
                          );
                        }).toList(),
                      ),
                    ),
                    // Add a number indicator (e.g., 1/2, 2/2) under the image
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        '${currentPageIndex + 1} / ${photoBookImages.length}', // Display current page number
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey, // Grey text color
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title and Price in the same line
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                photoBook.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.grey, // Grey text color
                                ),
                              ),
                              Text(
                                '${photoBook.price.isNotEmpty ? photoBook.price.first.value : 0} dhs',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey, // Grey text color
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // TAILLE and COUVERTURE in the same line with dropdowns
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // TAILLE Dropdown
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'TAILLE : ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700], // Darker grey for labels
                                    ),
                                  ),
                                  DropdownButton<String>(
                                    value: selectedTaille,
                                    hint: Text(
                                      photoBook.size.isNotEmpty
                                          ? '${photoBook.size.first.dimensions}x${photoBook.size.first.dimensions} cm'
                                          : 'N/A',
                                      style: const TextStyle(
                                        color: Colors.grey, // Grey text color
                                      ),
                                    ),
                                    items: photoBook.size.map((size) {
                                      return DropdownMenuItem<String>(
                                        value: '${size.dimensions} ',
                                        child: Text(
                                          '${size.dimensions} ',
                                          style: const TextStyle(
                                            color: Colors.grey, // Grey text color
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedTaille = value; // Update selected TAILLE
                                      });
                                    },
                                  ),
                                ],
                              ),
                              // COUVERTURE Dropdown
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'COUVERTURE : ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700], // Darker grey for labels
                                    ),
                                  ),
                                  DropdownButton<String>(
                                    value: selectedCouverture,
                                    hint: Text(
                                      photoBook.coverFinish.isNotEmpty
                                          ? photoBook.coverFinish.first.name
                                          : 'N/A',
                                      style: const TextStyle(
                                        color: Colors.grey, // Grey text color
                                      ),
                                    ),
                                    items: photoBook.coverFinish.map((cover) {
                                      return DropdownMenuItem<String>(
                                        value: cover.name,
                                        child: Text(
                                          cover.name,
                                          style: const TextStyle(
                                            color: Colors.grey, // Grey text color
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedCouverture = value; // Update selected COUVERTURE
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                           Text(
                            'DETAILS:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700], // Darker grey for labels
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Le prix est appliqué sur les ${photoBook.numberPageInitial} premières pages.',
                            style: const TextStyle(
                              color: Colors.grey, // Grey text color
                            ),
                          ),
                          const Text(
                            'Ajout d\'une page : (+13 dhs 20x20cm) +23 dhs 27x27cm)',
                            style: TextStyle(
                              color: Colors.grey, // Grey text color
                            ),
                          ),
                          Text(
                            'Types d\'album: ${photoBook.type.isNotEmpty ? photoBook.type.first.name : 'N/A'}',
                            style: const TextStyle(
                              color: Colors.grey, // Grey text color
                            ),
                          ),
                          Text(
                            'Types de papier: ${photoBook.paperFinish.isNotEmpty ? photoBook.paperFinish.first.name : 'N/A'}',
                            style: const TextStyle(
                              color: Colors.grey, // Grey text color
                            ),
                          ),
                          Text(
                            'Tailles de l\'album: ${photoBook.size.isNotEmpty ? '${photoBook.size.first.dimensions}x${photoBook.size.first.dimensions} cm' : 'N/A'}',
                            style: const TextStyle(
                              color: Colors.grey, // Grey text color
                            ),
                          ),
                          Text(
                            'Longueur de l\'album: De ${photoBook.numberPageInitial} à 200 pages',
                            style: const TextStyle(
                              color: Colors.grey, // Grey text color
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Center the "Personnaliser" button
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => CreationPhotoBookScreen(photoBook: photoBook),
                                ));
                              },
                              child: const Text(
                                'Personnaliser',
                                style: TextStyle(
                                  color: Colors.white, // Keep button text white
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}