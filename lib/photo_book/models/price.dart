
import 'package:heritage/photo_book/models/cover_finish.dart';
import 'package:heritage/photo_book/models/size.dart';

class Price {
  final int id;
  final Size size;
  final CoverFinish coverFinish;
  final DateTime? dateStart;
  final DateTime? dateEnd;
  final double pagePrice;
  final double value;

  Price({required this.id, required this.size, required this.coverFinish, required this.dateStart, required this.dateEnd,  required this.pagePrice, required this.value});






  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'size': size.toMap(), // Assuming Size class has a toMap() method
      'dateStart': dateStart,
      'dateEnd': dateEnd,
      'pagePrice': pagePrice,
      'basePrice': value,
    };
  }

  static Price fromMap(Map<String, dynamic> map) {
    return Price(
      id: map['id'] ?? 0,
      size: Size.fromMap(map['size'] ?? {}), // Assuming Size class has a fromMap() method
      dateStart: DateTime.parse(map['datestart'] ?? ''),
      dateEnd: DateTime.parse(map['dateEnd'] ?? ''),
      pagePrice: map['pagePrice'] ?? 0.0,
      value: map['value'] ?? 0.0,
      coverFinish: CoverFinish.fromMap(map['coverFinish'] ?? {})
    );
  }
}
