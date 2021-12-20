import 'package:http/http.dart' as http;
import 'dart:convert';
import 'rpcresponse.dart' as rh;

class Gateway {
  static const types = {
    'CLASS': 1,
    'TEACHER': 2,
    'SUBJECT': 2,
    'ROOM': 3,
    'STUDENT': 4
  };

  String applicationName = "default";
  String sessionId = "";
  int personId = -1;
  int klasseId = -1;

  final String URL =
      "https://hepta.webuntis.com/WebUntis/jsonrpc.do?school=bbs1-mainz";
  bool sessionValid = false;

  Gateway(String appID) {
    applicationName = appID;
  }

  void createSession(username, password) async {
    rh.RPCResponse response = await query({
      "id": applicationName,
      "method": "authenticate",
      "params": {
        "user": username,
        "password": password,
        "client": applicationName
      },
      "jsonrpc": 2.0
    });

    //TODO bessere error Nachrichten vorallem bei bekannen Error codes
    if (response.isHttpError())
      throw Exception("Ein http Fehler ist aufegteten: " +
          response.errorMessage.toString() +
          "(" +
          response.errorCode.toString() +
          ")");
    else if (response.isError()) {
      if (response.errorCode == -8504) {
        throw Exception("Benutzename oder Passwort falsch");
      } else
        throw new Exception("Ein Fehler ist aufgetreten: " +
            response.errorMessage.toString() +
            "(" +
            response.errorCode.toString() +
            ")");
    }

    sessionId = response.payload['sessionId'];
    personId = response.payload['personId'];
    klasseId = response.payload['klasseId'];

    print("Login Successfull, sessionID recieved");
  }

  Future<rh.RPCResponse> query(Object data) async {
    return rh.RPCResponse.handle(await http.Client().post(Uri.parse(URL),
        headers: {'Content-type': 'application/json'}, body: jsonEncode(data)));
  }
}
