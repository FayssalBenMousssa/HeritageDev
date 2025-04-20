import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:heritage/photo_book/models/zone.dart';
import '../../models/layout.dart';
import '../../models/page.dart';
import 'edit_page_screen.dart';
import '../../models/page.dart' as custom_page;
class LayoutWidget extends StatelessWidget {
  final Layout layout;
  final String backgroundUrl;
  final Function(int zoneIndex, Layout layout) onImageTap;
  final bool isEditable;

  const LayoutWidget({
    Key? key,
    required this.layout,
    required this.backgroundUrl,
    required this.onImageTap,
    required this.isEditable,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final layoutSize = _calculateLayoutSize(layout);
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          width: layoutSize.width + 12,
          height: layoutSize.height + 12,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: backgroundUrl.isNotEmpty
                  ? NetworkImage(backgroundUrl)
                  : const AssetImage('assets/placeholder.jpg') as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: layout.zones.map((zone) {
              return Positioned(
                left: zone.left,
                top: zone.top,
                width: zone.width,
                height: zone.height,
                child: Container(
                  margin: const EdgeInsets.all(8.0),
                  child: _buildInteractiveZone(context, zone),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveZone(BuildContext context, Zone zone) {
    final transformationController = zone.transformationController;

    if (isEditable) {
      transformationController.addListener(() {
        final matrix = transformationController.value;
        final newScale = matrix.getMaxScaleOnAxis();
        final newTranslation = matrix.getTranslation();
        final newOffset = Offset(
          newTranslation.x / (zone.width != 0 ? zone.width : 1.0),
          newTranslation.y / (zone.height != 0 ? zone.height : 1.0),
        );

        if (newScale != zone.scale || newOffset != zone.offset) {
          zone.scale = newScale;
          zone.offset = newOffset;
        }
      });
    }

    return Stack(
      children: [
        GestureDetector(
          onLongPress: () {
            if (isEditable) {
              _switchImage(zone);
            }
          },
          child: InteractiveViewer(
            transformationController: transformationController,
            boundaryMargin: EdgeInsets.zero,
            panEnabled: isEditable,
            minScale: isEditable ? 1.0 : zone.scale,
            maxScale: isEditable ? 3.0 : zone.scale,
            constrained: true,
            child: zone.imageUrl.startsWith('http') || zone.imageUrl.startsWith('https')
                ? Image.network(
              zone.imageUrl,
              fit: BoxFit.cover,
              width: zone.width,
              height: zone.height,
            )
                : Image.file(
              File(zone.imageUrl),
              fit: BoxFit.cover,
              width: zone.width,
              height: zone.height,
            ),
          ),
        ),
        if (isEditable)
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditPageScreen(page: custom_page.Page(layout: layout, background: backgroundUrl, id: '', photos: [], texts: [], stickers: [])),
                  ),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4.0,
                      spreadRadius: 2.0,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8.0),
                child: const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _switchImage(Zone zone) {
    print('Image switched for zone: ${zone.imageUrl}');
  }

  Size _calculateLayoutSize(Layout layout) {
    double maxWidth = 0;
    double maxHeight = 0;

    for (Zone zone in layout.zones) {
      maxWidth = max(maxWidth, zone.left + zone.width);
      maxHeight = max(maxHeight, zone.top + zone.height);
    }

    return Size(maxWidth, maxHeight);
  }
}