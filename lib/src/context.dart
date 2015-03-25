library ddrive.credentials;

import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/drive/v2.dart' as drive;
import "package:http/http.dart" as http;
import 'package:path/path.dart' as path;

import 'dart:convert';
import 'dart:io';
import 'dart:async';

Credentials credentials;
drive.DriveApi api;

class Defaults {
  static const ClientId = '354790962074-7rrlnuanmamgg1i4feed12dpuq871bvd.apps.googleusercontent.com';
  static const Secret = 'RHjKdah8RrHFwu6fcc0uEVCw';
  static const Scopes = const [drive.DriveApi.DriveScope];
  static const AccessType = 'offline';
}

gdPath(String absPath) {
  return path.join(absPath, ".gd");
}

credentialsExist(String absPath) async {
  File f = new File( path.join(gdPath(absPath), "credentials.json"));
  return f.exists();
}

Future<String> discoverGdPath(String currentAbsPath) async {
  String  p = currentAbsPath;
  String newPath;
  bool found = false;

  while(!found){
    FileStat info = await FileStat.stat( gdPath(p) );
    if(info.type == FileSystemEntityType.DIRECTORY){
      found = true;
      break;
    }

    newPath = path.normalize(path.join(p, ".."));
    if(p == newPath) {
      break;
    }
    p = newPath;
  }

  if(!found) throw new StateError("no gd context is found; use ddrive init");

  return new Future(() => p);
}

discover(String currentAbsPath) async {
  var p = currentAbsPath;
  var newPath;
  bool found = false;

  while(!found){
    FileStat info = await FileStat.stat( gdPath(p) );
    if(info.type == FileSystemEntityType.DIRECTORY){
      found = true;
      break;
    }

    newPath = path.normalize(path.join(p, ".."));
    if(p == newPath) {
      break;
    }
    p = newPath;
  }

  if(!found) throw new StateError("no gd context is found; use ddrive init");

  await loadCredentialsFromFile(p);
}

loadCredentialsFromFile(String absPath) async {
  Credentials credentials;
  http.Client c = new http.Client();

  File f = new File(path.join(gdPath(absPath), "credentials.json"));
  if(await f.exists()) {
    credentials =  new Credentials.fromJson(await f.readAsString());

    auth.AccessCredentials accessCredentials = new auth.AccessCredentials(credentials.accessToken, credentials.refreshToken, credentials.scopes);
    accessCredentials = await auth.refreshCredentials(
        new auth.ClientId( Defaults.ClientId, Defaults.Secret), accessCredentials, c);

    c =  auth.authenticatedClient(c, accessCredentials);
    api = new drive.DriveApi(c);

    c.close();
  }else {
    throw new StateError("no gd context is found; use ddrive init");
  }
}

initialize(String absPath) async {
  File f = new File(path.join(gdPath(absPath), "credentials.json"));

  if(!await FileSystemEntity.isDirectory(absPath)) throw new ArgumentError("$absPath is not a directory");

  if(!await f.exists()) {
    f.createSync(recursive: true);
  }
}

////////////////
askForAuthorization(String absPath) async {
  File f = new File( path.join( gdPath(absPath), 'credentials.json') );
  http.Client c = new http.Client();
  if(await f.exists()) {
    credentials =  new Credentials.fromJson(await f.readAsString());
  }else {
    f.createSync();
  }

  void prompt(String url) {
    print('''Please go to the following URL and grant access:");
      => $url");
    ''');
  }

  auth.AccessCredentials accessCredentials = await auth.obtainAccessCredentialsViaUserConsent(
      new auth.ClientId( Defaults.ClientId, Defaults.Secret), Defaults.Scopes, c, prompt);
  c =  auth.authenticatedClient(c, accessCredentials);

  credentials =  new Credentials(Defaults.ClientId, Defaults.Secret, accessCredentials.accessToken, accessCredentials.refreshToken, accessCredentials.scopes);
  f.writeAsStringSync(Credentials.toJson(credentials));

  c.close();
}

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
    var accessTokenJson = {"type" : c.accessToken.type, "data" : c.accessToken.data, "expiry" : c.accessToken.expiry.toUtc().millisecondsSinceEpoch};
    return JSON.encode({"clientId": "${c.clientId}", "secret": "${c.secret}", "accessToken": accessTokenJson, "refreshToken" : c.refreshToken, "scopes": c.scopes});
  }
}

