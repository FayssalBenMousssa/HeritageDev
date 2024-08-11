// demo_page.dart

import 'package:flutter/material.dart';

class DemoPage extends StatelessWidget {
  final int page;

  const DemoPage({Key? key, required this.page}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Text(
          'Page $page',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
