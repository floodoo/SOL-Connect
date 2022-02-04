
// ignore_for_file: constant_identifier_names

///Klasse um SOLC-API Server antworten zu handlen
class SOLCResponse {
  
  //Server Codes
  //Codes 0-99 keine Errors
	static const int CODE_SUCCESS = 0;
	static const int CODE_READY = 1;
  static const int CODE_SEND_READY = 2;
	
	//Codes 100-... Error codes
	static const int CODE_UNKNOWN_ERROR = 100;
	static const int CODE_MISSING_PAYLOAD = 101;
	static const int CODE_NOT_AUTHENTICATED = 102;
	static const int CODE_INSUFICCIENT_PERMISSIONS = 103;
	static const int CODE_ARGUMENT_PARSE_ERROR = 104;
	static const int CODE_ID_NOT_MATCH = 105;
	static const int CODE_HTTP_ERROR = 106;
	static const int CODE_ENTRY_MISSING = 107;

  int _responseCode = 0;
  dynamic _payload;
  String _errorMessage = "";

  final dynamic _body;

  SOLCResponse(this._body);

  static SOLCResponse handle(dynamic body) {
    SOLCResponse response = SOLCResponse(body);
    
    if(response._body['code'] != null) {
      response._responseCode = response._body['code'];
    } else {
      //Invalid response
      return response;
    }

    if(response._responseCode < 100) {
      if(response._body['data'] != null) {
        response._payload = response._body['data'];
      }
    } else {
      if(response._body['error'] != null) {
        response._errorMessage = response._body['error'];
      }
    }

    return response;
  }

  dynamic get originalBody => _body;

  bool get isError => responseCode >= 100;

  String get errorMessage => _errorMessage;

  ///Codes 0-99 = Status Codes. 100+ = Error Codes
  int get responseCode => _responseCode;

  dynamic get payload => _payload;
}