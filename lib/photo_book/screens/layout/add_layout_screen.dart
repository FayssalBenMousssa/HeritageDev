import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/layout.dart';

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
      miniatureImage: miniatureImage,
    );

    await docRef.set(newLayout.toMap());

    // Navigate back to LayoutListScreen after saving
    Navigator.pop(context);
  }
}
