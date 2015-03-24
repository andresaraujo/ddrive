#!/usr/bin/env dart

import 'package:unscripted/unscripted.dart';
import 'package:ddrive/src/cli.dart' as cli;

main(arguments) async => declare(cli.Ddrive).execute(arguments);