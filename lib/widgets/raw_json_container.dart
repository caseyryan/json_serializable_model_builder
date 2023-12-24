import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:json_serializable_model_builder/controllers/json_tree_controller.dart';
import 'package:json_serializable_model_builder/widgets/json_highlighter.dart';
import 'package:json_serializable_model_builder/widgets/line_counter.dart';

import '../json_formatter.dart';

class RawJsonContainer extends StatelessWidget {
  const RawJsonContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final normalStyle = GoogleFonts.lato(
      fontSize: 16.0,
      fontWeight: FontWeight.w500,
      height: 1.0,
    );
    return Container(
      // color: Colors.grey[50],
      color: Theme.of(context).primaryColor.withOpacity(.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              bottom: 12.0,
            ),
            child: Row(
              children: [
                OutlinedButton(
                  onPressed: jsonTreeController.hasPastedJson ? jsonTreeController.toggleHighlight : null,
                  child: jsonTreeController.highlightJson ? const Text('Edit JSON') : const Text('Highlight JSON'),
                ),
                const SizedBox(width: 12.0),
                if (jsonTreeController.hasPastedJson)
                  OutlinedButton(
                    onPressed: jsonTreeController.onRegenerateModelsPressed,
                    child: const Text('Regenerate Models'),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LineCounter(
                  numLines: jsonTreeController.numLines,
                  style: normalStyle,
                ),
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: jsonTreeController.showHighlightedText
                        ? JsonHighlighter(
                            value: jsonTreeController.formattedJson,
                          )
                        : TextFormField(
                            maxLines: 1000000,
                            controller: jsonTreeController.jsonController,
                            onChanged: jsonTreeController.onChange,
                            decoration: const InputDecoration.collapsed(
                              hintText: 'Paste your JSON here',
                            ),
                            style: normalStyle,
                            inputFormatters: [
                              JsonFormatter(),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
          if (jsonTreeController.error?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
              ),
              child: Container(
                constraints: const BoxConstraints(
                  maxHeight: 80.0,
                ),
                child: SingleChildScrollView(
                  child: Text(
                    jsonTreeController.error!,
                    style: normalStyle.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
