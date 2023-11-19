import 'package:flutter/material.dart';
import 'package:json_serializable_model_builder/controllers/json_tree_controller.dart';
import 'package:json_serializable_model_builder/widgets/json_highlighter.dart';

import '../json_formatter.dart';

class RawJsonContainer extends StatelessWidget {
  const RawJsonContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Theme.of(context).cardColor,
            width: double.infinity,
            height: double.infinity,
            child: jsonTreeController.showHighlightedText
                ? JsonHighlighter(
                    value: jsonTreeController.formattedJson,
                  )
                : TextFormField(
                    maxLines: 1000000,
                    controller: jsonTreeController.jsonController,
                    onChanged: jsonTreeController.onJsonEnter,
                    decoration: const InputDecoration.collapsed(
                      hintText: 'Paste your JSON here',
                    ),
                    inputFormatters: [
                      JsonFormatter(),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
