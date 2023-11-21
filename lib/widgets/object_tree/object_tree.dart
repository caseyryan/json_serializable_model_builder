import 'package:flutter/material.dart';
import 'package:json_serializable_model_builder/controllers/json_tree_controller.dart';

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
    if (jsonTreeController.mergeSimilarTypes) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                '"Merge Similar Models" mode (default).\nIn this mode you see only the models grouped by similar structures. This mode is preferred since there might be many inner structures with the exact same set of fields. They will be grouped into shared classes',
              ),
            ),
            // TypeView(
            //   data: jsonTreeController.mergedTypeWrapper,
            // ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              '"Generate Distinct Models" mode.\nIn this mode you will get a distinct class for each inner structure. This approach allows you do set default values for all of them but the downside is that you will end up (potentially) with many classes with exactly the same structure but different names. I recommend using "Merge Similar Models" mode instead',
            ),
          ),
          // TypeView(
          //   data: typeWrapper,
          // ),
        ],
      ),
    );
  }
}
