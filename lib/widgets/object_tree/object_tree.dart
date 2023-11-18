import 'package:flutter/material.dart';
import 'package:json_serializable_model_builder/controllers/json_tree_controller.dart';
import 'package:json_serializable_model_builder/widgets/object_tree/type_view.dart';
import 'package:lite_forms/lite_forms.dart';

class ObjectTree extends StatelessWidget {
  const ObjectTree({super.key});

  @override
  Widget build(BuildContext context) {
    return LiteState<JsonTreeController>(
      builder: (BuildContext c, JsonTreeController controller) {
        final TypeWrapper? typeWrapper = controller.typeWrapper;
        if (typeWrapper == null) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('No model yet'),
            ],
          );
        }
        return SingleChildScrollView(
          child: TypeView(
            data: typeWrapper,
          ),
        );
      },
    );
  }
}
