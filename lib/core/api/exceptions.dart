class WrongCredentiansException implements Exception {
  WrongCredentiansException({String cause = "Falscher Benutzename oder Passwort!"});
}

class FailedToRefreshSessionException implements Exception {
  FailedToRefreshSessionException({String cause = "Etwas ist beim refreshen der aktuellen Session schiefgelaufen"});
}
