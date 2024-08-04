import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:heritage/photo_book/models/book_type.dart';
import 'package:heritage/photo_book/models/photo_book.dart';
import 'package:heritage/photo_book/models/category.dart';
import 'package:heritage/photo_book/models/book_form.dart';
import 'package:heritage/photo_book/models/paper_finish.dart';
import 'package:heritage/photo_book/models/cover_finish.dart';
import 'package:heritage/photo_book/models/size.dart'; // Import the Size class

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
  List<Size> _sizes = []; // Added list to store sizes

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchBookForms();
    _fetchTypes();
    _fetchPaperFinishes();
    _fetchCoverFinishes();
    _fetchSizes(); // Fetch sizes when initializing
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
          .map((doc) =>
          PaperFinish.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<void> _fetchCoverFinishes() async {
    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection('coverFinishes').get();
    setState(() {
      _coverFinishes = querySnapshot.docs
          .map((doc) =>
          CoverFinish.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<void> _fetchSizes() async {
    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection('sizes').get();
    setState(() {
      _sizes = querySnapshot.docs
          .map((doc) => Size.fromMap(doc.data() as Map<String, dynamic>))
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

              FormBuilderCheckboxGroup<Size>(
                name: 'size',
                decoration: const InputDecoration(labelText: 'Select Sizes'),
                validator: (values) {
                  if (values == null || values.isEmpty) {
                    return 'Please select at least one size';
                  }
                  return null;
                },
                options: _sizes
                    .map((size) => FormBuilderFieldOption(
                  value: size,
                  child: Text(size.name),
                ))
                    .toList(),
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

              FormBuilderCheckboxGroup<Category>(
                name: 'category',
                decoration: const InputDecoration(labelText: 'Select Categories'),
                validator: (values) {
                  if (values == null || values.isEmpty) {
                    return 'Please select at least one category';
                  }
                  return null;
                },
                options: _categories
                    .map((category) => FormBuilderFieldOption(
                  value: category,
                  child: Text(category.categoryName),
                ))
                    .toList(),
              ),

              const SizedBox(height: 8.0),
              FormBuilderCheckboxGroup<BookForm>(
                name: 'bookForm',
                decoration: const InputDecoration(labelText: 'Select Book Forms'),
                validator: (values) {
                  if (values == null || values.isEmpty) {
                    return 'Please select at least one book form';
                  }
                  return null;
                },
                options: _formsBook
                    .map((formBook) => FormBuilderFieldOption(
                  value: formBook,
                  child: Text(formBook.name),
                ))
                    .toList(),
              ),

              const SizedBox(height: 8.0),
              FormBuilderCheckboxGroup<BookType>(
                name: 'bookType',
                decoration: const InputDecoration(labelText: 'Select Types'),
                validator: (values) {
                  if (values == null || values.isEmpty) {
                    return 'Please select at least one type';
                  }
                  return null;
                },
                options: _types
                    .map((type) => FormBuilderFieldOption(
                  value: type,
                  child: Text(type.name),
                ))
                    .toList(),
              ),

              const SizedBox(height: 8.0),
              FormBuilderCheckboxGroup<PaperFinish>(
                name: 'paperFinish',
                decoration: const InputDecoration(labelText: 'Select Paper Finishes'),
                validator: (values) {
                  if (values == null || values.isEmpty) {
                    return 'Please select at least one paper finish';
                  }
                  return null;
                },
                options: _paperFinishes
                    .map((paperFinish) => FormBuilderFieldOption(
                  value: paperFinish,
                  child: Text(paperFinish.name),
                ))
                    .toList(),
              ),

              const SizedBox(height: 8.0),
              FormBuilderCheckboxGroup<CoverFinish>(
                name: 'coverFinish',
                decoration: const InputDecoration(labelText: 'Select Cover Finishes'),
                validator: (values) {
                  if (values == null || values.isEmpty) {
                    return 'Please select at least one cover finish';
                  }
                  return null;
                },
                options: _coverFinishes
                    .map((coverFinish) => FormBuilderFieldOption(
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
    final List<Size> selectedSizes = formData?['size'] ?? [];
    final double price =
        double.tryParse(formData?['price'] ?? '') ?? 0;
    final String miniature = formData?['miniature'] ?? '';
    final double printingTime =
        double.tryParse(formData?['printingTime'] ?? '') ?? 0;

    final List<Category> selectedCategories = formData?['category'] ?? [];
    final List<BookForm> selectedBookForms = formData?['bookForm'] ?? [];
    final List<BookType> selectedBookTypes = formData?['bookType'] ?? [];
    final List<PaperFinish> selectedPaperFinishes = formData?['paperFinish'] ?? [];
    final List<CoverFinish> selectedCoverFinishes = formData?['coverFinish'] ?? [];

    DocumentReference docRef =
    FirebaseFirestore.instance.collection('photoBooks').doc();

    PhotoBook newPhotoBook = PhotoBook(
      id: docRef.id,
      pages: [],
      title: title,
      formBook: selectedBookForms,
      description: description,
      type: selectedBookTypes,
      size: selectedSizes,
      paperFinish: selectedPaperFinishes,
      coverFinish: selectedCoverFinishes,
      price: price,
      miniature: miniature,
      printingTime: printingTime,
      categories: selectedCategories,
      coverImageUrl: '', // Set the cover image URL appropriately
    );

    await docRef.set(newPhotoBook.toMap());
    await docRef.update({'id': docRef.id});

    Navigator.pop(context);
  }
}
