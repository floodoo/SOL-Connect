import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

import 'package:logger/logger.dart';
import 'package:sol_connect/core/api/models/utils.dart';
import 'package:sol_connect/core/api/usersession.dart';
import 'package:sol_connect/core/excel/models/cellcolors.dart';
import 'package:sol_connect/core/excel/models/mergedblock.dart';
import 'package:sol_connect/core/excel/models/phasestatus.dart';
import 'package:sol_connect/core/excel/models/version.dart';
import 'package:sol_connect/util/logger.util.dart';

///Interface für SOLC-API-3 Server
class SOLCApiManager {
  final Logger log = getLogger();

  String _baseURL;
  int _port;
  static const int timeoutSeconds =
      5; //Throw a timeout if a response does not come within x seconds

  static final Version buildRequired = Version.of("3.0.0");

  SOLCApiManager(this._baseURL, this._port);

  void setBaseURL(String baseURL) {
    _baseURL = baseURL;
  }

  void setServerPort(int port) {
    _port = port;
  }

  String get apiAddress => "$_baseURL:$_port/api";

  String get baseURL => _baseURL;

  int get port => _port;

  Future<Version> getVersion() async {
    http.Response response =
        await http.Client().get(Uri.parse("$apiAddress/version"));
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      return Version.of(jsonDecode(response.body)['data']['displayValue']);
    } else {
      return Version(0, 0, 0);
    }
  }

  ///Sendet eine Anfrage an den Server, um Farben einer Excel Datei zu extrahieren.
  Future<CellColors> getExcelColorData(List<int> fileBytes) async {
    var request =
        http.MultipartRequest("POST", Uri.parse("$apiAddress/getcolor"));
    request.files.add(
        http.MultipartFile.fromBytes('sheet', fileBytes, filename: 'sheet'));

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      String json = await convert.utf8.decodeStream(response.stream);
      return CellColors(data: jsonDecode(json)['data'], failed: false);
    }
    return CellColors(failed: true);
  }

  ///Wirft eine Exception wenn ein Fehlercode auftritt
  ///@deprecated
  Future<PhaseStatus?> getSchoolClassInfo({required int schoolClassId}) async {
    //SOLCResponse? response =
    //    await _querySOLC(command: "phase-status <$schoolClassId>");
    //if (response != null) {
    //  return PhaseStatus(response.payload);
    //}
    return null;
  }

  Future<List<int>> downloadVirtualSheet({required int schoolClassId}) async {
    List<int> bytes = [];
    //await _querySOLC(
    //    command: "download-file <$schoolClassId>", downloadBytes: bytes);
    return bytes;
  }

  ///Wirft eine Exception wenn ein Fehlercode auftritt
  Future<void> downloadSheet(
      {required int schoolClassId, required File targetFile}) async {
    List<int> bytes = [];
    //await _querySOLC(
    //    command: "download-file <$schoolClassId>", downloadBytes: bytes);

    await targetFile.create(recursive: true);
    await targetFile.writeAsBytes(bytes);
  }

  ///Wirft eine Exception wenn ein Fehlercode auftritt
  ///
  ///**ACHTUNG! Bei erfolgreichem hochladen wird der user automatisch serverseitig abgemeldet!**
  Future<void> uploadPhasing(
      {required UserSession authenticatedUser,
      required int schoolClassId,
      required MergedBlock block}) async {
    
    ///Wandelt dieses Objekt in eine PhTP gültige JSON um
    var object = {
      "version": "1",
      "classId": schoolClassId,
      "blockStart": Utils.convertToUntisDate(block.blockStart),
      "blockEnd": Utils.convertToUntisDate(block.blockEnd)
    };

    http.Response response = await http.post(Uri.parse("$apiAddress/api/phasing/upload"), 
      headers: {
        "JSESSIONID": authenticatedUser.sessionid,
        "Authentication": "Bearer ${authenticatedUser.bearerToken}"
      },
      body: jsonEncode(object));
  }
}
