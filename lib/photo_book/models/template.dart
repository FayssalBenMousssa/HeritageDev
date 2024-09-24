import 'package:heritage/photo_book/models/book_form.dart';
import 'package:heritage/photo_book/models/book_type.dart';
import 'package:heritage/photo_book/models/category.dart';
import 'package:heritage/photo_book/models/cover_finish.dart';
import 'package:heritage/photo_book/models/paper_finish.dart';
import 'package:heritage/photo_book/models/price.dart';
import 'package:heritage/photo_book/models/size.dart';

class Template {
  final String id;
  final List<String> pages;
  final String title;
  final List<BookForm> formBook;
  final String description;
  final List<BookType> type;
  final List<Size> size;
  final List<PaperFinish> paperFinish;
  final List<CoverFinish> coverFinish;
  final List<Price>  price;
  final String miniature;
  final double printingTime;
  final List<Category> categories;
   String coverImageUrl;
    String borders ;

  Template({
    required this.id,
    required this.pages,
    required this.title,
    required this.formBook,
    required this.description,
    required this.type,
    required this.size, // Changed from String to List<Size>
    required this.paperFinish,
    required this.coverFinish,
    required this.price,
    required this.miniature,
    required this.printingTime,
    required this.categories,
    required this.coverImageUrl,
    required this.borders,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pages': pages,
      'title': title,
      'formBook': formBook.map((f) => f.toMap()).toList(),
      'description': description,
      'type': type.map((t) => t.toMap()).toList(),
      'size': size.map((s) => s.toMap()).toList(), // Convert List<Size> to List<Map>
      'paperFinish': paperFinish.map((pf) => pf.toMap()).toList(),
      'coverFinish': coverFinish.map((cf) => cf.toMap()).toList(),
      'price': price.map((price) => price.toMap()).toList(),
      'miniature': miniature,
      'printingTime': printingTime,
      'categories': categories.map((category) => category.toMap()).toList(),
      'coverImageUrl': coverImageUrl,
      'borders': borders,
    };
  }

  static Template fromMap(Map<String, dynamic> map) {
    try {
      return Template(
        id: map['id']  as String,
        pages: List<String>.from(map['pages'] ?? []),
        title: map['title'] ?? '',
        formBook: map['formBook'] != null && map['formBook'] is List
            ? List<BookForm>.from((map['formBook'] as List).map((formBookMap) => BookForm.fromMap(formBookMap)))
            : [],
        description: map['description'] ?? '',
        type: map['type'] != null && map['type'] is List
            ? List<BookType>.from((map['type'] as List).map((typeMap) => BookType.fromMap(typeMap)))
            : [],
        size: map['size'] != null && map['size'] is List
            ? List<Size>.from((map['size'] as List).map((sizeMap) => Size.fromMap(sizeMap)))
            : [],
        paperFinish: map['paperFinish'] != null && map['paperFinish'] is List
            ? List<PaperFinish>.from((map['paperFinish'] as List).map((pfMap) => PaperFinish.fromMap(pfMap)))
            : [],
        coverFinish: map['coverFinish'] != null && map['coverFinish'] is List
            ? List<CoverFinish>.from((map['coverFinish'] as List).map((cfMap) => CoverFinish.fromMap(cfMap)))
            : [],
        price: map['price'] != null && map['price'] is List
            ? List<Price>.from((map['price'] as List).map((priceMap) => Price.fromMap(priceMap)))
            : [],



        miniature: map['miniature'] ?? '', // Handle as String
        printingTime: map['printingTime'] is num ? (map['printingTime'] as num).toDouble() : 0.0,

        // Handle conversion to double
        categories: map['categories'] != null && map['categories'] is List
            ? List<Category>.from((map['categories'] as List).map((categoryMap) => Category.fromMap(categoryMap)))
            : [],


        coverImageUrl: map['coverImageUrl'] ?? '',
        borders: map['borders'] ?? '',
      );
    } catch (e) {
      print('Error creating Template from map: $e');
      throw e; // or handle the error as needed
    }
  }
}
