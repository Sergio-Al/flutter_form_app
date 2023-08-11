import 'package:flutter/material.dart';
import 'package:forms_app/data/dummy_items.dart';

import 'package:forms_app/models/grocery_item.dart';
import 'package:forms_app/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceryItems = [];

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );

    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your groceries'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _groceryItems.isEmpty
          ? const Center(
              child: Text('No items here'),
            )
          : ListView.builder(
              itemCount: _groceryItems.length,
              itemBuilder: (ctx, index) {
                final item = _groceryItems[index];
                return Dismissible(
                  key: Key(item.id),
                  onDismissed: (direction) {
                    setState(() {
                      _groceryItems.removeAt(index);
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${item.name} dismissed!!'),
                      ),
                    );
                  },
                  // Show a red background as the item is swiped away.
                  background: Container(color: Colors.red),
                  child: ListTile(
                    title: Text(item.name),
                    leading: Container(
                      width: 24,
                      height: 24,
                      color: item.category.color,
                    ),
                    trailing: Text(item.quantity.toString()),
                  ),
                );
              }),
    );
  }
}
