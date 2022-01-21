/*Author Philipp Gersch */

import 'dart:convert';
import 'package:http/http.dart' as http;

class RPCResponse {
  String _statusMessage = "success";
  int _errorCode = 0;
  dynamic payload = {};

  String appId = "";
  String rpcVersion = "2.0";

  http.Response? originalResponse;

  RPCResponse(this.originalResponse);

  //Simuliert eine künstliche Abfrage mit einem bereits gegebenen http body
  static RPCResponse handleArtifical(dynamic httpResponseBody) {
    
    //print(httpResponseBody + "\n\n\n_____________________");
    RPCResponse response = RPCResponse(null);
    
    dynamic json = jsonDecode(httpResponseBody);

    //Standart Daten auszulesen
    if (json['id'].runtimeType == int) {
      response.appId = json['id'];
    } else {
      response.appId = "null";
    }

    response.rpcVersion = json['jsonrpc'];

    //Lese die Daten aus
    var result = json['result'];
    if (result != null) {
      response.payload = result;
      return response;
    }

    //wenn kein result, versuche einen Error auszulesen
    var error = json['error'];
    if (error != null) {
      response._statusMessage = json['error']['message'];
      response._errorCode = json['error']['code'];
      return response;
    }

    //Die Antwort hat nicht den HTTP statuscode 200!
    return response;
  }

  static RPCResponse handle(http.Response httpResponse) {

    //Erstmal den Statuscode checken
    if (httpResponse.statusCode != 200) {
      RPCResponse err = RPCResponse(httpResponse);
      err._statusMessage = "http error";
      err._errorCode = httpResponse.statusCode;
      return err;
    }
    

    RPCResponse generated = handleArtifical(httpResponse.body);
    generated.originalResponse = httpResponse;
    generated._errorCode = httpResponse.statusCode;
    return generated;
  }

  /// @return true - Wenn der Fehler am http liegt
  bool isHttpError() {
    return payload.isEmpty && _statusMessage == "http error";
  }

  /// @return true - Wenn der Handler einen Error hat
  bool isError() {
    return _statusMessage != "success" || isHttpError();
  }

  String getErrorMessage() {
    return _statusMessage;
  }

  int getErrorCode() {
    return _errorCode;
  }

  dynamic getPayloadData() {
    return payload;
  }
}
