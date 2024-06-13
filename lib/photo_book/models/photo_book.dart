import 'package:heritage/photo_book/models/category.dart';
import 'package:heritage/photo_book/models/page.dart';

class PhotoBook {
  final int id;
  final List<Page> pages;
  final String title;
  final String form;
  final String description;
  final String type;
  final String size;
  final String paperFinish;
  final String coverFinish;
  final double price;
  final double miniature;
  final double printingTime;
  final List<Category> categories;

  PhotoBook({
    required this.id,
    required this.pages,
    required this.title,
    required this.form,
    required this.description,
    required this.type,
    required this.size,
    required this.paperFinish,
    required this.coverFinish,
    required this.price,
    required this.miniature,
    required this.printingTime,
    required this.categories,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pages': pages.map((page) => page.toMap()).toList(),
      'title': title,
      'form': form,
      'description': description,
      'type': type,
      'size': size,
      'paperFinish': paperFinish,
      'coverFinish': coverFinish,
      'price': price,
      'miniature': miniature,
      'printingTime': printingTime,
      'categories': categories.map((category) => category.toMap()).toList(),
    };
  }

  factory PhotoBook.fromMap(Map<String, dynamic> map) {
    return PhotoBook(
      id: map['id'],
      pages: List<Page>.from(
          map['pages']?.map((page) => Page.fromMap(page)) ?? []),
      title: map['title'] ?? '',
      form: map['form'] ?? '',
      description: map['description'] ?? '',
      type: map['type'] ?? '',
      size: map['size'] ?? '',
      paperFinish: map['paperFinish'] ?? '',
      coverFinish: map['coverFinish'] ?? '',
      price: map['price'] ?? 0.0,
      miniature: map['miniature'] ?? 0.0,
      printingTime: map['printingTime'] ?? 0.0,
      categories: List<Category>.from(
          map['categories']?.map((category) => Category.fromMap(category)) ??
              []),
    );
  }
}
