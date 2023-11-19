// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:json_serializable_model_builder/controllers/json_tree_controller.dart';
import 'package:json_serializable_model_builder/dialogs/show_cupertino_confirmation.dart';
import 'package:json_serializable_model_builder/widgets/object_tree/object_tree.dart';
import 'package:json_serializable_model_builder/widgets/raw_json_container.dart';
import 'package:lite_forms/lite_forms.dart';

class JsonTreePage extends StatefulWidget {
  const JsonTreePage({super.key});

  @override
  State<JsonTreePage> createState() => _JsonTreePageState();
}

class _JsonTreePageState extends State<JsonTreePage> {
  Widget _buildClearButton() {
    if (jsonTreeController.hasData) {
      return Row(
        children: [
          IconButton.outlined(
            onPressed: () async {
              if (await showCupertinoConfirmation(
                context: context,
                description:
                    'This will clear your model. Do you really want to continue?',
              )) {
                jsonTreeController.reset();
              }
            },
            icon: const Icon(Icons.close),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    const flex1 = 65;
    const flex2 = 45;
    return LiteState<JsonTreeController>(
      builder: (BuildContext c, JsonTreeController controller) {
        return Unfocuser(
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              title: const Text(
                'Build Json Serializable Model',
              ),
            ),
            body: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: flex1,
                          child: Row(
                            children: [
                              IconButton.outlined(
                                tooltip: 'Regenerate Model',
                                onPressed: () async {
                                  if (await showCupertinoConfirmation(
                                    context: context,
                                    description:
                                        'Do you want to reset all your changes and rebuild the model from scratch?',
                                  )) {
                                    jsonTreeController.rebuildJson();
                                  }
                                },
                                icon: const Icon(Icons.refresh),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: flex2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (!jsonTreeController.hasData)
                                MaterialButton(
                                  onPressed: jsonTreeController.enterExample,
                                  child: const Text('Example JSON'),
                                ),
                              _buildClearButton(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: flex1,
                          child: ObjectTree(),
                        ),
                        const VerticalDivider(
                          width: .5,
                        ),
                        Expanded(
                          flex: flex2,
                          child: RawJsonContainer(),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
