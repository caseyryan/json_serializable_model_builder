import 'package:flutter/material.dart';
import 'package:json_serializable_model_builder/controllers/json_tree_controller.dart';
import 'package:lite_forms/lite_forms.dart';

import '../json_formatter.dart';

class RawJsonContainer extends StatelessWidget {
  const RawJsonContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return LiteState<JsonTreeController>(
      builder: (BuildContext c, JsonTreeController controller) {
        return Column(
          children: [
            Expanded(
              child: Container(
                color: Theme.of(context).cardColor,
                width: double.infinity,
                height: double.infinity,
                child: TextFormField(
                  maxLines: 1000000,
                  controller: controller.jsonController,
                  onChanged: controller.onJsonEnter,
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Enter JSON',
                  ),
                  inputFormatters: [
                    JsonFormatter(),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
