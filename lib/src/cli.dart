
import 'package:unscripted/unscripted.dart';
import 'package:googleapis/drive/v2.dart' as drive;

import 'commands/quota.dart';
import 'commands/init.dart';

class Ddrive extends Object with
    QuotaCommand,
    InitCommand {

  @Command(allowTrailingOptions: true, help: 'A simple Google Drive client')
  Ddrive();
}