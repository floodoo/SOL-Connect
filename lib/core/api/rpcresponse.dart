import 'dart:convert';
import 'package:http/http.dart' as http;

class RPCResponse {
  String errorMessage = "";
  int errorCode = 0;

  dynamic payload = {};
  String appId = "";
  String rpcVersion = "2.0";

  static RPCResponse handle(http.Response httpResponse) {
    RPCResponse response = RPCResponse();

    //Erstmal den Statuscode checken
    if (httpResponse.statusCode != 200) {
      response.errorCode = httpResponse.statusCode;
      response.errorMessage = "Die Anfrage hat mit dem http Statuscode " +
          httpResponse.statusCode.toString() +
          " geantwortet!";
      return response;
    }

    dynamic json = jsonDecode(httpResponse.body);

    //Standart Daten auszulesen
    response.appId = json['id'];
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
      response.errorMessage = json['error']['message'];
      response.errorCode = json['error']['code'];
      return response;
    }

    //Die Antwort hat nicht den HTTP statuscode 200!
    return response;
  }

/// @return true - Wenn der Fehler am http liegt
  bool isHttpError() {
    return errorMessage.isEmpty && payload.isEmpty;
  }

  /// @return true - Wenn der Handler einen Error hat
  bool isError() {
    return errorMessage.isNotEmpty || isHttpError();
  }
}
