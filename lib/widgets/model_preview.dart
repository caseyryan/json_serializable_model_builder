import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:json_serializable_model_builder/controllers/tokenizer.dart';

import 'highlighter_theme.dart';

void showTemplatePreview({
  required BuildContext context,
  required List<List<Template>> templates,
}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) {
        return TemplatePreview(
          templates: templates,
        );
      },
    ),
  );
}

class TemplatePreview extends StatelessWidget {
  const TemplatePreview({
    super.key,
    required this.templates,
  });

  final List<List<Template>> templates;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
      ),
      body: CustomScrollView(
        slivers: [
          ...templates.map(
            (e) {
              return _TemplateView(
                templates: e,
                key: ValueKey(e),
              );
            },
          ).toList()
        ],
      ),
    );
  }
}

class _TemplateView extends StatefulWidget {
  const _TemplateView({
    super.key,
    required this.templates,
  });

  final List<Template> templates;

  @override
  State<_TemplateView> createState() => _TemplateViewState();
}

class _TemplateViewState extends State<_TemplateView> {
  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          ...widget.templates.map(
            (e) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Material(
                  elevation: 1.0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: HighlightView(
                            e.content,
                            language: 'dart',
                            theme: highlighterThemeLight,
                          ),
                        ),
                        Column(
                          children: [
                            IconButton.outlined(
                              tooltip: 'Copy ${e.typeName} to clipboard',
                              onPressed: () async {
                                await e.content.copyToClipboard();
                                if (mounted) {
                                  '${e.typeName} model has been copied to the clipboard'.showSnackbar(context);
                                }
                              },
                              icon: const Icon(Icons.copy_all),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ).toList()
        ],
      ),
    );
  }
}
