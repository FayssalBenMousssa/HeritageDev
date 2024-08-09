import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heritage/photo_book/models/size.dart';
import 'package:heritage/photo_book/models/price.dart';

class AddPriceScreen extends StatelessWidget {
  const AddPriceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Price'),
      ),
      body: const AddPriceForm(),
    );
  }
}

class AddPriceForm extends StatefulWidget {
  const AddPriceForm({super.key});

  @override
  AddPriceFormState createState() => AddPriceFormState();
}

class AddPriceFormState extends State<AddPriceForm> {
  final _formKey = GlobalKey<FormState>();
  int? id;
  Size? selectedSize;
  DateTime? datestart;
  DateTime? dateEnd;
  double coverPrice = 0.0;
  double pagePrice = 0.0;
  double basePrice = 0.0;

  // Method to handle date selection
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
          datestart = picked;
        } else {
          dateEnd = picked;
        }
      });
    }
  }

  void _addPrice(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Price newPrice = Price(
        id: id!,
        size: selectedSize!,
        datestart: datestart,
        dateEnd: dateEnd,
        coverPrice: coverPrice,
        pagePrice: pagePrice,
        basePrice: basePrice,
      );

      Map<String, dynamic> priceData = newPrice.toMap();

      FirebaseFirestore.instance.collection('prices').add(priceData).then((docRef) {
        // Update the ID of the newly added price
        String priceId = docRef.id;
        FirebaseFirestore.instance.collection('prices').doc(priceId).update({'id': priceId});

        // Show Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Price added'))
        );

        // Navigate back to the list of prices
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'ID'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'ID is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  id = int.tryParse(value!);
                },
              ),
              DropdownButtonFormField<Size>(
                decoration: const InputDecoration(labelText: 'Size'),
                value: selectedSize,
                onChanged: (value) {
                  setState(() {
                    selectedSize = value;
                  });
                },
                items: _buildSizeDropdownItems(),
                validator: (value) {
                  if (value == null) {
                    return 'Size is required';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: datestart == null
                            ? 'Select Start Date'
                            : 'Start Date: ${datestart!.toLocal()}'.split(' ')[0],
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context, isStartDate: true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: dateEnd == null
                            ? 'Select End Date'
                            : 'End Date: ${dateEnd!.toLocal()}'.split(' ')[0],
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context, isStartDate: false),
                    ),
                  ),
                ],
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Cover Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Cover Price is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  coverPrice = double.tryParse(value!)!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Page Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Page Price is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  pagePrice = double.tryParse(value!)!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Base Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Base Price is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  basePrice = double.tryParse(value!)!;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _addPrice(context),
                child: const Text('Add Price'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<Size>> _buildSizeDropdownItems() {
    // Populate this list with your actual Size objects.
    List<Size> sizes = [
      Size(name: 'Small', dimensions: ''),
      Size(name: 'Medium', dimensions: ''),
      Size(name: 'Large', dimensions: ''),
    ];

    return sizes.map((size) {
      return DropdownMenuItem<Size>(
        value: size,
        child: Text(size.name),
      );
    }).toList();
  }
}
