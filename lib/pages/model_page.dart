import 'package:flutter/cupertino.dart';
import 'package:botbuilder/widgets/add_button.dart';
import 'package:botbuilder/widgets/search_bar.dart';

class ModelPage extends StatefulWidget {
  const ModelPage({super.key});

  @override
  State<ModelPage> createState() => _ModelPageState();
}

class _ModelPageState extends State<ModelPage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Model')),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Model',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  AddButton(
                    onPressed: () {
                      // TODO: handle add model
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Search Bar
              SearchBar(
                placeholder: 'Search',
                onChanged: (value) {
                  setState(() => searchQuery = value);
                },
              ),
              const SizedBox(height: 16),

              // Grid List
              Expanded(
                child: GridView.builder(
                  itemCount: 12, // TODO: replace with filtered data
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey4,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text("Model", style: TextStyle(fontSize: 12)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
