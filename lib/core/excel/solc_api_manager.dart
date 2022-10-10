import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:logger/logger.dart';
import 'package:sol_connect/core/api/models/utils.dart';
import 'package:sol_connect/core/api/usersession.dart';
import 'package:sol_connect/core/excel/models/phasestatus.dart';
import 'package:sol_connect/core/excel/models/version.dart';
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
  static const int timeoutSeconds = 5; //Throw a timeout if a response does not come within x seconds

  static final Version buildRequired = Version.of("2.1.5");

  SOLCApiManager(this._inetAddress, this._port);

  void setServerAddress(String inetAddress) {
    _inetAddress = inetAddress;
  }

  void setServerPort(int port) {
    _port = port;
  }

  String get inetAddress => _inetAddress;

  int get port => _port;

  Future<Version> getVersion() async {
    SOLCResponse? response = await _querySOLC(command: "version");
    if (response != null) {
      return Version.of(response.payload['displayValue']);
    }
    return Version(1, 0, 0);
  }

  ///Wirft eine Exception wenn ein Fehlercode auftritt
  Future<PhaseStatus?> getSchoolClassInfo({required int schoolClassId}) async {
    SOLCResponse? response = await _querySOLC(command: "phase-status <$schoolClassId>");
    if (response != null) {
      return PhaseStatus(response.payload);
    }
    return null;
  }

  Future<List<int>> downloadVirtualSheet({required int schoolClassId}) async {
    List<int> bytes = [];
    await _querySOLC(command: "download-file <$schoolClassId>", downloadBytes: bytes);
    return bytes;
  }

  ///Wirft eine Exception wenn ein Fehlercode auftritt
  Future<void> downloadSheet({required int schoolClassId, required File targetFile}) async {
    List<int> bytes = [];
    await _querySOLC(command: "download-file <$schoolClassId>", downloadBytes: bytes);

    await targetFile.create(recursive: true);
    await targetFile.writeAsBytes(bytes);
  }

  ///Wirft eine Exception wenn ein Fehlercode auftritt
  ///
  ///**ACHTUNG! Bei erfolgreichem hochladen wird der user automatisch serverseitig abgemeldet!**
  Future<void> uploadSheet(
      {required UserSession authenticatedUser,
      required int schoolClassId,
      required DateTime blockStart,
      required DateTime blockEnd,
      required File file}) async {
    await _querySOLC(
        uploadFileSource: file,
        command:
            "upload-file <${authenticatedUser.sessionid}> <${authenticatedUser.bearerToken}> <$schoolClassId> <${Utils.convertToUntisDate(blockStart)}> <${Utils.convertToUntisDate(blockEnd)}>");
    await authenticatedUser.regenerateSession();
  }

  ///Transferdata ist eigentlich nur eine Datei
  ///Transferdata wird gebraucht, wenn ein Befehl einen Dateiupload oder Download inizialisiert.
  ///
  ///Zurückgegebene Werte können null sein, je nachdem was für ein Befehl benutzt wurde.
  ///Ein rückgabewert gibt es nur wenn eine Serverantwort im JSON Format kommt bzw wenn der Code 0 (SUCCESS) ist.
  ///Ansonsten wird alles über die File Objekte gehandled
  ///Spezielle Exceptions:
  ///* `SOLCServerError` Hat zusätzlich noch die ursprüngliche Nachricht
  ///
  ///Folgende "normale" Exceptions können geworfen werden:
  ///* `UploadFileNotSpecifiedException` Wenn ein Befehl ein Dateiupload erwartet diese jedoch nicht angegeben wurde
  ///* `UploadFileNotFoundException` Wenn die hochzuladene Datei im System nicht gefunden werden konnte bzw. nicht existiert
  ///* `DownloadFileNotFoundException` Wenn keine Datei zum Download nicht angegeben wurde
  Future<SOLCResponse?> _querySOLC({required String command, File? uploadFileSource, List<int>? downloadBytes}) async {
    SOLCResponse? returnValue;
    dynamic exception;

    try {
      _activeSockets = _activeSockets + 1;
      final socket = await Socket.connect(_inetAddress, _port);

      //Sende den Befehl
      socket.writeln(command);
      await socket.flush();

      void throwException(Exception e) {
        exception = e;
        socket.close();
      }

      bool awaitFileStream = false;

      if (downloadBytes != null) {
        downloadBytes.clear();
      }

      var subscription = socket.listen(
        (event) async {
          if (awaitFileStream) {
            if (downloadBytes == null) {
              throwException(DownloadFileNotFoundException("Kein Ziel zum Download angegeben"));
              return;
            }
            downloadBytes.addAll(event);
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
            throwException(
                SOLCServerError("${response.errorMessage} (SOLC Error Code: ${response.responseCode})", response));
            return;
          }

          //Einfache JSON Antwort
          if (response.responseCode == SOLCResponse.CODE_SUCCESS) {
            returnValue = response;
            socket.close();
            return;
          }

          //Server bereit einen Dateiupload zu empfangen
          if (response.responseCode == SOLCResponse.CODE_READY) {
            if (uploadFileSource == null) {
              throwException(UploadFileNotSpecifiedException("Keine Datei zum Upload angegeben"));
              socket.close();
              return;
            }
            if (!(await uploadFileSource.exists())) {
              throwException(UploadFileNotFoundException("Datei zum Upload existiert nicht"));
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
          throwException(Exception("Ein Fehler ist bei der Verbindung zum SOLC-API Server aufgetreten"));
        },
      );

      await subscription.asFuture<void>().timeout(const Duration(seconds: timeoutSeconds), onTimeout: () {
        throwException(SOLCServerResponseTimeoutException("Timeout after $timeoutSeconds seconds"));
      });

      await socket.close();
      await subscription.cancel();

      _activeSockets--;
      log.d("Connection for SOLC command '$command' closed. $_activeSockets active connections.");
    } on Exception catch (error) {
      _activeSockets--;
      throw FailedToEstablishSOLCServerConnection(
          "Konnte keine Verbindung zum Konvertierungsserver $_inetAddress herstellen: $error");
    }
    if (exception != null) {
      throw exception;
    }
    return returnValue;
  }
}
