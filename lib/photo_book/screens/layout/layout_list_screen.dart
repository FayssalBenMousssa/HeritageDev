import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_layout_screen.dart'; // Import the AddLayoutScreen

class LayoutListScreen extends StatelessWidget {
  const LayoutListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Layout List'),
      ),
      body: LayoutListView(), // Widget that will display all layouts
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to AddLayoutScreen when button is pressed
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddLayoutScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class LayoutListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('layouts').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final List<DocumentSnapshot> docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> data = docs[index].data() as Map<String, dynamic>;

            return ListTile(
              leading: Image.network(
                data['miniatureImage'],
                width: 50,
                height: 50,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.broken_image, size: 50);
                },
              ),
              title: Text(data['name']),
              subtitle: Text(data['description']),
            );
          },
        );
      },
    );
  }
}
