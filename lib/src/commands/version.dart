library ddrive.src.commands.version;

import 'package:unscripted/unscripted.dart';
import '../context.dart' as context;

class VersionCommand {
  @SubCommand(help: 'Prints the Ddrive version')
  version() async {
    context.printVersionInfo();
  }
}
