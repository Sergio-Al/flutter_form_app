import 'package:flutter/material.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add a new Item',
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(12),
        child: Text('The form'),
      ),
    );
  }
}