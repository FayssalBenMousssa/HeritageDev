import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/rendering.dart';
import 'app_left_drawer.dart';
import 'photo_book/models/category.dart'; // Adjust paths as per your project structure

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;


    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      drawer: AppLeftDrawer(user: user),
      body: Column(
        children: <Widget>[
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Quel Souvenir voulez-vous Capturer?',
                style: TextStyle(fontSize: 8, fontWeight: FontWeight.normal),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildHorizontalList(),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Check Offers and Discounts',
                style: TextStyle(fontSize: 8, fontWeight: FontWeight.normal),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _buildGallerySlider(),
          ),


        ],
      ),
    );
  }

  Widget _buildHorizontalList() {
    final CollectionReference categoriesCollection =
    FirebaseFirestore.instance.collection('categories');

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

        return Container(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              Category category = categories[index];
              return _buildCategoryListItem(context, category);
            },
          ),
        );
      },
    );
  }
  Widget _buildCategoryListItem(BuildContext context,Category category) {
    return Container(
      width: 100,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              image: DecorationImage(
                image: category.imageUrl.isNotEmpty
                    ? CachedNetworkImageProvider(category.imageUrl)
                    : AssetImage('assets/placeholder.png') as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          Align(
            alignment: Alignment.center, // Change this to move the button
            child: SizedBox(
              width: 90, // Set desired width
              height: 30, // Set desired height
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/photo_book_client',
                    arguments: {'category': category}, // Example argument
                  );
                },

                child: Text(
                  category.categoryName,
                  style: const TextStyle(color: Colors.black, fontSize: 10),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }





  Widget _buildGallerySlider() {
    const int numberOfImages = 5; // Number of random images to display
    final List<String> randomImageUrls = List.generate(
      numberOfImages,
          (index) => 'https://picsum.photos/600/400?random=$index',
    );

    // Overlay texts for the images
    final List<String> overlayTexts = [
      "Offres Spéciales: -50% sur les albums!",
      "Nouveau! Collection 2024.",
      "Capturez vos moments précieux.",
      "Créez votre album maintenant!",
      "Des souvenirs à feuilleter!",
    ];

    final PageController pageController = PageController(viewportFraction: 0.8);
    Timer? autoScrollTimer;

    // Start auto-scrolling
    void startAutoScroll() {
      autoScrollTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
        if (pageController.hasClients) {
          int nextPage = (pageController.page!.toInt() + 1) % numberOfImages;
          pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }

    // Stop auto-scrolling
    void stopAutoScroll() {
      autoScrollTimer?.cancel();
    }

    // Start auto-scrolling immediately
    startAutoScroll();

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // Stop auto-scrolling when user interacts with the slider
        if (notification is UserScrollNotification &&
            notification.direction != ScrollDirection.idle) {
          stopAutoScroll();
        }
        return false;
      },
      child: PageView.builder(
        controller: pageController,
        itemCount: randomImageUrls.length,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: pageController,
            builder: (context, child) {
              double value = 1.0;

              if (pageController.position.haveDimensions) {
                value = pageController.page! - index;
                value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
              }

              return Center(
                child: SizedBox(
                  height: Curves.easeInOut.transform(value) * 400,
                  width: Curves.easeInOut.transform(value) * 350,
                  child: Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: NetworkImage(randomImageUrls[index]),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: AnimatedOpacity(
                          opacity: value,
                          duration: const Duration(milliseconds: 300),
                          child: Transform.translate(
                            offset: Offset(0, (1 - value) * 50),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                overlayTexts[index % overlayTexts.length],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }





}
