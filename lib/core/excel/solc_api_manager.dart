
import 'dart:convert';
import 'dart:io';

import 'package:logger/logger.dart';
import 'package:sol_connect/core/api/models/utils.dart';
import 'package:sol_connect/core/api/usersession.dart';
import 'package:sol_connect/core/excel/models/phasestatus.dart';
import 'package:sol_connect/core/excel/solcresponse.dart';
import 'package:sol_connect/core/exceptions.dart';
import 'package:sol_connect/util/logger.util.dart';

//Vielleicht einen besseren Namen ausdenken
//Handled alles SOLC-API Server zeug

class SOLCApiManager {
  final Logger log = getLogger();

  int _activeSockets = 0;

  String _inetAddress;
  int _port;

  SOLCApiManager(this._inetAddress, this._port);

  void setServerAddress(String inetAddress) {
    _inetAddress = inetAddress;
  }

  void setServerPort(int port) {
    _port = port;
  }

  String get inetAddress => _inetAddress;

  int get port => _port;

  ///Wirft eine Exception wenn ein Fehlercode auftritt
  Future<PhaseStatus?> getKlasseInfo({required int klasseId}) async {
    SOLCResponse? response = await _querySOLC(command: "phase-status <" + klasseId.toString() + ">");
    if (response != null) {
      return PhaseStatus(response.payload);
    }
    return null;
  }

  ///Wirft eine Exception wenn ein Fehlercode auftritt
  Future<void> downloadSheet({required int klasseId, required File targetFile}) async {
    await _querySOLC(command: "download-file <" + klasseId.toString() + ">", downloadFileTarget: targetFile);
  }

  ///Wirft eine Exception wenn ein Fehlercode auftritt
  ///
  ///**ACHTUNG! Bei erfolgreichem hochladen wird der user automatisch serverseitig abgemeldet!** 
  Future<void> uploadSheet(
      {required UserSession authenticatedUser,
      required int klasseId,
      required DateTime blockStart,
      required DateTime blockEnd,
      required File file}) async {
    await _querySOLC(
        command: "upload-file "
                "<" +
            authenticatedUser.sessionid +
            ">"
                "<" +
            authenticatedUser.bearerToken +
            ">"
                "<" +
            klasseId.toString() +
            ">"
                "<" +
            Utils.convertToUntisDate(blockStart) +
            ">"
                "<" +
            Utils.convertToUntisDate(blockEnd) +
            ">");
    await authenticatedUser.regenerateSession();
  }

  ///Transferdata ist eigentlich nur eine Datei
  ///Transferdata wird gebraucht, wenn ein Befehl einen Dateiupload oder Download inizialisiert.
  ///
  ///Zurückgegebene Werte können null sein, je nachdem was für ein Befehl benutzt wurde.
  ///Ein rückgabewert gibt es nur wenn eine Serverantwort im JSON Format kommt bzw wenn der Code 0 (SUCCESS) ist.
  ///Ansonsten wird alles über die File Objekte gehandled
  Future<SOLCResponse?> _querySOLC({required String command, File? uploadFileSource, File? downloadFileTarget}) async {
    SOLCResponse? returnValue;
    dynamic exception;

    try {
      _activeSockets = _activeSockets + 1;
      final socket = await Socket.connect(_inetAddress, _port);

      //Sende den Befehl
      socket.writeln(command);
      await socket.flush();
      bool awaitFileStream = false;

      var subscription = socket.listen(
        (event) async {
          if (awaitFileStream) {
            if (downloadFileTarget == null) {
              exception = Exception("Kein Dateiziel zum Download angegeben");
              return;
            }
            await downloadFileTarget.create(recursive: true);
            await downloadFileTarget.writeAsBytes(event);
            return;
          }

          dynamic decodedMessage = "";
          try {
            decodedMessage = jsonDecode(String.fromCharCodes(event));
          } on FormatException {
            socket.close();
            return;
          }

          SOLCResponse response = SOLCResponse.handle(decodedMessage);
          if (response.isError) {
            exception =
                SOLCServerError(response.errorMessage + " (SOLC Error Code: " + response.responseCode.toString() + ")");
            return;
          }

          //Einfache JSON Antwort
          if (response.responseCode == SOLCResponse.CODE_SUCCESS) {
            returnValue = response;
            socket.close();
            return;
          }

          //Server bereit eine Datei zu uploaden
          if (response.responseCode == SOLCResponse.CODE_READY) {
            if (downloadFileTarget == null) {
              exception = Exception("Keine Datei zum Upload angegeben");
              return;
            }
            if (!(await uploadFileSource!.exists())) {
              exception = Exception("Datei zum Upload existiert nicht");
              return;
            }
            await socket.addStream(uploadFileSource.openRead());
            socket.close();
            return;
          }

          //Server fragt den Client ob er bereit ist eine Datei zu downloaden. Sende ein "ready-to-recieve" und lade die Date als Stream herunter
          if (response.responseCode == SOLCResponse.CODE_SEND_READY) {
            awaitFileStream = true;
            socket.writeln("ready-to-recieve");
            await socket.flush();
            return;
          }
        },
        onError: (error) {
          _activeSockets--;
          exception = SOLCServerError("Ein Fehler ist bei der Verbindung zum SOLC-API Server aufgetreten");
        },
      );

      await subscription.asFuture<void>();
      await subscription.cancel();

      _activeSockets--;
      log.d("Socket closed naturally. " + _activeSockets.toString() + " active sockets.");
    } on Exception catch (error) {
      _activeSockets--;
      throw FailedToEstablishSOLCServerConnection(
          "Konnte keine Verbindung zum Konvertierungsserver " + _inetAddress + " herstellen: " + error.toString());
    }

    if (exception != null) {
      throw exception;
    }
    return returnValue;
  }
}
