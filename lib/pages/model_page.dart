import 'package:botbuilder/pages/addmodel_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:botbuilder/widgets/add_button.dart';
import 'package:botbuilder/widgets/search_bar.dart';
import 'package:botbuilder/services/model_service.dart';
import 'package:botbuilder/models/model.dart';
import 'package:url_launcher/url_launcher.dart';

class ModelPage extends StatefulWidget {
  const ModelPage({super.key});

  @override
  State<ModelPage> createState() => _ModelPageState();
}

class _ModelPageState extends State<ModelPage> {
  final _modelService = ModelService();

  List<Model> models = [];
  List<Model> filteredModels = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadModels();
  }

  Future<void> loadModels() async {
    try {
      final data = await _modelService.getModels();
      setState(() {
        models = data;
        filteredModels = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print('Error loading models: $e');
    }
  }

  void onSearchChanged(String value) {
    setState(() {
      searchQuery = value;
      filteredModels =
          models
              .where(
                (model) =>
                    model.name.toLowerCase().contains(value.toLowerCase()),
              )
              .toList();
    });
  }

  void openPdfUrl(String? url) async {
    if (url == null || url.isEmpty) return;

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print('Could not launch $url');
    }
  }

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
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const AddModelPage(),
                        ),
                      );

                      // If model was added successfully, reload the models list
                      if (result == true) {
                        setState(() {
                          isLoading = true;
                        });
                        await loadModels();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Search Bar
              SearchBar(placeholder: 'Search', onChanged: onSearchChanged),
              const SizedBox(height: 16),

              // Grid List or Loading
              isLoading
                  ? const Expanded(
                    child: Center(child: CupertinoActivityIndicator()),
                  )
                  : Expanded(
                    child: GridView.builder(
                      itemCount: filteredModels.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.9,
                          ),
                      itemBuilder: (context, index) {
                        final model = filteredModels[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey4,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              // รูปภาพแบบย่อให้พอดี
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => openPdfUrl(model.pdfUrl),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child:
                                          model.imageUrl != null
                                              ? Image.network(
                                                '${dotenv.env['API_BASE_URL']}${model.imageUrl}',
                                                fit:
                                                    BoxFit
                                                        .contain, // 👈 ย่อให้พอดี
                                              )
                                              : Container(
                                                color:
                                                    CupertinoColors.systemGrey3,
                                              ),
                                    ),
                                  ),
                                ),
                              ),

                              // ชื่อ model ด้านล่าง
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Text(
                                  model.name,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: CupertinoColors.black,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
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
