library ddrive.src.commands.quota;

import 'package:unscripted/unscripted.dart';
import 'package:googleapis/drive/v2.dart' as drive;
import 'package:path/path.dart' as path;

import '../util.dart';
import '../context.dart' as context;

class QuotaCommand {
  @SubCommand(help: 'Gets the quota information about the current user')
  quota() async {
    await context.discover(path.current);
    drive.DriveApi api = context.api;

    drive.About about = await api.about.get();
    num free =
        num.parse(about.quotaBytesTotal) - num.parse(about.quotaBytesUsed);
    print('''
      Name : ${about.name}
      Root Folder Id : ${about.rootFolderId}
      Account type : ${about.quotaType}
      Bytes used : ${about.quotaBytesUsed} (${prettySize(about.quotaBytesUsed)})
      Bytes free : ${free} (${prettySize(free)})
      Bytes InTrash : ${about.quotaBytesUsedInTrash} (${prettySize(about.quotaBytesUsedInTrash)})
      Total bytes : ${about.quotaBytesTotal} (${prettySize(about.quotaBytesTotal)})
      ''');
  }
}
