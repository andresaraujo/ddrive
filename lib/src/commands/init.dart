library ddrive.src.commands.init;

import 'package:unscripted/unscripted.dart';
import 'package:googleapis/drive/v2.dart' as drive;
import 'package:path/path.dart' as path;

import '../context.dart' as context;


class InitCommand {

  @SubCommand(help: 'Gets the quota information about the current user')
  init({ @Option(help: 'The root directory for Google Drive. Defaults to your current directory') String driveHome }) async {
    String p = driveHome == null || driveHome.isEmpty ? path.current : driveHome; //path ? path : path.current;
    bool firstTime = ! await context.credentialsExist(p);
    context.askForAuthorization(p);
  }
}