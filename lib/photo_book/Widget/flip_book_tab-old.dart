// import 'package:flutter/material.dart';
// import 'package:heritage/photo_book/models/layout.dart';
// import '../models/zone.dart';
//
// // Updated buildFlipBookTab to display multiple pages with different templates
// Widget buildFlipBookTab(List<Layout> templates) {
//   return PageView.builder(
//     itemCount: templates.length, // Set the number of pages based on the templates list
//     itemBuilder: (context, index) {
//       final template = templates[index]; // Get the current CollageTemplate
//       return Center(
//         child: Container(
//           margin: const EdgeInsets.all(15.0), // Adds margin around the container
//           padding: const EdgeInsets.all(3.0), // Adds padding inside the container
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.blueAccent), // Border style for the container
//           ),
//           child: SizedBox(
//             width: 400, // Sets a fixed width for the collage container
//             height: 400, // Sets a fixed height for the collage container
//             child: Padding(
//               padding: EdgeInsets.all(template.margin), // Padding based on the template's margin
//               child: Column(
//                 children: template.zones.map((zone) {
//                   return Container(
//                     width: (zone.widthPercent * 400) / 100, // Width based on zone's percentage
//                     height: (zone.heightPercent * 400) / 100, // Height based on zone's percentage
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.blueAccent), // Border for the zone container
//                       color: zone.isEmpty ? Colors.grey[400] : null, // Gray background if zone is empty
//                       image: zone.isEmpty
//                           ? null // No image if zone is empty
//                           : DecorationImage(
//                         image: NetworkImage(
//                           zone.photo ?? 'https://via.placeholder.com/200', // Default photo if zone.photo is null
//                         ),
//                         fit: BoxFit.cover, // Cover to fill the zone area
//                       ),
//                     ),
//                     child: zone.isEmpty
//                         ? Center(child: Text('Zone ${zone.id}')) // Placeholder text for empty zones
//                         : null, // No child widget if zone contains an image
//                   );
//                 }).toList(), // Converts the zones to a list of widgets
//               ),
//             ),
//           ),
//         ),
//       );
//
//
//
//     },
//   );
// }
