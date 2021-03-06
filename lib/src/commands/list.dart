library ddrive.src.commands.list;

import 'package:unscripted/unscripted.dart';
import 'package:googleapis/drive/v2.dart' as drive;
import 'package:path/path.dart' as path;
import 'package:ansicolor/ansicolor.dart';

import '../context.dart' as context;

class ListCommand {
  @SubCommand(help: 'List files')
  list({@Option(help: 'Directory to list. Optional') String dir: ""}) async {
    context.printVersionInfo();
    AnsiPen pen = new AnsiPen();

    String currentPath = path.join(path.current, dir);
    String gdPath = await context.discoverGdPath(currentPath);

    String relPath = path.relative(currentPath, from: gdPath);
    relPath = relPath == "." ? "" : relPath;

    List<String> subtree = relPath.split("/");

    //Connect and get the drive API
    await context.discover(path.current);
    drive.DriveApi api = context.api;

    String parentId = "root";
    drive.FileList results;

    if (relPath.isEmpty) {
      results = await findFilesInPath(api, parentId);
    } else {
      for (int i = 0; i < subtree.length; i++) {
        String p = subtree[i];
        drive.FileList rootList = await findFoldersInPath(api, parentId, p);
        if (!rootList.items.isEmpty) {
          parentId = rootList.items[0].id;

          if (i == subtree.length - 1) {
            results = await findFilesInPath(api, parentId);
          }
        } else {
          print("Folder [${relPath}] doesn't exist");
          break;
        }
      }
    }

    if (results == null) {
      print("No files found in ${relPath}");
    } else {
      List<String> r = results.items
          .map((f) => f.mimeType == "application/vnd.google-apps.folder"
              ? "/" + f.title
              : f.title)
          .toList();
      r.sort((a, b) => a.compareTo(b));
      r.forEach((f) {
        if(f.startsWith("/")){
          pen.xterm(006);
          print( pen(f));
        }else{
          pen.xterm(245);
          print( pen(f));
        }
      });
    }
  }

  findFoldersInPath(
      drive.DriveApi api, String folderId, String folderName) async {
    return api.files.list(
        q: "'$folderId' in parents and title = '$folderName' and trashed=false and mimeType = 'application/vnd.google-apps.folder'");
  }

  findFilesInPath(drive.DriveApi api, String folderId) async {
    return api.files.list(q: "'$folderId' in parents and trashed=false");
  }
}
