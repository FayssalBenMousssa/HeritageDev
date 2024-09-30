import 'package:flutter/material.dart';

class CheckboxListDialog<T> extends StatefulWidget {
  final List<T> items;
  final List<T> selectedItems;
  final String title;
  final String Function(T) itemLabel;

  const CheckboxListDialog({
    Key? key,
    required this.items,
    required this.selectedItems,
    required this.title,
    required this.itemLabel,
  }) : super(key: key);

  @override
  CheckboxListDialogState<T> createState() => CheckboxListDialogState<T>();
}

class CheckboxListDialogState<T> extends State<CheckboxListDialog<T>> {
  late List<T> _selectedItems;

  @override
  void initState() {
    super.initState();
    _selectedItems = List.from(widget.selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          children: widget.items.map((item) {
            final isSelected = _selectedItems.contains(item);
            return CheckboxListTile(
              title: Text(widget.itemLabel(item)),
              value: isSelected,
              onChanged: (isChecked) {
                setState(() {
                  if (isChecked == true) {
                    _selectedItems.add(item);
                  } else {
                    _selectedItems.remove(item);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(_selectedItems);
          },
          child: const Text('OK'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
