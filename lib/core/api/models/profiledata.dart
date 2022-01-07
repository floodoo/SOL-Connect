/*Author Philipp Gersch */

import '../../exceptions.dart';

class ProfileData {

  String _displayName = "";
  String _imageURL = "";

  String _oneDriveClientID = "";
  String _schoolLongName = "";
  int _schoolId = -1;

  ProfileData(dynamic jsonData) {
    
    if(jsonData == null) {
      return;
    }

    if(jsonData['errorMessage'] != null) {
      throw FailedToFetchUserdata(jsonData['errorMessage']);
    }   

    _displayName = jsonData['user']['person']['displayName'];
   
    if(jsonData['user']['person']['imageUrl'] != null) {
      _imageURL = jsonData['user']['person']['imageUrl'];
    }

    if(jsonData['tenant'] != null) {
      _schoolId = jsonData['tenant']['id'];
      _schoolLongName = jsonData['tenant']['displayName'];
    }

    if(jsonData['oneDriveData'] != null) {
      _oneDriveClientID = jsonData['oneDriveData']['oneDriveClientId'];
    }
  }

  ///Der vollständige Name. Der Nachname kommt vor dem Vornahmen.
  ///Falls Vor- und Nachnahme getrennt werden soll gibt es die Funktion `getNameSeparated()`
  ///
  ///Z.B. `"Lustig Peter"`
  String getFirstAndLastName() {
    return _displayName;
  }

  ///Vor und Nachname getrennt. Könnte bei Leuten mit speziellen Namen mehr
  ///als 2 einträge zurückgeben.
  List<String> getNameSeparated() {
    return _displayName.split(" ");
  }

  ///Die URL des Profilbildes
  ///
  ///Z.B. `https://images.webuntis.com/image/5539000/awd4ou5rt23orw8torw978sefg`
  String getProfilePictureURL() {
    return _imageURL;
  }

  ///Die onedrive client id. Vielleich irgendwann mal nützlich keine ahnung.
  String getOnedriveClientId() {
    return _oneDriveClientID;
  }

  ///Der ausführliche Name der Schule
  ///
  ///Z.B. `"BBS I für Gewerbe und Technik"`
  String getSchoolLongName() {
    return _schoolLongName;
  }

  ///Die ID der schule. Vielleicht für andere Abfragen nützlich
  ///
  ///Z.B. `18696`
  int getSchoolId() {
    return _schoolId;
  }
}