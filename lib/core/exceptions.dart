class WrongCredentiansException implements Exception {
  WrongCredentiansException({String cause = "Falscher Benutzename oder Passwort!"});
}

class FailedToRefreshSessionException implements Exception {
  FailedToRefreshSessionException({String cause = "Etwas ist beim refreshen der aktuellen Session schiefgelaufen"});
}

class FailedToEstablishExcelServerConnection implements Exception {
  FailedToEstablishExcelServerConnection({String cause= ""});
}

class ExcelConvertConnectionError implements Exception {
  ExcelConvertConnectionError({String cause= ""});
}

class ExcelConversionAlreadyActive implements Exception {
  ExcelConversionAlreadyActive({String cause=""});
}

class ExcelConversionServerError implements Exception {
  ExcelConversionServerError({String cause = ""});
}
