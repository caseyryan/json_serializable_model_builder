import 'package:flutter/material.dart';
import 'package:json_serializable_model_builder/controllers/json_tree_controller.dart';
import 'package:json_serializable_model_builder/widgets/object_tree/object_tree.dart';
import 'package:json_serializable_model_builder/widgets/raw_json_container.dart';
import 'package:lite_forms/lite_forms.dart';

class JsonTreePage extends StatefulWidget {
  const JsonTreePage({super.key});

  @override
  State<JsonTreePage> createState() => _JsonTreePageState();
}

class _JsonTreePageState extends State<JsonTreePage> {
  @override
  Widget build(BuildContext context) {
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
              Row(
                children: [
                  IconButton(
                    tooltip: 'Regenerate Model',
                    onPressed: jsonTreeController.rebuildJson,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              const Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 65,
                      child: ObjectTree(),
                    ),
                    VerticalDivider(
                      width: .5,
                    ),
                    Expanded(
                      flex: 45,
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
  }
}
