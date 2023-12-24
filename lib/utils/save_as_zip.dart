import 'dart:convert';

import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:json_serializable_model_builder/controllers/tokenizer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as html;

Future saveAsZip({
  required List<List<Template>> templates,
  required RenderBox renderBox,
}) async {
  for (int i = 0; i < templates.length; i++) {
    var list = templates[i];
    if (list.isEmpty) {
      /// this situation is basically impossible.
      /// But just in case)
      continue;
    }
    final archive = Archive();
    String? archiveName;
    for (var template in list) {
      final fileName = template.fileName;
      List<int> contentBytes = utf8.encode(
        template.content,
      );
      if (template.isRoot && archiveName == null) {
        archiveName = template.archiveName;
      }
      final archiveInput = ArchiveFile.noCompress(
        fileName,
        contentBytes.length,
        contentBytes,
      );
      archive.addFile(archiveInput);
    }
    final archiveBytes = ZipEncoder().encode(
      archive,
      modified: DateTime.now(),
    )!;
    if (kIsWeb) {
      downloadInBrowser(
        bytes: archiveBytes,
        fileName: archiveName ?? 'Classes_$i.zip',
      );
    } else {
      final position = renderBox.localToGlobal(Offset.zero);
      Share.shareXFiles(
        [
          XFile.fromData(Uint8List.fromList(archiveBytes)),
        ],
        sharePositionOrigin: Rect.fromLTRB(
          position.dx,
          position.dy,
          position.dx + renderBox.size.width,
          position.dy + renderBox.size.height,
        ),
      );
    }
  }
}

void downloadInBrowser({
  required List<int> bytes,
  required String fileName,
}) {
  final blob = html.Blob([bytes]);
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
