import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
    return PageView.builder(
      itemCount: 5, // Number of items in the gallery
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.accents[Random().nextInt(Colors.accents.length)],
          ),
          child: Center(
            child: Text(
              'Slide $index',
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
        );
      },
    );
  }
}
