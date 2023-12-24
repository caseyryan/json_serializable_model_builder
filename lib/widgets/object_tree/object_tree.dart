import 'package:flutter/material.dart';
import 'package:json_serializable_model_builder/controllers/json_tree_controller.dart';
import 'package:json_serializable_model_builder/widgets/object_tree/token_container_list.dart';

class ObjectTree extends StatelessWidget {
  const ObjectTree({super.key});

  @override
  Widget build(BuildContext context) {
    if (!jsonTreeController.hasData) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('No model yet'),
        ],
      );
    }
    return CustomScrollView(
      slivers: [
        ...jsonTreeController.tokenContainers.map(
          (e) {
            return TokenContainerList(
              key: ValueKey(e),
              container: e,
            );
          },
        ).toList()
      ],
    );
  }
}
