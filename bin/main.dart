// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:ddrive/ddrive.dart' as ddrive;

import 'package:unscripted/unscripted.dart';
import 'package:prompt/prompt.dart';

main(arguments) {
  arguments = ['init'];//, '--help'];
  declare(Ddrive).execute(arguments);
}

class Ddrive extends Object with
  StatsCommand,
  ListCommand,
  InitCommand {

  @Command(allowTrailingOptions: true, help: 'A simple Google Drive client')
  Ddrive();
}

class InitCommand {
  @SubCommand(help: 'Initializate Google Drive credentials')
  init() {
    var url = "http://something";

    print('''
Visit this URL to get an authorization code
${url}
    ''');
    String code = askSync( new Question("Paste the authorization code:"));//.then( (value) => print('>>>>>>$value'));
    close();

    //todo: validate input
  }
}

class StatsCommand {
  @SubCommand(help: 'See stats')
  stats() {}
}

class ListCommand {
  List<String> files = ['file 1', 'file 2'];

  @SubCommand(help: 'List')
  list() {
    for(var f in files){
      print(f);
    }
  }
}