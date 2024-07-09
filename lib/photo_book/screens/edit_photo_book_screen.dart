import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heritage/photo_book/models/photo_book.dart';
import 'package:heritage/photo_book/models/category.dart';
import 'package:heritage/photo_book/models/book_form.dart';
import 'package:heritage/photo_book/models/book_type.dart';
import 'package:heritage/photo_book/models/cover_finish.dart';
import 'package:heritage/photo_book/models/paper_finish.dart';
import 'package:heritage/photo_book/models/size.dart';

class EditPhotoBookScreen extends StatefulWidget {
  final PhotoBook photoBook;

  const EditPhotoBookScreen({Key? key, required this.photoBook}) : super(key: key);

  @override
  _EditPhotoBookScreenState createState() => _EditPhotoBookScreenState();
}

class _EditPhotoBookScreenState extends State<EditPhotoBookScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late Category _category;
  late BookForm _bookForm;
  late BookType _bookType;
  late CoverFinish _coverFinish;
  late PaperFinish _paperFinish;
  late Size _size;

  List<Category> _categories = [];
  List<BookForm> _bookForms = [];
  List<BookType> _bookTypes = [];
  List<CoverFinish> _coverFinishes = [];
  List<PaperFinish> _paperFinishes = [];
  List<Size> _sizes = [];

  @override
  void initState() {
    super.initState();
    _title = widget.photoBook.title;

    _category = widget.photoBook.categories.isNotEmpty
        ? widget.photoBook.categories.first
        : Category(id: '', categoryName: '', imageUrl: '');

    _bookForm = widget.photoBook.formBook.isNotEmpty
        ? widget.photoBook.formBook.first
        : BookForm(id: '', name: '', description: '');

    _bookType = widget.photoBook.type.isNotEmpty
        ? widget.photoBook.type.first
        : BookType(id: '', name: '', description: '');

    _coverFinish = widget.photoBook.coverFinish.isNotEmpty
        ? widget.photoBook.coverFinish.first
        : CoverFinish(id: '', name: '', description: '');

    _paperFinish = widget.photoBook.paperFinish.isNotEmpty
        ? widget.photoBook.paperFinish.first
        : PaperFinish(id: '', name: '', description: '');

    _size = widget.photoBook.size.isNotEmpty
        ? widget.photoBook.size.first
        : Size(name: '', dimensions: '');

    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    try {
      final categorySnapshot = await FirebaseFirestore.instance.collection('categories').get();
      final bookFormSnapshot = await FirebaseFirestore.instance.collection('forms').get();
      final bookTypeSnapshot = await FirebaseFirestore.instance.collection('types').get();
      final coverFinishSnapshot = await FirebaseFirestore.instance.collection('coverFinishes').get();
      final paperFinishSnapshot = await FirebaseFirestore.instance.collection('paperFinishes').get();
      final sizeSnapshot = await FirebaseFirestore.instance.collection('sizes').get();

      setState(() {
        _categories = categorySnapshot.docs.map((doc) => Category.fromMap(doc.data())).toList();
        _bookForms = bookFormSnapshot.docs.map((doc) => BookForm.fromMap(doc.data())).toList();
        _bookTypes = bookTypeSnapshot.docs.map((doc) => BookType.fromMap(doc.data())).toList();
        _coverFinishes = coverFinishSnapshot.docs.map((doc) => CoverFinish.fromMap(doc.data())).toList();
        _paperFinishes = paperFinishSnapshot.docs.map((doc) => PaperFinish.fromMap(doc.data())).toList();
        _sizes = sizeSnapshot.docs.map((doc) => Size.fromMap(doc.data())).toList();

        // Ensure that the dropdown values match the items list
        _category = _categories.firstWhere((cat) => cat.id == _category.id,
            orElse: () => _categories.isNotEmpty ? _categories.first : Category(id: '', categoryName: '', imageUrl: ''));
        _bookForm = _bookForms.firstWhere((form) => form.id == _bookForm.id,
            orElse: () => _bookForms.isNotEmpty ? _bookForms.first : BookForm(id: '', name: '', description: ''));
        _bookType = _bookTypes.firstWhere((type) => type.id == _bookType.id,
            orElse: () => _bookTypes.isNotEmpty ? _bookTypes.first : BookType(id: '', name: '', description: ''));
        _coverFinish = _coverFinishes.firstWhere((cover) => cover.id == _coverFinish.id,
            orElse: () => _coverFinishes.isNotEmpty ? _coverFinishes.first : CoverFinish(id: '', name: '', description: ''));
        _paperFinish = _paperFinishes.firstWhere((paper) => paper.id == _paperFinish.id,
            orElse: () => _paperFinishes.isNotEmpty ? _paperFinishes.first : PaperFinish(id: '', name: '', description: ''));
        _size = _sizes.firstWhere((size) => size.name == _size.name,
            orElse: () => _sizes.isNotEmpty ? _sizes.first : Size(name: '', dimensions: ''));
      });
    } catch (e) {
      print('Error fetching dropdown data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch dropdown data: $e')),
      );
    }
  }

  void _updatePhotoBook() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      // Debug prints to verify form data
      print('Form data - Title: $_title');
      print('Form data - Category: ${_category.toMap()}');
      print('Form data - BookForm: ${_bookForm.toMap()}');
      print('Form data - BookType: ${_bookType.toMap()}');
      print('Form data - CoverFinish: ${_coverFinish.toMap()}');
      print('Form data - PaperFinish: ${_paperFinish.toMap()}');
      print('Form data - Size: ${_size.toMap()}');

      FirebaseFirestore.instance
          .collection('photoBooks')
          .doc(widget.photoBook.id)
          .update({
        'title': _title,
        'category': _category.toMap(),
        'bookForm': _bookForm.toMap(),
        'bookType': _bookType.toMap(),
        'coverFinish': _coverFinish.toMap(),
        'paperFinish': _paperFinish.toMap(),
        'size': _size.toMap(),
      }).then((_) {
        // Confirming data was updated
        FirebaseFirestore.instance
            .collection('photoBooks')
            .doc(widget.photoBook.id)
            .get()
            .then((doc) {
          print('Updated Document: ${doc.data()}');
          Navigator.pop(context);
        }).catchError((error) {
          print('Failed to fetch updated document: $error');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to fetch updated document: $error')),
          );
        });
      }).catchError((error) {
        print('Failed to update photo book: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update photo book: $error')),
        );
      });
    } else {
      print('Form validation failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Photo Book'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (value) => _title = value ?? '',
              ),
              DropdownButtonFormField<Category>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: _categories.map((Category category) {
                  return DropdownMenuItem<Category>(
                    value: category,
                    child: Text(category.categoryName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _category = value!;
                  });
                },
                onSaved: (value) => _category = value!,
              ),
              DropdownButtonFormField<BookForm>(
                value: _bookForm,
                decoration: const InputDecoration(labelText: 'Book Form'),
                items: _bookForms.map((BookForm bookForm) {
                  return DropdownMenuItem<BookForm>(
                    value: bookForm,
                    child: Text(bookForm.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _bookForm = value!;
                  });
                },
                onSaved: (value) => _bookForm = value!,
              ),
              DropdownButtonFormField<BookType>(
                value: _bookType,
                decoration: const InputDecoration(labelText: 'Book Type'),
                items: _bookTypes.map((BookType bookType) {
                  return DropdownMenuItem<BookType>(
                    value: bookType,
                    child: Text(bookType.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _bookType = value!;
                  });
                },
                onSaved: (value) => _bookType = value!,
              ),
              DropdownButtonFormField<CoverFinish>(
                value: _coverFinish,
                decoration: const InputDecoration(labelText: 'Cover Finish'),
                items: _coverFinishes.map((CoverFinish coverFinish) {
                  return DropdownMenuItem<CoverFinish>(
                    value: coverFinish,
                    child: Text(coverFinish.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _coverFinish = value!;
                  });
                },
                onSaved: (value) => _coverFinish = value!,
              ),
              DropdownButtonFormField<PaperFinish>(
                value: _paperFinish,
                decoration: const InputDecoration(labelText: 'Paper Finish'),
                items: _paperFinishes.map((PaperFinish paperFinish) {
                  return DropdownMenuItem<PaperFinish>(
                    value: paperFinish,
                    child: Text(paperFinish.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _paperFinish = value!;
                  });
                },
                onSaved: (value) => _paperFinish = value!,
              ),
              DropdownButtonFormField<Size>(
                value: _size,
                decoration: const InputDecoration(labelText: 'Size'),
                items: _sizes.map((Size size) {
                  return DropdownMenuItem<Size>(
                    value: size,
                    child: Text(size.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _size = value!;
                  });
                },
                onSaved: (value) => _size = value!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updatePhotoBook,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
