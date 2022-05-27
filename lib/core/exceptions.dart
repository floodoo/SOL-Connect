/*Author Philipp Gersch */

import 'package:sol_connect/core/excel/solcresponse.dart';

class FailedToEstablishSOLCServerConnection implements Exception {
  String cause = "";
  FailedToEstablishSOLCServerConnection(this.cause);

  @override
  String toString() {
    return "$runtimeType: $cause";
  }
}

class ExcelConversionConnectionError implements Exception {
  String cause = "";
  ExcelConversionConnectionError(this.cause);

  @override
  String toString() {
    return "$runtimeType: $cause";
  }
}

class ExcelConversionAlreadyActive implements Exception {
  String cause = "";
  ExcelConversionAlreadyActive(this.cause);

  @override
  String toString() {
    return "$runtimeType: $cause";
  }
}

class SOLCServerError implements Exception {
  String cause = "";
  final SOLCResponse? _response;

  SOLCServerError(this.cause, [this._response]);

  SOLCResponse get response => _response!;

  @override
  String toString() {
    return "$runtimeType: $cause";
  }
}

class ExcelMergeNonSchoolBlockException implements Exception {
  String cause = "";
  ExcelMergeNonSchoolBlockException(this.cause);

  @override
  String toString() {
    return "$runtimeType: $cause";
  }
}

class ExcelMergeTimetableNotMatchException implements Exception {
  String cause = "";
  ExcelMergeTimetableNotMatchException(this.cause);

  @override
  String toString() {
    return "$runtimeType: $cause";
  }
}

class ExcelMergeTimetableNotFound implements Exception {
  String cause = "";
  ExcelMergeTimetableNotFound(this.cause);

  @override
  String toString() {
    return "$runtimeType: $cause";
  }
}

// Excel Datei konnte nicht für den angegebenen Stundenplan verifiziert werden.
class ExcelMergeFileNotVerified implements Exception {
  String cause = "";
  ExcelMergeFileNotVerified(this.cause);

  @override
  String toString() {
    return "$runtimeType: $cause";
  }
}

class FailedToFetchUserdata implements Exception {
  String cause = "";
  FailedToFetchUserdata(this.cause);

  @override
  String toString() {
    return "$runtimeType: $cause";
  }
}

class UserAlreadyLoggedInException implements Exception {
  String cause = "";
  UserAlreadyLoggedInException(this.cause);

  @override
  String toString() {
    return "$runtimeType: $cause";
  }
}

class WrongCredentialsException implements Exception {
  String cause = "";
  WrongCredentialsException(this.cause);

  @override
  String toString() {
    return "$runtimeType: $cause";
  }
}

class MissingCredentialsException implements Exception {
  String cause = "";
  MissingCredentialsException(this.cause);

  @override
  String toString() {
    return "$runtimeType: $cause";
  }
}

class ApiConnectionError implements Exception {
  String cause = "";
  ApiConnectionError(this.cause);

  @override
  String toString() {
    return "$runtimeType: $cause";
  }
}

class FailedToFetchNewsException implements Exception {
  String cause = "";
  FailedToFetchNewsException(this.cause);

  @override
  String toString() {
    return "$runtimeType: $cause";
  }
}

class CurrentPhaseplanOutOfRange implements Exception {
  String cause = "";
  CurrentPhaseplanOutOfRange(this.cause);

  @override
  String toString() {
    return "$runtimeType: $cause";
  }
}

class InsufficientPermissionsException implements Exception {
  String cause = "";
  InsufficientPermissionsException(this.cause);

  @override
  String toString() {
    return "$runtimeType: $cause";
  }
}

class UploadFileNotFoundException implements Exception {
  String cause = "";
  UploadFileNotFoundException(this.cause);

  @override
  String toString() {
    return "$runtimeType: $cause";
  }
}

class UploadFileNotSpecifiedException implements Exception {
  String cause = "";
  UploadFileNotSpecifiedException(this.cause);

  @override
  String toString() {
    return "$runtimeType: $cause";
  }
}

class DownloadFileNotFoundException implements Exception {
  String cause = "";
  DownloadFileNotFoundException(this.cause);

  @override
  String toString() {
    return "$runtimeType: $cause";
  }
}

class NextBlockStartNotInRangeException implements Exception {
  String cause = "";
  NextBlockStartNotInRangeException(this.cause);

  @override
  String toString() {
    return "$runtimeType: $cause";
  }
}

class NextBlockEndNotInRangeException implements Exception {
  String cause = "";
  NextBlockEndNotInRangeException(this.cause);

  @override
  String toString() {
    return "$runtimeType: $cause";
  }
}

class SecurityTokenRequired implements Exception {
  String cause = "";
  SecurityTokenRequired(this.cause);

  @override
  String toString() {
    return "$runtimeType: $cause";
  }
}

class InvalidSecurityToken implements Exception {
  String cause = "";
  InvalidSecurityToken(this.cause);

  @override
  String toString() {
    return "$runtimeType: $cause";
  }
}
