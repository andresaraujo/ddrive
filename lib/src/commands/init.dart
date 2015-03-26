library ddrive.src.commands.init;

import 'package:unscripted/unscripted.dart';
import 'package:path/path.dart' as path;

import '../context.dart' as context;

class InitCommand {
  @SubCommand(help: 'Initialize a Google Drive home directory')
  init({@Option(
      help: 'The root directory for Google Drive. Defaults to your current directory') String driveHome}) async {
    String p =
        driveHome == null || driveHome.isEmpty ? path.current : driveHome;
    bool firstTime = !await context.credentialsExist(p);
    context.askForAuthorization(p);
  }
}
