//Dieses Objekt ist dafür zuständig eine Excel Datei einzulesen

class FileHandler {
  static void readFile({String path = ""}) {
    if (path.isEmpty) throw Exception("Der Pfad existiert nicht");
  }
}
