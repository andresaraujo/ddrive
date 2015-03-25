library ddrive.src.commands.list;

import 'package:unscripted/unscripted.dart';
import 'package:googleapis/drive/v2.dart' as drive;
import 'package:path/path.dart' as path;

import '../util.dart';
import '../context.dart' as context;

class ListCommand {

  @SubCommand(help: 'List files')
  list({@Option(help: 'Directory to list. Optional') String dir : ""}) async {
    String currentPath = path.join(path.current, dir);
    String gdPath = await context.discoverGdPath(currentPath);



    String relPath = path.relative(currentPath, from: gdPath);

    print(currentPath);
    print(gdPath);
    print(relPath);

    await context.discover(path.current);
    drive.DriveApi api = context.api;
    drive.FileList list = await api.files.list(q : "'$relPath' in parents and trashed=false"); //$folderID' in parents

    list.items.forEach((f) => print(f.title));
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