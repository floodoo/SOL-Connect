/*Author Philipp Gersch */

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

// Excel Datei konnte nicht für den angegebenen Stundenplan verifiziert werden.
class ExcelMergeFileNotVerified implements Exception {
  String cause = "";
  ExcelMergeFileNotVerified(this.cause);

  @override
  String toString() {
    return runtimeType.toString() + ": " + cause;
  }
}

class FailedToFetchUserdata implements Exception {
  String cause = "";
  FailedToFetchUserdata(this.cause);

  @override
  String toString() {
    return runtimeType.toString() + ": " + cause;
  }
}

class UserAlreadyLoggedInException implements Exception {
  String cause = "";
  UserAlreadyLoggedInException(this.cause);

  @override
  String toString() {
    return runtimeType.toString() + ": " + cause;
  }
}

class WrongCredentialsException implements Exception {
  String cause = "";
  WrongCredentialsException(this.cause);

  @override
  String toString() {
    return runtimeType.toString() + ": " + cause;
  }
}

class MissingCredentialsException implements Exception {
  String cause = "";
  MissingCredentialsException(this.cause);

  @override
  String toString() {
    return runtimeType.toString() + ": " + cause;
  }
}

class ApiConnectionError implements Exception {
  String cause = "";
  ApiConnectionError(this.cause);

  @override
  String toString() {
    return runtimeType.toString() + ": " + cause;
  }
}

class FailedToFetchNewsException implements Exception {
  String cause = "";
  FailedToFetchNewsException(this.cause);

  @override
  String toString() {
    return runtimeType.toString() + ": " + cause;
  }
}

class CurrentPhaseplanOutOfRange implements Exception {
  String cause = "";
  CurrentPhaseplanOutOfRange(this.cause);

  @override
  String toString() {
    return runtimeType.toString() + ": " + cause;
  }
}

class InsufficientPermissionsException implements Exception {
  String cause = "";
  InsufficientPermissionsException(this.cause);

  @override
  String toString() {
    return runtimeType.toString() + ": " + cause;
  }
}
