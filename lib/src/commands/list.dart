library ddrive.src.commands.list;

import 'package:unscripted/unscripted.dart';
import 'package:googleapis/drive/v2.dart' as drive;
import 'package:path/path.dart' as path;

import '../util.dart';
import '../context.dart' as context;

class ListCommand {

  @SubCommand(help: 'List files')
  list() async {
  }
}

/*

//get only folders
drive.FileList fileList = await api.files.list(q: "mimeType='application/vnd.google-apps.folder'");
//drive.ChildList fileList = await api.children.list(q: "mimeType='application/vnd.google-apps.folder'");

fileList.items.forEach((drive.File f) {
print("${f.id} /${f.title}");
});
*/