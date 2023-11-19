import 'package:flutter/material.dart';

import '../../controllers/json_tree_controller.dart';
import 'value_view.dart';

class TypeView extends StatefulWidget {
  const TypeView({
    super.key,
    required this.data,
  });

  final TypeWrapper data;

  @override
  State<TypeView> createState() => _TypeViewState();
}

class _TypeViewState extends State<TypeView> {
  List<Widget> _buildChildren() {
    final children = <Widget>[];
    for (var value in widget.data.values) {
      if (value is ValueWrapper) {
        children.add(
          ValueView(
            data: value,
          ),
        );
      } else if (value is TypeWrapper) {
        children.add(
          TypeView(
            data: value,
          ),
        );
      }
    }
    return children;
  }

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium!;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
        ),
        elevation: .4,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.data.proposedTypeName,
                            style: style.copyWith(
                              color: const Color.fromARGB(255, 13, 106, 16),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 4.0,
                        ),
                        Flexible(
                          child: Text(
                            widget.data.keyName,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Nullable Values',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(
                        width: 4.0,
                      ),
                      SizedBox(
                        height: 20.0,
                        width: 20.0,
                        child: Checkbox(
                          value: widget.data.isNullable,
                          visualDensity: VisualDensity.adaptivePlatformDensity,
                          onChanged: (value) {
                            widget.data.isNullable = !widget.data.isNullable;
                            jsonTreeController.rebuild();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              ..._buildChildren(),
            ],
          ),
        ),
      ),
    );
  }
}
