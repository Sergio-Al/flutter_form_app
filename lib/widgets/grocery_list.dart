import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:forms_app/data/categories.dart';

import 'package:http/http.dart' as http;

import 'package:forms_app/models/grocery_item.dart';
import 'package:forms_app/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  late Future<List<GroceryItem>> _loadedItems;
  String? _error;

  Future<List<GroceryItem>> _loadItems() async {
    final url = Uri.https(
        'flutter-test-3506b-default-rtdb.firebaseio.com', 'shopping-list.json');
    // throw Exception();

    final response = await http.get(url);

    if (response.statusCode >= 400) {
      throw Exception('Failed to fetch grocery items. Please try again later.');
    }

    if (response.body == 'null') {
      return [];
    }

    final Map<String, dynamic> listData = json.decode(response.body);
    final List<GroceryItem> loadedItems = [];

    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere((catItem) => catItem.value.name == item.value['category'])
          .value;
      loadedItems.add(
        GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ),
      );
    }

    return loadedItems;
  }

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

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });

    final url = Uri.https('flutter-test-3506b-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      // Optional show error message
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadedItems = _loadItems();
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
      body: FutureBuilder(
        future: _loadedItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }

          if (snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No items added yet.'),
            );
          }

          return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (ctx, index) {
                final item = snapshot.data![index];
                return Dismissible(
                  key: ValueKey(item.id),
                  onDismissed: (direction) {
                    _removeItem(snapshot.data![index]);

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
              });
        },
      ),
    );
  }
}
