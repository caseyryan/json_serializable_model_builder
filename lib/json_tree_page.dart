// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/foundation.dart';
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
                'Build `json_serializable` Model',
                style: TextStyle(color: Colors.white),
              ),
            ),
            body: SafeArea(
              child: LiteFormGroup(
                name: JsonTreeController.kSettingsFormName,
                builder: (context, scrollController) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: flex1,
                              child: Row(
                                children: [
                                  IconButton.outlined(
                                    tooltip: 'Regenerate Model',
                                    onPressed: () async {
                                      if (kDebugMode ||
                                          await showCupertinoConfirmation(
                                            context: context,
                                            description:
                                                'Do you want to reset all your changes and rebuild the model from scratch?',
                                          )) {
                                        jsonTreeController.rebuildJson();
                                      }
                                    },
                                    icon: const Icon(Icons.refresh),
                                  ),
                                  if (jsonTreeController.hasData)
                                    IconButton.outlined(
                                      tooltip: 'Save Model',
                                      onPressed: jsonTreeController.saveModel,
                                      icon: const Icon(Icons.save_alt_rounded),
                                    ),
                                  LiteDropSelector(
                                    dropSelectorActionType:
                                        LiteDropSelectorActionType.multiselect,
                                    paddingRight: 8.0,
                                    selectorViewBuilder: (context, selectedItems) {
                                      return Container(
                                        color: Colors.transparent,
                                        child: IgnorePointer(
                                          child: selectedItems.isEmpty
                                              ? IconButton.outlined(
                                                  onPressed: () {},
                                                  icon: Stack(
                                                    children: [
                                                      Icon(
                                                        Icons.settings,
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : IconButton.filledTonal(
                                                  onPressed: () {},
                                                  icon: Stack(
                                                    children: [
                                                      Icon(
                                                        Icons.settings,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                        ),
                                      );
                                    },
                                    name: 'jsonSettings',
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    initialValue: jsonTreeController.selectedTypes,
                                    serializer: (value) async {
                                      if (value is List) {
                                        return value.map((e) => e.payload).toList();
                                      }
                                      return value;
                                    },
                                    onChanged: (value) {
                                      jsonTreeController.rebuildJson();
                                    },
                                    items: [
                                      LiteDropSelectorItem(
                                        title: 'Merge Similar Models',
                                        payload: JsonSettingType.mergeSimilar,
                                        iconBuilder: (context, item, isSelected) {
                                          return Icon(
                                            Icons.merge,
                                            color: Colors.blue,
                                          );
                                        },
                                      ),
                                      LiteDropSelectorItem(
                                        title: 'Prefer Nullable',
                                        payload: JsonSettingType.preferNullable,
                                        iconBuilder: (context, item, isSelected) {
                                          return Icon(
                                            Icons.check_circle_outline,
                                            color: Colors.green,
                                          );
                                        },
                                      ),
                                    ],
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
                            // const VerticalDivider(
                            //   width: .5,
                            // ),
                            Expanded(
                              flex: flex2,
                              child: RawJsonContainer(),
                            )
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
