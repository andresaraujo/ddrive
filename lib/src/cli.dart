import 'package:unscripted/unscripted.dart';

import 'commands/list.dart';
import 'commands/quota.dart';
import 'commands/init.dart';
import 'commands/version.dart';

class Ddrive extends Object with ListCommand, QuotaCommand, InitCommand, VersionCommand {
  @Command(allowTrailingOptions: true, help: 'A simple Google Drive client')
  Ddrive();
}
