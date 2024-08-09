
import 'package:heritage/photo_book/models/size.dart';

class Price {
  final int id;
  final Size size;
  final DateTime? datestart;
  final DateTime? dateEnd;
  final double coverPrice;
  final double pagePrice;
  final double basePrice;

  Price({
    required this.id,
    required this.size,
    required this.datestart,
    required this.dateEnd,
    required this.coverPrice,
    required this.pagePrice,
    required this.basePrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'size': size.toMap(), // Assuming Size class has a toMap() method
      'datestart': datestart,
      'dateEnd': dateEnd,
      'coverPrice': coverPrice,
      'pagePrice': pagePrice,
      'basePrice': basePrice,
    };
  }

  static Price fromMap(Map<String, dynamic> map) {
    return Price(
      id: map['id'] ?? 0,
      size: Size.fromMap(map['size'] ?? {}), // Assuming Size class has a fromMap() method
      datestart: DateTime.parse(map['datestart'] ?? ''),
      dateEnd: DateTime.parse(map['dateEnd'] ?? ''),
      coverPrice: map['coverPrice'] ?? 0.0,
      pagePrice: map['pagePrice'] ?? 0.0,
      basePrice: map['basePrice'] ?? 0.0,
    );
  }
}
