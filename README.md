<a href="https://www.freepik.com/photos/background">Background photo created by rawpixel.com - www.freepik.com</a>

## Arbeiten mit einer Session nach erfolgreichem einloggen
Nach dem einloggen wird einem eine SessionID vergeben.<br>
Es sollte auch der Name der Schule mit Base64 dekodiert werden und im Gateway Objekt gespeichert werden.
<bt>
Bei nachfolgenden Anfragen müssen Cookies für den Header generiert werden:
  - Mit einem ; getrennt
  - Schulname in Base64 "schoolname"
  - SessionID mit namen "JSESSIONID"
  - Diese Daten müssen serialisiert werden.

  -> Schauen wie die Javascript Funktion / Klasse "CookieBuilder" aufgebaut ist und wie die Variablen serialisiert werden
  
  Wenn das nicht passiert kommt ein Error "Invalid Request"
