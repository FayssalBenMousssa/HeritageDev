import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:heritage/photo_book/models/book_type.dart'; // Updated import for BookType
import 'package:heritage/photo_book/models/photo_book.dart';
import 'package:heritage/photo_book/models/category.dart';
import 'package:heritage/photo_book/models/book_form.dart';
import 'package:heritage/photo_book/models/paper_finish.dart';
import 'package:heritage/photo_book/models/cover_finish.dart';

class AddPhotoBookScreen extends StatelessWidget {
  const AddPhotoBookScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Photo Book'),
      ),
      body: const AddPhotoBookForm(),
    );
  }
}

class AddPhotoBookForm extends StatefulWidget {
  const AddPhotoBookForm({Key? key}) : super(key: key);

  @override
  _AddPhotoBookFormState createState() => _AddPhotoBookFormState();
}

class _AddPhotoBookFormState extends State<AddPhotoBookForm> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  List<Category> _categories = [];
  List<BookForm> _formsBook = [];
  List<BookType> _types = [];
  List<PaperFinish> _paperFinishes = [];
  List<CoverFinish> _coverFinishes = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchBookForms();
    _fetchTypes();
    _fetchPaperFinishes();
    _fetchCoverFinishes();
  }

  Future<void> _fetchCategories() async {
    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection('categories').get();
    setState(() {
      _categories = querySnapshot.docs
          .map((doc) => Category.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<void> _fetchBookForms() async {
    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection('forms').get();
    setState(() {
      _formsBook = querySnapshot.docs
          .map((doc) => BookForm.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<void> _fetchTypes() async {
    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection('types').get();
    setState(() {
      _types = querySnapshot.docs
          .map((doc) => BookType.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<void> _fetchPaperFinishes() async {
    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection('paperFinishes').get();
    setState(() {
      _paperFinishes = querySnapshot.docs
          .map((doc) => PaperFinish.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<void> _fetchCoverFinishes() async {
    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection('coverFinishes').get();
    setState(() {
      _coverFinishes = querySnapshot.docs
          .map((doc) => CoverFinish.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
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
                name: 'title',
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
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
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8.0),
              FormBuilderTextField(
                name: 'size',
                decoration: const InputDecoration(labelText: 'Size'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8.0),
              FormBuilderTextField(
                name: 'price',
                decoration: const InputDecoration(labelText: 'Price'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8.0),
              FormBuilderTextField(
                name: 'miniature',
                decoration: const InputDecoration(labelText: 'Miniature'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8.0),
              FormBuilderTextField(
                name: 'printingTime',
                decoration: const InputDecoration(labelText: 'Printing Time'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8.0),
              FormBuilderDropdown<Category>(
                name: 'category',
                decoration: const InputDecoration(labelText: 'Select Category'),
                validator: (value) {
                  if (value == null) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                items: _categories
                    .map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category.categoryName),
                ))
                    .toList(),
              ),
              const SizedBox(height: 8.0),
              FormBuilderDropdown<BookForm>(
                name: 'bookForm',
                decoration:
                const InputDecoration(labelText: 'Select Book Form'),
                validator: (value) {
                  if (value == null) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                items: _formsBook
                    .map((formBook) => DropdownMenuItem(
                  value: formBook,
                  child: Text(formBook.name),
                ))
                    .toList(),
              ),
              const SizedBox(height: 8.0),
              FormBuilderDropdown<BookType>(
                name: 'bookType',
                decoration: const InputDecoration(labelText: 'Select Type'),
                validator: (value) {
                  if (value == null) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                items: _types
                    .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.name),
                ))
                    .toList(),
              ),
              const SizedBox(height: 8.0),
              FormBuilderDropdown<PaperFinish>(
                name: 'paperFinish',
                decoration:
                const InputDecoration(labelText: 'Select Paper Finish'),
                validator: (value) {
                  if (value == null) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                items: _paperFinishes
                    .map((paperFinish) => DropdownMenuItem(
                  value: paperFinish,
                  child: Text(paperFinish.name),
                ))
                    .toList(),
              ),
              const SizedBox(height: 8.0),
              FormBuilderDropdown<CoverFinish>(
                name: 'coverFinish',
                decoration:
                const InputDecoration(labelText: 'Select Cover Finish'),
                validator: (value) {
                  if (value == null) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                items: _coverFinishes
                    .map((coverFinish) => DropdownMenuItem(
                  value: coverFinish,
                  child: Text(coverFinish.name),
                ))
                    .toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.saveAndValidate() ?? false) {
                    _savePhotoBook(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Processing Data')),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _savePhotoBook(BuildContext context) async {
    final formData = _formKey.currentState?.value;

    final String title = formData?['title'] ?? '';
    final String description = formData?['description'] ?? '';
    final String size = formData?['size'] ?? '';
    final double price = double.tryParse(formData?['price'] ?? '') ?? 0;
    final double miniature = double.tryParse(formData?['miniature'] ?? '') ?? 0;
    final double printingTime = double.tryParse(formData?['printingTime'] ?? '') ?? 0;

    final category = formData?['category'];
    final bookForm = formData?['bookForm'];
    final bookType = formData?['bookType'];
    final paperFinish = formData?['paperFinish'];
    final coverFinish = formData?['coverFinish'];

    DocumentReference docRef =
    FirebaseFirestore.instance.collection('photoBooks').doc();

    PhotoBook newPhotoBook = PhotoBook(
      id: docRef.id,
      pages: [],
      title: title,
      formBook: [bookForm],
      description: description,
      type: [bookType],
      size: size,
      paperFinish: [paperFinish],
      coverFinish: [coverFinish],
      price: price,
      miniature: miniature,
      printingTime: printingTime,
      categories: [category],
      coverImageUrl: '', // Set the cover image URL appropriately
    );

    await docRef.set(newPhotoBook.toMap());
    await docRef.update({'id': docRef.id});

    Navigator.pop(context);
  }
}
