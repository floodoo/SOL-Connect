/*Author Philipp Gersch */

import 'dart:convert';
import 'package:http/http.dart' as http;

class RPCResponse {
  //Fehlercodes
  static const rpcWrongCredentials = -8504;

  String _statusMessage = "";
  int _errorCode = 0;
  int _httpResponse = 0;
  dynamic _payload = {};

  String _appId = "";
  String _rpcVersion = "2.0";

  http.Response? _originalResponse;

  RPCResponse(this._originalResponse);

  //Simuliert eine künstliche Abfrage mit einem bereits gegebenen http body
  static RPCResponse handleArtifical(dynamic httpResponseBody) {
    RPCResponse response = RPCResponse(null);

    dynamic json = jsonDecode(httpResponseBody);

    //Standart Daten auszulesen
    response._appId = json['id'];
    response._rpcVersion = json['jsonrpc'];

    //Lese die Daten aus
    var result = json['result'];
    if (result != null) {
      response._payload = result;
      return response;
    }

    //wenn kein result, versuche einen Error auszulesen
    var error = json['error'];
    if (error != null) {
      response._statusMessage = json['error']['message'];
      response._errorCode = json['error']['code'];
      return response;
    }

    return response;
  }

  static RPCResponse handle(http.Response httpResponse) {
    //Erstmal den Statuscode checken
    if (httpResponse.statusCode != 200) {
      RPCResponse err = RPCResponse(httpResponse);
      err._statusMessage = "http error";
      err._httpResponse = httpResponse.statusCode;
      return err;
    }

    RPCResponse generated = handleArtifical(httpResponse.body);
    generated._originalResponse = httpResponse;
    return generated;
  }

  ///Könnte null sein wenn die Abfrage simuliert wurde
  http.Response? get originalResponse => _originalResponse;

  ///Sollte immer 2.0 sein
  String get rpcVersion => _rpcVersion;

  ///Name der App wie sie in der Anfrage angegeben ist. Hier: SOL-Connect
  String get appName => _appId;

  ///Gibt true zurück, wenn der Fehler API bedingt ist
  bool get isApiError => _statusMessage.isNotEmpty && _payload.isNotEmpty;

  ///Gibt true zurück, wenn der Fehler http bedingt ist
  bool get isHttpError => _payload.isEmpty && _statusMessage == "http error";

  ///Gibt true zurück, wenn ein API oder HTTP Fehler aufgetreten ist
  bool get isError => _statusMessage.isNotEmpty || isHttpError;

  ///Lesbare Fehlermeldung. Leer wenn erfolgreich
  String get errorMessage => _statusMessage;

  ///Fehlercode der von der JSONRPC API generiert wurde. (0 bedeutet kein Error)
  int get rpcResponseCode => _errorCode;

  ///Standart http codes. 404 wenn nicht gefunden, 501 wenn down und 200 wenn erfolg etc...
  int get httpResponseCode => _httpResponse;

  dynamic get payloadData => _payload;
}
