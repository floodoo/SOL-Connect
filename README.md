<a href="https://www.freepik.com/photos/background">Background photo created by rawpixel.com - www.freepik.com</a>

## Excel Server ausführen:

Ausführbare Programme finden sich unter:
> /ExcelServer/binaries/

Dieses Programm lässt sich generell mit 2 Argumenten konfigurieren:
- Maximale Anzahl an Clients, die gleichzeitig verbunden sein dürfen.
- Maximale Zeit, die ein Client mit dem Server verbunden sein darf (Angegeben in Millisekunden!)

Beide Dateien benötigen eine Java installation
- Min JRE Version: 1.8
- Max JRE Version: 1.11

### EXE Datei ausführen
___

Die Exe Datei besitzt beide Argumente vordefiniert: **10 Clients und Maximal 10 Sekunden timeout.**<br>
Diese lässt sich auf Windows Systemen mit einem einfache Doppelklick öffnen.<br>
Um Aktionen zu überwachen öffnen sich ein Konsolenfenster in dem alles geloggt wird.

### JAR Datei ausführen
___

Diese Datei lässt sich nur anständig in einem Terminal ausführen.
Man kann aber beide Argumente selbst bestimmen.

- Zum Pfad welchseln in der die jar gespeichert ist.
- Folgenden Befehl ausführen:
```java -Xmx1G -jar excelServer.jar 10 10000```


___ 

### Excel Server dependencies:

- <a>https://github.com/DevKevYT/devscript</a> version: '1.9.1'<br>
- <a>https://mvnrepository.com/artifact/org.apache.poi/poi</a> version: '5.1.0'<br>
- <a>https://mvnrepository.com/artifact/org.apache.poi/poi-ooxml</a> version: '5.1.0'<br>
- <a>https://mvnrepository.com/artifact/org.apache.xmlbeans/xmlbeans</a> version: '2.3.0'<br>
- <a>https://mvnrepository.com/artifact/dom4j/dom4j</a> version: '1.6.1'<br>
- <a>https://mvnrepository.com/artifact/org.apache.commons/commons-collections4</a> version: '4.3'<br>
- <a>https://mvnrepository.com/artifact/org.apache.commons/commons-compress</a> version: '1.18'<br>
- <a>https://mvnrepository.com/artifact/org.apache.poi/ooxml-schemas</a> version: '4.1'
