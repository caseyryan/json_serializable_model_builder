import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lite_forms/lite_forms.dart';

typedef ConfirmCondition = Future Function();

Future<bool> showCustomDialog({
  String? description,
  String title = '',
  required BuildContext context,
  required String? confirmText,
  required String cancelText,
  ConfirmCondition? confirmCondition,
  Widget? content,
}) async {
  final result = await showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) {
      return LiteFormGroup(
        name: 'alert',
        builder: (c, scrollController) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: content ?? Text(description ?? ''),
            actions: <CupertinoDialogAction>[
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(cancelText),
              ),
              if (confirmText != null)
                CupertinoDialogAction(
                  onPressed: () async {
                    if (confirmCondition != null) {
                      await confirmCondition();
                    } else {
                      Navigator.of(context).pop(true);
                    }
                  },
                  child: Text(confirmText),
                ),
            ],
          );
        },
      );
    },
  );
  return result == true;
}

class AlertField extends StatelessWidget {
  const AlertField({
    super.key,
    required this.initialValue,
  });

  final String initialValue;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: LiteTextFormField(
        paddingTop: 12.0,
        name: 'input',
        autofocus: true,
        initialValue: initialValue,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
        ),
      ),
    );
  }
}
