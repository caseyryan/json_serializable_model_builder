import 'dart:convert';
import 'dart:html' as html;

import 'package:json_serializable_model_builder/controllers/tokenizer.dart';

Future saveAsZip(
  List<List<Template>> templates,
) async {
  for (int i = 0; i < templates.length; i++) {
    var list = templates[i];
    // Archive archive = ArchiveFile.noCompress('classes_$i', size, content);
    int totalArchiveSize = 0;
    for (var template in list) {
      final fileName = template.fileName;
      List<int> contentBytes = utf8.encode(
        template.content,
      );

      final blob = html.Blob([contentBytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = fileName;
      html.document.body?.children.add(anchor);

      // download
      anchor.click();

      // cleanup
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
    }
  }
}
