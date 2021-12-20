import 'package:http/http.dart' as http;
import 'dart:convert';

class Gateway {
  String applicationName = "defaule";
  String sessionCode = "";
  final String URL = "https://hepa.webuntis.com/jsonrpc.do?school=bbs1-mainz";
  bool sessionValid = false;

  Gateway(String appID) {
    applicationName = appID;
  }

  void createSession(username, password) async {
    final response = await http.Client().post(Uri.parse(URL), headers: {
      'Content-type': 'application/json'
    }, body: {
      jsonEncode({
        "id": applicationName,
        "method": "authenticate",
        "params": {
          "user": username,
          "password": password,
          "client": applicationName
        },
        "jsonrpc": 2.0
      })
    });

    print(response.body);

    if (response.statusCode == 200) {
      sessionValid = true;
    }
  }
}
