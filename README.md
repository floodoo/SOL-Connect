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

Die Exe Datei besitzt beide Argumente vordefiniert: **10 Clients und Maximal 10 Sekunden timeout.**<br>
Diese lässt sich auf Windows Systemen mit einem einfache Doppelklick öffnen.<br>
Um Aktionen zu überwachen öffnen sich ein Konsolenfenster in dem alles geloggt wird.

### JAR Datei ausführen

Diese Datei lässt sich nur anständig in einem Terminal ausführen.
Man kann aber beide Argumente selbst bestimmen.

- Zum Pfad welchseln in der die jar gespeichert ist.
- Folgenden Befehl ausführen:
```java -Xmx1G -jar excelServer.jar 10 10000```

## Server Funktionen

Grundlegend ist es möglich Befehle an den Server mittels eines einfachen Strings über ein TCP Socket zu senden.
Pro Verbindungsaufbau ist die Befehlszahl auf 1 begrenzt. Bevor die Verbindung vom Server getrennt wird.<br>
Man kann jedoch mehrere Befehle mit einem ";" getrennt senden, die dann gleichzeitig ausgeführt werden.

Wenn Daten vom Server generiert werden, werden sie im JSON Format zurückgegeben.
Es folgt eine kleine Liste möglicher Befehle.

#### convertxssf

## Patchnotes

### 1.0.1
- Behebung einer Schwachstelle.
- Detaillierteres Logging für besseres Monitoring
- Es werden nurnoch Errors geloggt


# Excel Server dependencies:

- <a>https://github.com/DevKevYT/devscript</a> version: '1.9.1'<br>
- <a>https://mvnrepository.com/artifact/org.apache.poi/poi</a> version: '5.1.0'<br>
- <a>https://mvnrepository.com/artifact/org.apache.poi/poi-ooxml</a> version: '5.1.0'<br>
- <a>https://mvnrepository.com/artifact/org.apache.xmlbeans/xmlbeans</a> version: '2.3.0'<br>
- <a>https://mvnrepository.com/artifact/dom4j/dom4j</a> version: '1.6.1'<br>
- <a>https://mvnrepository.com/artifact/org.apache.commons/commons-collections4</a> version: '4.3'<br>
- <a>https://mvnrepository.com/artifact/org.apache.commons/commons-compress</a> version: '1.18'<br>
- <a>https://mvnrepository.com/artifact/org.apache.poi/ooxml-schemas</a> version: '4.1'
