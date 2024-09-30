

import 'zone.dart';

class Layout {
  final String name; // Name of the collage template
  final String description;
  final double margin;
  //final List<Zone> zones;
  final String miniatureImage; // Path or URL to miniature image preview

  Layout({
    required this.name,
    required this.description,
    required this.margin,
    //required this.zones,
    required this.miniatureImage,
  });

  // Convert Layout object to a map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'margin': margin,
      //'zones': zones.map((zone) => zone.toMap()).toList(), // Ensure each Zone is converted to a map
      'miniatureImage': miniatureImage,
    };
  }

  // Create a Layout object from a map
  static Layout fromMap(Map<String, dynamic> map) {
    return Layout(
      name: map['name'] ?? '', // Assign default value if not present
      description: map['description'] ?? '',
      margin: map['margin']?.toDouble() ?? 0.0, // Ensure margin is a double
     // zones: (map['zones'] as List<dynamic>?)
      //    ?.map((zoneMap) => Zone.fromMap(zoneMap as Map<String, dynamic>))
         // .toList() ?? [],
      miniatureImage: map['miniatureImage'] ?? '',
    );
  }
}



/*
List<Layout> layouts = [
  Layout(
    name: '50x25x25',
    description: 'A template for family photos with three zones.',
    margin: 1.0,
    zones: [
      Zone(id: 1, heightPercent: 50, widthPercent: 100, isEmpty: false, photo: 'https://via.placeholder.com/200'),
      Zone(id: 2, heightPercent: 25, widthPercent: 100, isEmpty: false, photo: 'https://via.placeholder.com/200'),
      Zone(id: 3, heightPercent: 24, widthPercent: 100, isEmpty: false, photo: 'https://via.placeholder.com/200'),
    ],
    miniatureImage: 'https://via.placeholder.com/50',
  ),
  Layout(
    name: '50x50',
    description: 'A template for family photos with three zones.',
    margin: 1.0,
    zones: [
      Zone(id: 1, heightPercent: 50, widthPercent: 100, isEmpty: false, photo: 'https://via.placeholder.com/200'),
      Zone(id: 2, heightPercent: 50, widthPercent: 100, isEmpty: false, photo: 'https://via.placeholder.com/200')
    ],
    miniatureImage: 'https://via.placeholder.com/50',
  ),
  Layout(
    name: '50x25x50',
    description: 'A template for family photos with three zones.',
    margin: 1.0,
    zones: [
      Zone(id: 1, heightPercent: 25, widthPercent: 100, isEmpty: false, photo: 'https://via.placeholder.com/200'),
      Zone(id: 2, heightPercent: 50, widthPercent: 100, isEmpty: false, photo: 'https://via.placeholder.com/200'),
      Zone(id: 3, heightPercent: 25, widthPercent: 100, isEmpty: false, photo: 'https://via.placeholder.com/200'),
    ],
    miniatureImage: 'https://via.placeholder.com/50',
  )

];*/