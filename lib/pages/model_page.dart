import 'package:botbuilder/widgets/add_button.dart';
import 'package:botbuilder/widgets/search_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:botbuilder/services/model_service.dart';
import 'package:botbuilder/models/model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:botbuilder/pages/addmodel_page.dart';

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

  // ฟังก์ชันสำหรับเปิด URL ของ PDF
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
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Models'),
        backgroundColor: CupertinoColors.systemBackground,
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Models',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.black,
                        ),
                      ),
                      AddButton(
                        onPressed: () async {
                          final result = await Get.to(
                            () => const AddModelPage(),
                          );
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
                  SearchBar(
                    placeholder: 'Search models...',
                    onChanged: onSearchChanged,
                  ),
                ],
              ),
            ),
            // Display models in grid format
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    sliver:
                        isLoading
                            ? const SliverToBoxAdapter(
                              child: SizedBox(
                                height: 200,
                                child: Center(
                                  child: CupertinoActivityIndicator(radius: 16),
                                ),
                              ),
                            )
                            : filteredModels.isEmpty
                            ? SliverToBoxAdapter(
                              child: SizedBox(
                                height: 200,
                                child: Center(
                                  child: Text(
                                    'No models found',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: CupertinoColors.inactiveGray,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            : SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 0.8,
                                  ),
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final model = filteredModels[index];
                                return Container(
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: CupertinoColors.black.withAlpha(
                                          (0.1 * 255).toInt(),
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: () => openPdfUrl(model.pdfUrl),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child:
                                                model.imageUrl != null &&
                                                        model
                                                            .imageUrl!
                                                            .isNotEmpty
                                                    ? Image.network(
                                                      '${dotenv.env['API_BASE_URL']}${model.imageUrl}',
                                                      fit: BoxFit.cover,
                                                      width: 170,
                                                      height: 150,
                                                      errorBuilder: (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) {
                                                        return Container(
                                                          width: 170,
                                                          height: 150,
                                                          color:
                                                              CupertinoColors
                                                                  .systemGrey4,
                                                          child: const Icon(
                                                            CupertinoIcons.doc,
                                                            size: 120,
                                                            color:
                                                                CupertinoColors
                                                                    .inactiveGray,
                                                          ),
                                                        );
                                                      },
                                                    )
                                                    : Container(
                                                      width: 170,
                                                      height: 150,
                                                      color:
                                                          CupertinoColors
                                                              .systemGrey4,
                                                      child: const Icon(
                                                        CupertinoIcons.doc,
                                                        size: 120,
                                                        color:
                                                            CupertinoColors
                                                                .inactiveGray,
                                                      ),
                                                    ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        model.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: CupertinoColors.black,
                                        ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CupertinoButton(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                            minSize: 0,
                                            child: const Icon(
                                              CupertinoIcons.pencil,
                                              size: 20,
                                              color: CupertinoColors.activeBlue,
                                            ),
                                            onPressed: () async {
                                              final result = await Get.to(
                                                () => AddModelPage(
                                                  existingModel: model,
                                                ),
                                              );
                                              if (result == true)
                                                await loadModels();
                                            },
                                          ),
                                          CupertinoButton(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                            minSize: 0,
                                            child: const Icon(
                                              CupertinoIcons.delete,
                                              size: 20,
                                              color:
                                                  CupertinoColors
                                                      .destructiveRed,
                                            ),
                                            onPressed: () async {
                                              final confirm = await showCupertinoDialog<
                                                bool
                                              >(
                                                context: context,
                                                builder:
                                                    (
                                                      context,
                                                    ) => CupertinoAlertDialog(
                                                      title: const Text(
                                                        'Confirm Delete',
                                                      ),
                                                      content: const Text(
                                                        'Are you sure you want to delete this model?',
                                                      ),
                                                      actions: [
                                                        CupertinoDialogAction(
                                                          child: const Text(
                                                            'Cancel',
                                                          ),
                                                          onPressed:
                                                              () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                    false,
                                                                  ),
                                                        ),
                                                        CupertinoDialogAction(
                                                          isDestructiveAction:
                                                              true,
                                                          child: const Text(
                                                            'Delete',
                                                          ),
                                                          onPressed:
                                                              () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                    true,
                                                                  ),
                                                        ),
                                                      ],
                                                    ),
                                              );

                                              if (confirm == true) {
                                                try {
                                                  await _modelService
                                                      .deleteModel(model.id!);
                                                  await loadModels();
                                                } catch (e) {
                                                  print('Delete error: $e');
                                                }
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }, childCount: filteredModels.length),
                            ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
