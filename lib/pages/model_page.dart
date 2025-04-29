// model_page.dart
import 'package:flutter/cupertino.dart';

class ModelPage extends StatelessWidget {
  const ModelPage({super.key});

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Model',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    color: CupertinoColors.activeGreen,
                    child: const Text("ADD"),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const CupertinoSearchTextField(),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  itemCount: 12,
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
