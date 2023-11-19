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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'This tree does not correspond to the JSON structure. It only displays the inner classes. If you want it to correspond to the real structure, deselect `Merge similar classes`. But in this case you might end up with many different classes that have exactly the same structure but different names',
              ),
            ),
            TypeView(
              data: jsonTreeController.mergedTypeWrapper,
            ),
          ],
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
