
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:page_flip/page_flip.dart' show PageFlipWidget, PageFlipWidgetState;

import '../../Widget/flip_book_tab.dart';
import '../../models/layout.dart';

import '../../models/page.dart';
import '../../models/price.dart';
import '../../Widget/ImageSelector.dart';
import '../../models/template.dart';
import '../../Widget/demo_page.dart';


class TemplateDetailScreen extends StatefulWidget {
   Template photoBook;

   TemplateDetailScreen({super.key, required this.photoBook});

  @override
  _TemplateDetailScreenState createState() => _TemplateDetailScreenState();
}

class _TemplateDetailScreenState extends State<TemplateDetailScreen>
    with SingleTickerProviderStateMixin {
  final _controller = GlobalKey<PageFlipWidgetState>();

  late TabController _tabController;
  bool showListPrice = true;
  String? imageError;

  DateTime? dateStart;
  DateTime? dateEnd;



  final _formKey = GlobalKey<FormState>();


  final Map<String, TextEditingController> _sizeControllers = {};
  final Map<String, Map<String, TextEditingController>> _coverControllers = {};
  final Map<String, TextEditingController> _pageControllers = {};
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  late TextEditingController _valueController = TextEditingController();

  @override

  void initState() {
    super.initState();

    // Set default dates and other initializations
    //_loadInitialImage();
    _tabController = TabController(length: 9, vsync: this);
    dateStart = DateTime.now();
    dateEnd = DateTime.now().add(const Duration(days: 365));
    _startDateController.text = '${dateStart!.toLocal()}'.split(' ')[0];
    _endDateController.text = '${dateEnd!.toLocal()}'.split(' ')[0];
    _valueController.text = '0';

    // Fetch Template from Firestore and update local state
    fetchTemplate(widget.photoBook.id).then((fetchedTemplate) {
      if (fetchedTemplate != null) {
        setState(() {
          _photoBook = fetchedTemplate;
          _initializeControllers(); // Initialize controllers based on the fetched data
        });
      }
    });
  }


// Local variable to store fetched Template
  Template? _photoBook;

// Method to initialize controllers based on the fetched Template
  void _initializeControllers() {
    if (_photoBook != null) {
      // Initialize controllers with data from _photoBook
      for (var price in _photoBook!.price) {
        _sizeControllers[price.size.name] =
            TextEditingController(text: price.sizePrice.toString());
        _pageControllers[price.size.name] =
            TextEditingController(text: price.pagePrice.toString());
        if (_coverControllers[price.size.name] == null) {
          _coverControllers[price.size.name] = {};
        }
        _coverControllers[price.size.name]![price.coverFinish.name] =
            TextEditingController(text: price.coverPrice.toString());
        _valueController = TextEditingController(text: price.value.toString());
      }
    }
  }


  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _valueController.dispose();
    _tabController.dispose();
    for (var controller in _sizeControllers.values) {
      controller.dispose();
    }
    _coverControllers.values
        .expand((map) => map.values)
        .forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context,
      {required bool isStartDate})
  async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          dateStart = picked;
          _startDateController.text = '${dateStart!.toLocal()}'.split(' ')[0];
        } else {
          dateEnd = picked;
          _endDateController.text = '${dateEnd!.toLocal()}'.split(' ')[0];
        }
      });
    }
  }
  void generatePrices() {
    final double baseValue = double.tryParse(_valueController.text) ?? 0.0;
    final DateTime? startDate = dateStart;
    final DateTime? endDate = dateEnd;

    final List<Price> prices = [];
    final Map<String, double> sizePrices = {};
    final Map<String, double> coverPrices = {};

    for (var size in widget.photoBook.size) {
      final priceForSize =
          double.tryParse(_sizeControllers[size.name]?.text ?? '0') ?? 0.0;
      final pageValueForSize =
          double.tryParse(_coverControllers[size.name]?['page']?.text ?? '0') ??
              0.0;

      sizePrices[size.name] = priceForSize;

      for (var coverFinish in widget.photoBook.coverFinish) {
        final coverPrice = double.tryParse(
            _coverControllers[size.name]?[coverFinish.name]?.text ?? '0') ??
            0.0;
        coverPrices[coverFinish.name] = coverPrice;


        DocumentReference docRef =
        FirebaseFirestore.instance.collection('photoBooks').doc();
        prices.add(Price(
          id: docRef.id, // You may want to set a unique ID for each entry
          size: size,
          coverFinish: coverFinish,
          dateStart: startDate,
          dateEnd: endDate,
          pagePrice: pageValueForSize,
          value: baseValue,
          sizePrice: priceForSize,
          coverPrice: baseValue,
        ));
      }
    }

    FirebaseFirestore.instance
        .collection('photoBooks')
        .doc(widget.photoBook.id)
        .update({
      'price': prices.map((price) => price.toMap()).toList(),
    }).then((_) {
      Navigator.pop(context);
    }).catchError((error) {
      print('Failed to update photo book: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update photo book: $error')),
      );
    });

    // Print the list of prices
    for (var price in prices) {
      print(price.toString());
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.photoBook.title),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: TabBar(
            controller: _tabController,
            isScrollable: true, // Allow horizontal scrolling
            tabs: const [
              Tab(text: 'Price'),
              Tab(text: 'Cover Image'),
              Tab(text: 'Borders'),
              Tab(text: 'Miniature'),
              Tab(text: 'Description'),
              Tab(text: 'Size'),
              Tab(text: 'Printing Time'),
              Tab(text: 'Flip Book'),
              Tab(text: 'Cover Finish'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          showListPrice ? _buildListPrice() : _buildPriceTab(),
          _buildImageTab('Cover Image', widget.photoBook.coverImageUrl, 'coverImageUrl'),
          _buildImageTab('Borders', widget.photoBook.borders, 'borders'),
          _buildImageTab('Miniature', widget.photoBook.miniature, 'miniature'),       // Miniature image selection
          _buildDetailTab('Description: ${widget.photoBook.description}'),
          _buildDetailTab('Size: ${widget.photoBook.size}'),
          _buildDetailTab('Printing Time: ${widget.photoBook.printingTime} days'),

          PageDetailWidget(
            pages: widget.photoBook.pages, // Ensure correct casting
            numberPageInitial: widget.photoBook.numberPageInitial,
            photobookId : widget.photoBook.id
          ),


          _buildCoverFinishTab(),
        ],
      ),
    );
  }



  List<Layout> templates = [


  ];





  Widget _buildImageTab(String label, String imageUrl, String firestoreField) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(label),
        ),
        ImageSelector(
          initialImageUrl: imageUrl, // Pass the dynamic image URL here
          onImageSaved: (newImageUrl) {
            setState(() {
              // Update the corresponding photoBook field with the new image URL
              imageUrl = newImageUrl; // Update dynamically based on the tab

              // Update the Firestore document with the correct field name
              FirebaseFirestore.instance
                  .collection('photoBooks')
                  .doc(widget.photoBook.id)
                  .update({
                firestoreField: newImageUrl, // Use the Firestore field name
              }).then((_) {
                print("Firestore updated successfully");
              }).catchError((error) {
                print("Failed to update Firestore: $error");
              });
            });
          },
        ),
      ],
    );
  }



  Widget _buildPriceTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child:

      Form(
        key: _formKey, // Assign the form key here
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _valueController,
                      decoration: const InputDecoration(
                        labelText: 'Value',
                        border: OutlineInputBorder(),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Value is required';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        // Save the value if needed
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _startDateController,
                            decoration: const InputDecoration(
                              labelText: 'Select Start Date',
                              border: OutlineInputBorder(),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              ),
                            ),
                            readOnly: true,
                            onTap: () =>
                                _selectDate(context, isStartDate: true),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _endDateController,
                            decoration: const InputDecoration(
                              labelText: 'Select End Date',
                              border: OutlineInputBorder(),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              ),
                            ),
                            readOnly: true,
                            onTap: () =>
                                _selectDate(context, isStartDate: false),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ...widget.photoBook.size.map((size) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Size: $size',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),

                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _sizeControllers[size.name],
                        decoration: InputDecoration(
                          labelText: 'Price for size $size',
                          border: const OutlineInputBorder(),
                          errorBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Price for size $size is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _pageControllers[size.name],
                        decoration: InputDecoration(
                          labelText: 'Page value for size $size',
                          border: const OutlineInputBorder(),
                          errorBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Page value for size $size is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'Cover for size : $size',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),

                      const SizedBox(height: 10),
                      Row(
                        children: widget.photoBook.coverFinish.map((coverFinish) {
                          final coverFinishController =
                          _coverControllers[size.name]?[coverFinish.name];
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: TextFormField(
                                controller: coverFinishController,
                                decoration: InputDecoration(
                                  labelText: 'Cover value for ${coverFinish.name}',
                                  border: const OutlineInputBorder(),
                                  errorBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.red),
                                  ),
                                  focusedErrorBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.red),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Cover value for ${coverFinish.name} is required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      )
                    ],
                  ),
                );
              }),

              ElevatedButton(
                onPressed: () {
                  final formState = _formKey.currentState;

                  // Validate the form and check if it's valid
                  bool isValid = formState?.validate() ?? false;

                  if (isValid) {
                    formState?.save();

                    // Convert date strings to DateTime
                    DateTime? startDate = _startDateController.text.isNotEmpty
                        ? DateTime.tryParse(_startDateController.text)
                        : null;
                    DateTime? endDate = _endDateController.text.isNotEmpty
                        ? DateTime.tryParse(_endDateController.text)
                        : null;

                    // Convert base value to double
                    double baseValue =
                        double.tryParse(_valueController.text) ?? 0.0;

                    // Prepare the list of prices
                    List<Price> prices = [];

                    for (var size in widget.photoBook.size) {
                      final sizePriceString = _sizeControllers[size.name]?.text;
                      final pageValueForSizeString =
                          _pageControllers[size.name]?.text;

                      // Convert size and page values to double with default value
                      double sizePrice = sizePriceString?.isNotEmpty == true
                          ? double.tryParse(sizePriceString!) ?? baseValue
                          : baseValue;
                      double pageValueForSize =
                      pageValueForSizeString?.isNotEmpty == true
                          ? double.tryParse(pageValueForSizeString!) ??
                          baseValue
                          : baseValue;

                      for (var coverFinish in widget.photoBook.coverFinish) {
                        final coverValueString = _coverControllers[size.name]
                        ?[coverFinish.name]
                            ?.text;

                        // Convert cover value to double with default value
                        double coverValue = coverValueString?.isNotEmpty == true
                            ? double.tryParse(coverValueString!) ?? baseValue
                            : baseValue;

                        // Generate unique document ID for each price entry
                        DocumentReference docRef = FirebaseFirestore.instance
                            .collection('photoBooks')
                            .doc();

                        // Create the price object
                        Price price = Price(
                          id: docRef.id,
                          size: size,
                          coverFinish: coverFinish,
                          dateStart: startDate,
                          dateEnd: endDate,
                          pagePrice: pageValueForSize,
                          value:
                          baseValue, // Use baseValue as a fallback for value
                          sizePrice: sizePrice,
                          coverPrice: coverValue,
                        );

                        // Add the price object to the list of prices
                        prices.add(price);
                      }
                    }

                    // Update the photo book document with the list of prices
                    FirebaseFirestore.instance
                        .collection('photoBooks')
                        .doc(widget.photoBook.id)
                        .update({
                      'price': prices.map((price) => price.toMap()).toList(),
                    }).then((_) async {


                      setState(() {
                        showListPrice = !showListPrice;

                      });
                      await fetchTemplate(widget.photoBook.id);
                    }).catchError((error) {
                      print('Failed to update photo book: $error');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                            Text('Failed to update photo book: $error')),
                      );
                    });
                  } else {
                    // Collect and print errors manually
                    print('Validation Errors:');
                    if (_startDateController.text.isEmpty) {
                      print('Start Date is required.');
                    }
                    if (_endDateController.text.isEmpty) {
                      print('End Date is required.');
                    }
                    if (_valueController.text.isEmpty) {
                      print(
                          'Value is required.'); // Print error if value is missing
                    }

                    for (var size in widget.photoBook.size) {
                      final sizeController = _sizeControllers[size.name];
                      if (sizeController?.text.isEmpty ?? true) {
                        print('Price for size $size is required.');
                      }

                      final pageController = _pageControllers[size.name];
                      if (pageController?.text.isEmpty ?? true) {
                        print('Page value for size $size is required.');
                      }

                      final coverFinishControllers =
                      _coverControllers[size.name];
                      if (coverFinishControllers != null) {
                        for (var coverFinish in widget.photoBook.coverFinish) {
                          final coverFinishController =
                          coverFinishControllers[coverFinish.name];
                          if (coverFinishController?.text.isEmpty ?? true) {
                            print(
                                'Cover value for ${coverFinish.name} in size $size is required.');
                          }
                        }
                      }
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50), // Width to fill the screen and height of 50
                ),
                child: const Text('Submit'),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailTab(String content) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        content,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildFlipBookTab() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(15.0),
        padding: const EdgeInsets.all(3.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blueAccent),
        ),
        child: SizedBox(
          width: 300,  // Set a fixed size
          height: 300, // Keep height equal to width
          child: PageFlipWidget(
            key: _controller,
            backgroundColor: Colors.white,
            lastPage: Container(
              color: Colors.white,
              child: const Center(child: Text('Last Page!')),
            ),
            children: List.generate(
              36,
                  (index) => DemoPage(page: index),
            ),
          ),
        ),
      ),
    );
  }




  Widget _buildCoverFinishTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: widget.photoBook.coverFinish.length,
      itemBuilder: (context, index) {
        final coverFinish = widget.photoBook.coverFinish[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          child: ListTile(
            title: Text(coverFinish.name),
            subtitle: Text('Description: ${coverFinish.description}'),
          ),
        );
      },
    );
  }

  Widget _buildListPrice() {


    fetchTemplate(widget.photoBook.id).then((fetchedTemplate) {
      if (fetchedTemplate != null) {
        setState(() {
          _photoBook = fetchedTemplate;

        });
      }
    });

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  showListPrice = !showListPrice;
                });
              },
              child: Text('Edit'),
            ),
          ),
        ),
        if (_photoBook?.price != null) // Check if price list is not null
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _photoBook!.price.length, // Safe to use `!` after checking for null
              itemBuilder: (context, index) {
                final price = _photoBook!.price[index]; // Also safe to use `!`
                if (price == null) {
                  return SizedBox.shrink(); // Return an empty widget if price is null
                }
                double bookprice = price.value + price.coverPrice + price.sizePrice;
                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: ListTile(
                    title: Text(
                      'Price for size ${price.size.name} and cover ${price.coverFinish.name} : \$${bookprice.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 14.0),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );


  }




}


Future<Template?> fetchTemplate(String photoBookId) async {
  try {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('photoBooks')
        .doc(photoBookId)
        .get();

    if (doc.exists) {
      // Parse the document data to a Template object
      return Template.fromMap(doc.data() as Map<String, dynamic>);
    } else {
      print('Template with id $photoBookId not found.');
      return null;
    }
  } catch (e) {
    print('Error fetching Template: $e');
    return null;
  }
}

