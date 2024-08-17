
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heritage/photo_book/models/cover_finish.dart';
import 'package:heritage/photo_book/models/size.dart';

class Price {
  final String id;
  final Size size;
  final CoverFinish coverFinish;
  final DateTime? dateStart;
  final DateTime? dateEnd;
  final double pagePrice;
  final double value;
  final double sizePrice;
  final double coverPrice;

  Price({required this.id, required this.size, required this.coverFinish, required this.dateStart, required this.dateEnd,  required this.pagePrice,
    required this.value,
    required this.sizePrice,
    required this.coverPrice,
  });






  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'size': size.toMap(), // Assuming Size class has a toMap() method
      'coverFinish': coverFinish.toMap(),
      'dateStart': Timestamp.fromDate(dateStart!),
      'dateEnd': Timestamp.fromDate(dateEnd!),
      'pagePrice': pagePrice,
      'value': value,
      'coverPrice': coverPrice,
      'sizePrice': sizePrice,

    };
  }

  @override
  String toString() {
    return 'Price{id: $id, size: $size, coverFinish: $coverFinish, dateStart: $dateStart, dateEnd: $dateEnd, pagePrice: $pagePrice, value: $value}';
  }

  static Price fromMap(Map<String, dynamic> map) {
    return Price(
        id: map['id'] as String,
      size: Size.fromMap(map['size'] ?? {}), // Assuming Size class has a fromMap() method
      dateStart: (map['dateStart'] as Timestamp).toDate(),
      dateEnd:    (map['dateEnd'] as Timestamp).toDate(),
      pagePrice: map['pagePrice'] ?? 0.0,
      value: map['value'] ?? 0.0,
        coverPrice: map['coverPrice'] ?? 0.0,
        sizePrice: map['sizePrice'] ?? 0.0,
      coverFinish: CoverFinish.fromMap(map['coverFinish'] ?? {})
    );
  }


}
