import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:page_flip/page_flip.dart';

import '../models/photo_book.dart';
import '../Widget/demo_page.dart';
import '../models/price.dart';

class PhotoBookDetailScreen extends StatefulWidget {
  final PhotoBook photoBook;

  const PhotoBookDetailScreen({Key? key, required this.photoBook}) : super(key: key);

  @override
  _PhotoBookDetailScreenState createState() => _PhotoBookDetailScreenState();
}

class _PhotoBookDetailScreenState extends State<PhotoBookDetailScreen> with SingleTickerProviderStateMixin {
  final _controller = GlobalKey<PageFlipWidgetState>();
  File? _imageFile;
  Widget? _imagePreview;
  bool _isUploading = false; // Track the upload state
  late TabController _tabController;

  DateTime? dateStart;
  DateTime? dateEnd;
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  late TextEditingController _valueController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final Map<String, TextEditingController> _sizeControllers = {};
  final Map<String, Map<String, TextEditingController>> _coverControllers = {};
  final Map<String, TextEditingController> _pageControllers = {};


  @override
  void initState() {
    super.initState();
    _loadInitialImage();
    _tabController = TabController(length: 8, vsync: this);

    // Set default dates: start as today and end as one year later
    dateStart = DateTime.now();
    dateEnd = DateTime.now().add(const Duration(days: 365));

    _startDateController.text = '${dateStart!.toLocal()}'.split(' ')[0];
    _endDateController.text = '${dateEnd!.toLocal()}'.split(' ')[0];

    // Set default value to 0
    _valueController.text = '0';

    // // Initialize controllers for sizes, covers, and pages
    // for (var size in widget.photoBook.size) {
    //   _sizeControllers[size.name] = TextEditingController(text: '0');
    //   _pageControllers[size.name] = TextEditingController(text: '0'); // Initialize page controllers
    //   _coverControllers[size.name] = {};
    //   for (var coverFinish in widget.photoBook.coverFinish) {
    //     _coverControllers[size.name]![coverFinish.name] = TextEditingController(text: '0');
    //   }
    // }
    // price printing test
    if (widget.photoBook.price.isEmpty) {
      // Initialize controllers with '0' if there are no prices
      for (var size in widget.photoBook.size) {
        _sizeControllers[size.name] = TextEditingController(text: '0');
        _pageControllers[size.name] = TextEditingController(text: '0'); // Initialize page controllers
        _coverControllers[size.name] = {};
        for (var coverFinish in widget.photoBook.coverFinish) {
          _coverControllers[size.name]![coverFinish.name] = TextEditingController(text: '0');
        }
      }
      // Initialize _valueController with '0' if no prices
      _valueController = TextEditingController(text: '0');
    } else {
      // Populate controllers with price data
      for (var price in widget.photoBook.price) {
        // Print price details to the terminal
        print('-----------------------------');
        print('Price ID: ${price.id}');
        print('Size: ${price.size.name}');
        print('Cover Finish: ${price.coverFinish.name}');
        print('Date Start: ${price.dateStart}');
        print('Date End: ${price.dateEnd}');
        print('Page Price: ${price.pagePrice}');
        print('Value: ${price.value}');
        print('Size Price: ${price.sizePrice}');
        print('Cover Price: ${price.coverPrice}');
        print('-----------------------------');

        // Populate the controllers with the corresponding values
        _sizeControllers[price.size.name] = TextEditingController(text: price.sizePrice.toString());
        _pageControllers[price.size.name] = TextEditingController(text: price.pagePrice.toString()); // Set page price controller
        if (_coverControllers[price.size.name] == null) {
          _coverControllers[price.size.name] = {};
        }
        _coverControllers[price.size.name]![price.coverFinish.name] = TextEditingController(text: price.coverPrice.toString());

        // Set _valueController with the value from the last price entry
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
    _coverControllers.values.expand((map) => map.values).forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _loadInitialImage() {
    setState(() {
      _imagePreview = widget.photoBook.coverImageUrl.isNotEmpty
          ? CachedNetworkImage(
        imageUrl: widget.photoBook.coverImageUrl,
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      )
          : Image.asset('assets/logo.png'); // Replace with your default image asset path
    });
  }

  Future<void> _updateCoverImageUrl() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _imagePreview = Image.file(_imageFile!);
        _isUploading = true; // Start uploading
      });

      if (_imageFile != null) {
        firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('photobook_cover_images')
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
        await ref.putFile(_imageFile!);
        String imageUrl = await ref.getDownloadURL();

        try {
          await FirebaseFirestore.instance
              .collection('photoBooks')
              .doc(widget.photoBook.id)
              .update({'coverImageUrl': imageUrl});

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cover image updated successfully')),
          );

          setState(() {
            _imagePreview = CachedNetworkImage(
              imageUrl: imageUrl,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            );
            _isUploading = false; // End uploading
          });
        } catch (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update Firestore: $error')),
          );
          setState(() {
            _isUploading = false; // End uploading in case of error
          });
        }
      }
    }
  }

  Future<void> _selectDate(BuildContext context, {required bool isStartDate}) async {
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
              Tab(text: 'Description'),
              Tab(text: 'Size'),
              Tab(text: 'Miniature'),
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
          _buildPriceTab(),
          _buildCoverImageTab(),
          _buildDetailTab('Description: ${widget.photoBook.description}'),
          _buildDetailTab('Size: ${widget.photoBook.size}'),
          _buildDetailTab('Miniature: ${widget.photoBook.miniature}'),
          _buildDetailTab('Printing Time: ${widget.photoBook.printingTime} days'),
          _buildFlipBookTab(),
          _buildCoverFinishTab(),
        ],
      ),
    );
  }

  Widget _buildCoverImageTab() {
    return Column(
      children: [
        Expanded(
          child: Center(child: _imagePreview ?? const SizedBox.shrink()),
        ),
        if (_imagePreview != null) _buildImageThumbnail(),
      ],
    );
  }



  Widget _buildPriceTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
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
                            onTap: () => _selectDate(context, isStartDate: true),
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
                            onTap: () => _selectDate(context, isStartDate: false),
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
                      ...widget.photoBook.coverFinish.map((coverFinish) {
                        final coverFinishController =
                        _coverControllers[size.name]?[coverFinish.name];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cover Finish: ${coverFinish.name}',
                              style: const TextStyle(fontSize: 14.0),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
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
                            const SizedBox(height: 10),
                          ],
                        );
                      }),
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
                    DateTime? startDate = _startDateController.text.isNotEmpty ? DateTime.tryParse(_startDateController.text) : null;
                    DateTime? endDate = _endDateController.text.isNotEmpty ? DateTime.tryParse(_endDateController.text) : null;

                    // Convert base value to double
                    double baseValue = double.tryParse(_valueController.text) ?? 0.0;

                    // Prepare the list of prices
                    List<Price> prices = [];

                    for (var size in widget.photoBook.size) {
                      final sizePriceString = _sizeControllers[size.name]?.text;
                      final pageValueForSizeString = _pageControllers[size.name]?.text;

                      // Convert size and page values to double with default value
                      double sizePrice = sizePriceString?.isNotEmpty == true ? double.tryParse(sizePriceString!) ?? baseValue : baseValue;
                      double pageValueForSize = pageValueForSizeString?.isNotEmpty == true ? double.tryParse(pageValueForSizeString!) ?? baseValue : baseValue;

                      for (var coverFinish in widget.photoBook.coverFinish) {
                        final coverValueString = _coverControllers[size.name]?[coverFinish.name]?.text;

                        // Convert cover value to double with default value
                        double coverValue = coverValueString?.isNotEmpty == true ? double.tryParse(coverValueString!) ?? baseValue : baseValue;

                        // Generate unique document ID for each price entry
                        DocumentReference docRef = FirebaseFirestore.instance.collection('photoBooks').doc();

                        // Create the price object
                        Price price = Price(
                          id: docRef.id,
                          size: size,
                          coverFinish: coverFinish,
                          dateStart: startDate,
                          dateEnd: endDate,
                          pagePrice: pageValueForSize,
                          value: baseValue, // Use baseValue as a fallback for value
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
                    })
                        .then((_) {
                      Navigator.pop(context);
                    })
                        .catchError((error) {
                      print('Failed to update photo book: $error');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to update photo book: $error')),
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
                      print('Value is required.'); // Print error if value is missing
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

                      final coverFinishControllers = _coverControllers[size.name];
                      if (coverFinishControllers != null) {
                        for (var coverFinish in widget.photoBook.coverFinish) {
                          final coverFinishController =
                          coverFinishControllers[coverFinish.name];
                          if (coverFinishController?.text.isEmpty ?? true) {
                            print('Cover value for ${coverFinish.name} in size $size is required.');
                          }
                        }
                      }
                    }
                  }
                },
                child: const Text('Submit'),
              ),





            ],
          ),
        ),
      ),
    );
  }



  void generatePrices() {
    final double baseValue = double.tryParse(_valueController.text) ?? 0.0;
    final DateTime? startDate = dateStart;
    final DateTime? endDate = dateEnd;

    final List<Price> prices = [];
    final Map<String, double> sizePrices = {};
    final Map<String, double> coverPrices = {};

    for (var size in widget.photoBook.size) {
      final priceForSize = double.tryParse(_sizeControllers[size.name]?.text ?? '0') ?? 0.0;
      final pageValueForSize = double.tryParse(_coverControllers[size.name]?['page']?.text ?? '0') ?? 0.0;

      sizePrices[size.name] = priceForSize;

      for (var coverFinish in widget.photoBook.coverFinish) {
        final coverPrice = double.tryParse(_coverControllers[size.name]?[coverFinish.name]?.text ?? '0') ?? 0.0;
        coverPrices[coverFinish.name] = coverPrice;

        final totalPrice = baseValue + priceForSize  + coverPrice;
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
          sizePrice : priceForSize,
          coverPrice : baseValue,


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
    return Container(
      margin: const EdgeInsets.all(15.0),
      padding: const EdgeInsets.all(3.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
      ),
      child: PageFlipWidget(
        key: _controller,
        backgroundColor: Colors.white,
        lastPage: Container(
          color: Colors.white,
          child: const Center(child: Text('Last Page!')),
        ),
        children: List.generate(
          10,
              (index) => DemoPage(page: index),
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

  Widget _buildImageThumbnail() {
    return InkWell(
      onTap: _updateCoverImageUrl,
      child: Container(
        margin: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: _isUploading
            ? const CircularProgressIndicator() // Show progress indicator during upload
            : const Icon(Icons.camera_alt, size: 30), // Show camera icon
      ),
    );
  }
}
