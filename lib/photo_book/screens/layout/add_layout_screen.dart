import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../clippers/rectangle_clipper.dart';
import '../../models/layout.dart';
import '../../models/zone.dart';

class AddLayoutScreen extends StatelessWidget {
  const AddLayoutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Layout TEST'),
      ),
      body: const AddLayoutForm(),
    );
  }
}

class AddLayoutForm extends StatefulWidget {
  const AddLayoutForm({Key? key}) : super(key: key);

  @override
  _AddLayoutFormState createState() => _AddLayoutFormState();
}

class _AddLayoutFormState extends State<AddLayoutForm> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final String defaultImageUrl = 'https://example.com/default_image.png'; // Default image URL

  @override
  void initState() {
    super.initState();
    // Pre-fill the miniatureImage field with the default URL
    uploadLayoutsToFirestore();
    _formKey.currentState?.fields['miniatureImage']?.didChange(defaultImageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8.0),
              FormBuilderTextField(
                name: 'name',
                decoration: const InputDecoration(labelText: 'Layout Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name for the layout';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8.0),
              FormBuilderTextField(
                name: 'description',
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8.0),
              FormBuilderTextField(
                name: 'margin',
                decoration: const InputDecoration(labelText: 'Margin'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a margin value';
                  }
                  final margin = double.tryParse(value);
                  if (margin == null || margin < 0) {
                    return 'Please enter a valid positive margin';
                  }
                  return null;
                },
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 8.0),
              FormBuilderTextField(
                name: 'miniatureImage',
                decoration: const InputDecoration(labelText: 'Miniature Image URL'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an image URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.saveAndValidate() ?? false) {
                    _saveLayout(context);
                  }
                },
                child: const Text('Save Layout'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveLayout(BuildContext context) async {
    final formData = _formKey.currentState?.value;

    final String name = formData?['name'] ?? '';
    final String description = formData?['description'] ?? '';
    final double margin = double.tryParse(formData?['margin'] ?? '0') ?? 0;

    // Get the miniatureImage value directly from the form data
    final String miniatureImage = formData?['miniatureImage'] ?? '';

    DocumentReference docRef = FirebaseFirestore.instance.collection('layouts').doc();

    Layout newLayout = Layout(
      name: name,
      description: description,
      margin: margin,
      zones: [
        Zone(left: 0, top: 0, width: 150, height: 100, clipper: RectangleClipper(), imageUrl: 'https://picsum.photos/600/300'),
        Zone(left: 150, top: 0, width: 150, height: 100, clipper: RectangleClipper(), imageUrl: 'https://picsum.photos/600/300'),
      ],
      miniatureImage: miniatureImage,
    );

    await docRef.set(newLayout.toMap());

    // Navigate back to LayoutListScreen after saving
    Navigator.pop(context);
  }


// Upload Layouts to Firestore
  Future<void> uploadLayoutsToFirestore() async {
    // List of layouts to upload
    List<Layout> layouts = [
      Layout(
        name: 'Two Vertical Zones',
        description: 'Two vertically stacked zones',
        margin: 10.0,
        miniatureImage: 'https://firebasestorage.googleapis.com/v0/b/heritagebookapp-8f680.appspot.com/o/photobook_miniature%2FM1.png?alt=media&token=29001dbe-8339-46f6-99e4-adb30bef135a',
        zones: [
          Zone(left: 0, top: 0, width: 150, height: 300, clipper: RectangleClipper(), imageUrl: 'https://picsum.photos/600/300'),
          Zone(left: 150, top: 0, width: 150, height: 300, clipper: RectangleClipper(), imageUrl: 'https://picsum.photos/600/300'),
        ],
      ),
      Layout(
        name: 'Four Square Zones',
        description: 'Four equally sized square zones',
        margin: 10.0,
        miniatureImage: 'https://firebasestorage.googleapis.com/v0/b/heritagebookapp-8f680.appspot.com/o/photobook_miniature%2FM2.png?alt=media&token=4026c36c-00e2-472e-a671-b2cd2546c416',
        zones: [
          Zone(left: 0, top: 0, width: 150, height: 150, clipper: RectangleClipper(), imageUrl: 'https://picsum.photos/600/300'),
          Zone(left: 150, top: 0, width: 150, height: 150, clipper: RectangleClipper(), imageUrl: 'https://picsum.photos/600/300'),
          Zone(left: 0, top: 150, width: 150, height: 150, clipper: RectangleClipper(), imageUrl: 'https://picsum.photos/600/300'),
          Zone(left: 150, top: 150, width: 150, height: 150, clipper: RectangleClipper(), imageUrl: 'https://picsum.photos/600/300'),
        ],
      ),
      Layout(
        name: 'One Large and Two Small Zones',
        description: 'One large zone on the left and two smaller zones on the right',
        margin: 10.0,
        miniatureImage: 'https://firebasestorage.googleapis.com/v0/b/heritagebookapp-8f680.appspot.com/o/photobook_miniature%2FM3.png?alt=media&token=11afc154-50d2-449b-bb7b-0062a171cf3a',
        zones: [
          Zone(left: 0, top: 0, width: 150, height: 300, clipper: RectangleClipper(), imageUrl: 'https://picsum.photos/600/300'),
          Zone(left: 150, top: 0, width: 150, height: 150, clipper: RectangleClipper(), imageUrl: 'https://picsum.photos/600/300'),
          Zone(left: 150, top: 150, width: 150, height: 150, clipper: RectangleClipper(), imageUrl: 'https://picsum.photos/600/300'),
        ],
      ),
      // Add the remaining layouts in a similar manner...
    ];

    // Reference to Firestore collection
    CollectionReference layoutsCollection = FirebaseFirestore.instance.collection('layouts');

    // Loop through layouts and add them to Firestore
    for (Layout layout in layouts) {
      print(layout.name);
      Map<String, dynamic> layoutData = {
        'name': layout.name,
        'description': layout.description,
        'margin': layout.margin,
        'miniatureImage': layout.miniatureImage,
        'zones': layout.zones.map((zone) => {
          'left': zone.left,
          'top': zone.top,
          'width': zone.width,
          'height': zone.height,
          'clipper': zone.clipper.runtimeType.toString(),
          'imageUrl': zone.imageUrl,
        }).toList(),
      };

      // Add the layout to Firestore
      await layoutsCollection.add(layoutData);
    }

    print('Layouts uploaded successfully!');
  }

}
