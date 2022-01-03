/*Author Philipp Gersch*/

class WrongCredentiansException implements Exception {
  WrongCredentiansException({String cause = "Falscher Benutzename oder Passwort!"});
}

class FailedToRefreshSessionException implements Exception {
  FailedToRefreshSessionException({String cause = "Etwas ist beim refreshen der aktuellen Session schiefgelaufen"});
}

class FailedToEstablishExcelServerConnection implements Exception {
  String cause = "";
  FailedToEstablishExcelServerConnection(this.cause);

  @override
  String toString() {
    return runtimeType.toString() + ": " + cause;
  }
}

class ExcelConversionConnectionError implements Exception {
  String cause = "";
  ExcelConversionConnectionError(this.cause);

  @override
  String toString() {
    return runtimeType.toString() + ": " + cause;
  }
}

class ExcelConversionAlreadyActive implements Exception {
  String cause = "";
  ExcelConversionAlreadyActive(this.cause);

  @override
  String toString() {
    return runtimeType.toString() + ": " + cause;
  }
}

class ExcelConversionServerError implements Exception {
  String cause = "";
  ExcelConversionServerError(this.cause);

  @override
  String toString() {
    return runtimeType.toString() + ": " + cause;
  }
}

class ExcelMergeNonSchoolBlockException implements Exception {
  String cause = "";
  ExcelMergeNonSchoolBlockException(this.cause);

  @override
  String toString() {
    return runtimeType.toString() + ": " + cause;
  }
}

class ExcelMergeTimetableNotMatchException implements Exception {
  String cause = "";
  ExcelMergeTimetableNotMatchException(this.cause);

  @override
  String toString() {
    return runtimeType.toString() + ": " + cause;
  }
}

class ExcelMergeTimetableNotFound implements Exception {
  String cause = "";
  ExcelMergeTimetableNotFound(this.cause);

  @override
  String toString() {
    return runtimeType.toString() + ": " + cause;
  }
}
//Excel Datei konnte nicht für den angegebenen Stundenplan verifiziert werden.
class ExcelMergeFileNotVerified implements Exception {
  String cause = "";
  ExcelMergeFileNotVerified(this.cause);

  @override
  String toString() {
    return runtimeType.toString() + ": " + cause;
  }
}

