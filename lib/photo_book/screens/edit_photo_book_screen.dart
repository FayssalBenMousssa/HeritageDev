import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:heritage/photo_book/Widget/checkbox_selection_list.dart';
import 'package:heritage/photo_book/models/book_form.dart';
import 'package:heritage/photo_book/models/book_type.dart';
import 'package:heritage/photo_book/models/category.dart';
import 'package:heritage/photo_book/models/cover_finish.dart';
import 'package:heritage/photo_book/models/paper_finish.dart';
import 'package:heritage/photo_book/models/photo_book.dart';
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
  late List<Category> _selectedCategories;
  late List<BookForm> _selectedBookForms;
  late List<BookType> _selectedBookTypes;
  late List<CoverFinish> _selectedCoverFinishes;
  late List<PaperFinish> _selectedPaperFinishes;
  late List<Size> _selectedSizes;

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
    _selectedCategories = widget.photoBook.categories;
    _selectedBookForms = widget.photoBook.formBook;
    _selectedBookTypes = widget.photoBook.type;
    _selectedCoverFinishes = widget.photoBook.coverFinish;
    _selectedPaperFinishes = widget.photoBook.paperFinish;
    _selectedSizes = widget.photoBook.size;

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
      });
    } catch (e) {
      print('Error fetching dropdown data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch dropdown data: $e')),
      );
    }
  }

  Future<void> _showCheckboxDialog<T>({
    required List<T> items,
    required List<T> selectedItems,
    required String title,
    required String Function(T) itemLabel,
    required ValueChanged<List<T>> onSelectionChanged,
  }) async {
    final result = await showDialog<List<T>>(
      context: context,
      builder: (context) {
        return CheckboxListDialog<T>(
          items: items,
          selectedItems: selectedItems,
          title: title,
          itemLabel: itemLabel,
        );
      },
    );
    if (result != null) {
      onSelectionChanged(result);
    }
  }

  void _updatePhotoBook() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();


      FirebaseFirestore.instance
          .collection('photoBooks')
          .doc(widget.photoBook.id)
          .update({
        'title': _title,
        'categories': _selectedCategories.map((cat) => cat.toMap()).toList(),
        'formBook': _selectedBookForms.map((form) => form.toMap()).toList(),
        'type': _selectedBookTypes.map((type) => type.toMap()).toList(),
        'coverFinish': _selectedCoverFinishes.map((cover) => cover.toMap()).toList(),
        'paperFinish': _selectedPaperFinishes.map((paper) => paper.toMap()).toList(),
        'size': _selectedSizes.map((size) => size.toMap()).toList(),
      }).then((_) {
        Navigator.pop(context);
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
              _buildCheckboxButton(
                title: 'Category',
                selectedItems: _selectedCategories,
                items: _categories,
                itemLabel: (item) => item.categoryName,
                onSelectionChanged: (selectedItems) {
                  setState(() {
                    _selectedCategories = selectedItems;
                  });
                },
              ),
              _buildCheckboxButton(
                title: 'Book Form',
                selectedItems: _selectedBookForms,
                items: _bookForms,
                itemLabel: (item) => item.name,
                onSelectionChanged: (selectedItems) {
                  setState(() {
                    _selectedBookForms = selectedItems;
                  });
                },
              ),
              _buildCheckboxButton(
                title: 'Book Type',
                selectedItems: _selectedBookTypes,
                items: _bookTypes,
                itemLabel: (item) => item.name,
                onSelectionChanged: (selectedItems) {
                  setState(() {
                    _selectedBookTypes = selectedItems;
                  });
                },
              ),
              _buildCheckboxButton(
                title: 'Cover Finish',
                selectedItems: _selectedCoverFinishes,
                items: _coverFinishes,
                itemLabel: (item) => item.name,
                onSelectionChanged: (selectedItems) {
                  setState(() {
                    _selectedCoverFinishes = selectedItems;
                  });
                },
              ),
              _buildCheckboxButton(
                title: 'Paper Finish',
                selectedItems: _selectedPaperFinishes,
                items: _paperFinishes,
                itemLabel: (item) => item.name,
                onSelectionChanged: (selectedItems) {
                  setState(() {
                    _selectedPaperFinishes = selectedItems;
                  });
                },
              ),
              _buildCheckboxButton(
                title: 'Size',
                selectedItems: _selectedSizes,
                items: _sizes,
                itemLabel: (item) => item.name,
                onSelectionChanged: (selectedItems) {
                  setState(() {
                    _selectedSizes = selectedItems;
                  });
                },
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

  Widget _buildCheckboxButton<T>({
    required String title,
    required List<T> selectedItems,
    required List<T> items,
    required String Function(T) itemLabel,
    required ValueChanged<List<T>> onSelectionChanged,
  }) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward),
      onTap: () {
        _showCheckboxDialog<T>(
          items: items,
          selectedItems: selectedItems,
          title: title,
          itemLabel: itemLabel,
          onSelectionChanged: onSelectionChanged,
        );
      },
    );
  }
}
