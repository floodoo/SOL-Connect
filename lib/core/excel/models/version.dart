/*Author Philipp Gersch*/

class Version {
	
	final int _major;
	final int _minor;
	final int _patch;
	
	Version(this._major, this._minor, this._patch);
	
	///Gibt wahr zurück, wenn v1 älter als v2 ist
	static bool isOlder(Version v1, Version v2) {
		if(v1._major < v2._major) {
			return true;
		}
		if(v1._major <= v2._major && v1._minor < v2._minor) {
			return true;
		}
		if(v1._major <= v2._major && v1._minor <= v2._minor && v1._patch < v2._patch) {
			return true;
		}
		return false;
	}
	
	///Konvertiert ein String in ein Version Objekt
	static Version of(String version) {
		var subVersions = version.split(".");
		if(subVersions.isEmpty) {
		  return Version(1, 0, 0);
		} else {
			int major = 1;
			int minor = 0;
			int patch = 0;
			for(int i = 0; i < (subVersions.length >= 3 ? 3 : subVersions.length); i++) {
        if(i == 0) {
          major = int.parse(subVersions[i]);
        } else if(i == 1) {
          minor = int.parse(subVersions[i]);
        } else if(i == 2) {
          patch = int.parse(subVersions[i]);
        }
			}
			return Version(major, minor, patch);
		}
	}
	
	@override
  String toString() {
		return "$_major.$_minor.$_patch";
	}
}
