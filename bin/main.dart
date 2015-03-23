// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:ddrive/ddrive.dart' as ddrive;

import 'package:unscripted/unscripted.dart';
import 'package:prompt/prompt.dart';

import "package:http/http.dart" as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/drive/v2.dart' as drive;
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

drive.DriveApi api;

class Credentials {
  String clientId;
  String secret;
  auth.AccessToken accessToken;
  String refreshToken;
  List<String> scopes;
  Credentials(this.clientId, this.secret, this.accessToken, this.refreshToken, this.scopes);
  Credentials.fromJson(json){
    if (json is String) {
      json = JSON.decode(json);
    }
    if (json is! Map) {
      throw new ArgumentError('json must be a Map or a String encoding a Map.');
    }

    clientId = json['clientId'];
    secret = json['secret'];
    var accessTokenJson = json['accessToken'];
    accessToken = new auth.AccessToken(accessTokenJson['type'], accessTokenJson['data'], new DateTime.fromMillisecondsSinceEpoch(accessTokenJson['expiry'], isUtc: true));
    refreshToken = json['refreshToken'];
    scopes = json['scopes'];
  }

  static toJson(Credentials c) {
    var accessTokenJson = {"type" : c.accessToken.type, "data" : c.accessToken.data, "expiry" : c.accessToken.expiry.toUtc().millisecondsSinceEpoch};//JSON.encode(c.accessToken);
    return JSON.encode({"clientId": "${c.clientId}", "secret": "${c.secret}", "accessToken": accessTokenJson, "refreshToken" : c.refreshToken, "scopes": c.scopes});
  }
}

main(arguments) async {
  final clientId = '354790962074-7rrlnuanmamgg1i4feed12dpuq871bvd.apps.googleusercontent.com';
  final secret = 'RHjKdah8RrHFwu6fcc0uEVCw';
  final id = new auth.ClientId( clientId, secret);

  final scopes = [drive.DriveApi.DriveScope];

  final accesType = 'offline';

  Credentials credentials;
  http.Client c = new http.Client();

  void prompt(String url) {
    print("Please go to the following URL and grant access:");
    print("  => $url");
    print("");
  }

  File f = new File('credentials.json');
  if(await f.exists()) {
    credentials =  new Credentials.fromJson(await f.readAsString());
  }

  if(credentials != null) {
    var accessCredentials =new auth.AccessCredentials(credentials.accessToken, credentials.refreshToken, credentials.scopes);
    auth.refreshCredentials(id, accessCredentials, c);
    c =  auth.authenticatedClient(c, accessCredentials);
  }else {
    auth.AccessCredentials accessCredentials = await auth.obtainAccessCredentialsViaUserConsent(id, scopes, c, prompt);
    c =  auth.authenticatedClient(c, accessCredentials);

    credentials =  new Credentials(clientId, secret, accessCredentials.accessToken, accessCredentials.refreshToken, accessCredentials.scopes);

    f.createSync();
    f.writeAsStringSync(Credentials.toJson(credentials));
  }

  api = new drive.DriveApi(c);
  drive.FileList fileList = await api.files.list();

  fileList.items.forEach((drive.File f) => print("${f.id} ${f.originalFilename}"));

  c.close();

  arguments = ['quota'];//, '--help'];
  declare(Ddrive).execute(arguments);
}

class Ddrive extends Object with
  QuotaCommand,
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

class QuotaCommand {
  @SubCommand(help: 'prints out quota information for this drive')
  quota() async {
    drive.About about = await api.about.get();
    num free = num.parse(about.quotaBytesTotal) - num.parse(about.quotaBytesUsed);
    print('''
      Name : ${about.name}
      Account type : : ${about.quotaType}
      Bytes used : ${about.quotaBytesUsed} (${prettySize(about.quotaBytesUsed)})
      Bytes free : ${free} (${prettySize(free)})
      Bytes InTrash : ${about.quotaBytesUsedInTrash} (${prettySize(about.quotaBytesUsedInTrash)})
      Total bytes : ${about.quotaBytesTotal} (${prettySize(about.quotaBytesTotal)})
      ''');
  }
}

prettySize(bytes) {
  if(bytes is String){
    bytes = num.parse(bytes);
  }
  var sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
  if (bytes == 0) return '0 Bytes';
  var i = (math.log(bytes) / math.log(1024)).floor();
  return "${(bytes / math.pow(1024, i)).round()} ${sizes[i]}";
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