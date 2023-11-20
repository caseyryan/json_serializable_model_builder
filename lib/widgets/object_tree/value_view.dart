import 'package:flutter/material.dart';
import 'package:json_serializable_model_builder/controllers/json_tree_controller.dart';

class ValueView extends StatefulWidget {
  const ValueView({
    super.key,
    required this.data,
  });

  final ValueWrapper data;

  @override
  State<ValueView> createState() => _ValueViewState();
}

class _ValueViewState extends State<ValueView> {
  Widget _buildDefaultValue() {
    if (!widget.data.isNullable) {
      final defaultValue = widget.data.defaultValue;
      if (defaultValue == null) {
        return const Tooltip(
          message: 'This data type cannot have a default value other than `null`',
          child: Icon(
            Icons.warning_rounded,
            color: Colors.red,
          ),
        );
      }
      final children = <Widget>[
        const Text(' = '),
      ];
      TextStyle? valueStyle = Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: Colors.lightBlue,
          );

      children.add(Text(
        '$defaultValue',
        style: valueStyle,
      ));
      return Row(
        children: children,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildCheckBox() {
    if (!widget.data.canBeNullable) {
      return const SizedBox.shrink();
    }
    return Row(
      children: [
        Text(
          'nullable',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        SizedBox(
          height: 20.0,
          width: 20.0,
          child: Transform.scale(
            scale: .8,
            child: Checkbox(
              value: widget.data.isNullable,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              onChanged: (value) {
                setState(() {
                  widget.data.isNullable = !widget.data.isNullable;
                  widget.data.isChangedManually = true;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium!;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Material(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
        ),
        elevation: .1,
        child: InkWell(
          borderRadius: BorderRadius.circular(6.0),
          splashColor: Colors.black.withOpacity(.02),
          highlightColor: Colors.transparent,
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          widget.data.proposedTypeName,
                          style: style.copyWith(
                            color: widget.data.typeColor,
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
                      const SizedBox(
                        width: 4.0,
                      ),
                      _buildDefaultValue(),
                    ],
                  ),
                ),
                _buildCheckBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
