import 'package:flutter/cupertino.dart';

Future<bool> showCupertinoConfirmation({
  required BuildContext context,
  required String description,
  String title = 'Confirm action',
  String confirm = 'Yes',
  String cancel = 'No',
}) async {
  final result = await showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Text(title),
        content: Text(description),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(cancel),
          ),
          CupertinoDialogAction(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text(confirm),
          ),
        ],
      );
    },
  );
  return result == true;
}
