import 'package:heritage/photo_book/models/book_form.dart';
import 'package:heritage/photo_book/models/book_type.dart';
import 'package:heritage/photo_book/models/category.dart';
import 'package:heritage/photo_book/models/cover_finish.dart';
import 'package:heritage/photo_book/models/page.dart';
import 'package:heritage/photo_book/models/paper_finish.dart';
import 'package:heritage/photo_book/models/price.dart';
import 'package:heritage/photo_book/models/size.dart';

import 'dart:convert';

class Template {
  final String id;
  final List<Page> pages;
  final String title;
  final List<BookForm> formBook;
  final String description;
  final List<BookType> type;
  final List<Size> size;
  final List<PaperFinish> paperFinish;
  final List<CoverFinish> coverFinish;
  final List<Price> price;
  final String miniature;
  final double printingTime;
  final List<Category> categories;
  final int numberPageInitial;
  String coverImageUrl;
  String borders;

  Template({
    required this.id,
    required this.pages,
    required this.title,
    required this.formBook,
    required this.description,
    required this.type,
    required this.size,
    required this.paperFinish,
    required this.coverFinish,
    required this.price,
    required this.miniature,
    required this.printingTime,
    required this.categories,
    required this.coverImageUrl,
    required this.borders,
    this.numberPageInitial = 36,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pages': pages.map((page) => page.toMap()).toList(),
      'title': title,
      'formBook': formBook.map((form) => form.toMap()).toList(),
      'description': description,
      'type': type.map((t) => t.toMap()).toList(),
      'size': size.map((s) => s.toMap()).toList(),
      'paperFinish': paperFinish.map((pf) => pf.toMap()).toList(),
      'coverFinish': coverFinish.map((cf) => cf.toMap()).toList(),
      'price': price.map((p) => p.toMap()).toList(),
      'miniature': miniature,
      'printingTime': printingTime,
      'categories': categories.map((category) => category.toMap()).toList(),
      'coverImageUrl': coverImageUrl,
      'borders': borders,
      'numberPageInitial': numberPageInitial,
    };
  }

  static Template fromMap(Map<String, dynamic> map) {
    try {
      return Template(
        id: map['id'] as String,
        pages: (map['pages'] as List).map((page) => Page.fromMap(page)).toList(),
        title: map['title'] ?? '',
        formBook: (map['formBook'] as List).map((form) => BookForm.fromMap(form)).toList(),
        description: map['description'] ?? '',
        type: (map['type'] as List).map((t) => BookType.fromMap(t)).toList(),
        size: (map['size'] as List).map((s) => Size.fromMap(s)).toList(),
        paperFinish: (map['paperFinish'] as List).map((pf) => PaperFinish.fromMap(pf)).toList(),
        coverFinish: (map['coverFinish'] as List).map((cf) => CoverFinish.fromMap(cf)).toList(),
        price: (map['price'] as List).map((p) => Price.fromMap(p)).toList(),
        miniature: map['miniature'] ?? '',
        printingTime: map['printingTime'] is num ? (map['printingTime'] as num).toDouble() : 0.0,
        categories: (map['categories'] as List).map((category) => Category.fromMap(category)).toList(),
        coverImageUrl: map['coverImageUrl'] ?? '',
        borders: map['borders'] ?? '',
        numberPageInitial: map['numberPageInitial'] is num
            ? (map['numberPageInitial'] as num).toInt()
            : 0,
      );
    } catch (e) {
      print('Error creating Template from map: $e');
      throw e;
    }
  }

  // Save Template as JSON string
  String toJson() => json.encode(toMap());

  // Create Template from JSON string
  static Template fromJson(String jsonString) {
    final map = json.decode(jsonString) as Map<String, dynamic>;
    return fromMap(map);
  }

  // Save Template to Local Storage
  Future<void> saveToStorage() async {
    // Example: Save to SharedPreferences or a file
    // final prefs = await SharedPreferences.getInstance();
    // prefs.setString('template_$id', toJson());
    print('Saved template $id to storage');
  }

  // Load Template from Local Storage
  static Future<Template?> loadFromStorage(String id) async {
    // Example: Load from SharedPreferences or a file
    // final prefs = await SharedPreferences.getInstance();
    // final jsonString = prefs.getString('template_$id');
    // if (jsonString == null) return null;
    // return fromJson(jsonString);
    print('Loaded template $id from storage');
    return null;
  }
}
