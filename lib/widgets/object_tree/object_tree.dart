import 'package:flutter/material.dart';
import 'package:json_serializable_model_builder/controllers/json_tree_controller.dart';
import 'package:json_serializable_model_builder/widgets/object_tree/type_view.dart';

class ObjectTree extends StatelessWidget {
  const ObjectTree({super.key});

  @override
  Widget build(BuildContext context) {
    final TypeWrapper? typeWrapper = jsonTreeController.typeWrapper;
    if (typeWrapper == null) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('No model yet'),
        ],
      );
    }
    if (jsonTreeController.tryMergeSimilarTypes) {
      return SingleChildScrollView(
        child: TypeView(
          data: jsonTreeController.mergedTypeWrapper,
        ),
      );
    }

    return SingleChildScrollView(
      child: TypeView(
        data: typeWrapper,
      ),
    );
  }
}
