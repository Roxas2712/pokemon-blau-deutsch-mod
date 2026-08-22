# Changelog

## Unveröffentlicht – Stilllegung

- Diese editionsspezifische Einzel-Mod wird nicht mehr weiterentwickelt; das
  Repository bleibt als Archiv der bisherigen Veröffentlichungen erhalten.
- Die gepflegte Nachfolgeversion ist
  [Translation German Universal](https://github.com/Roxas2712/translation-german-universal).
  Die jeweils neueste Veröffentlichung ist über
  [GitHub Releases](https://github.com/Roxas2712/translation-german-universal/releases/latest)
  verfügbar.

## 1.1.1

### Behoben

- Das Release-Archiv wird unter dem vom Launcher erwarteten kanonischen Namen
  `deutsch-blau-1.1.1.zip` bereitgestellt.
- Tests und Screenshots werden nicht mehr in das installierbare Mod-Archiv
  aufgenommen. Die Laufzeitinhalte bleiben gegenüber 1.1.0 unverändert.

## 1.1.0

### Behoben

- Alle 151 Pokédex-Kategorien sind nun korrekt nach Pokémon-Art zugeordnet.
  Dadurch erscheinen unter anderem GLUMANDA als ECHSEN-, BISASAM als SAMEN-
  und SCHIGGY als MINIKRÖTEN-POKéMON statt mit verschobenen Kategorien.
- Neuere Engine-Texte und rohe Laufzeitbeschriftungen werden ebenfalls
  übersetzt; englische Rückfälle wie `USE`, `Enemy` oder der aktuelle
  Trainerwechsel-Satz bleiben nicht mehr sichtbar.
- Gefangene Pokémon verwenden den deutschen Artnamen auch als vorgeschlagenen
  Standardnamen; die Levelaufstiegswerte zeigen ANGR, VERT, INIT und SPEZ.
- Die Fenster für JA/NEIN sind sowohl allgemein als auch am Spielautomaten
  breit genug für `NEIN`.
- Ein ROM-freier Grafik-Transform zeichnet `ARENA` statt `GYM` direkt auf
  das vom Spieler importierte Overworld-Tileset.
- Die BOIS-CLUB-GAMES-Markenbezeichnung bleibt auf dem Titelbild unübersetzt
  und passt wieder in die vorgesehene Zeile.

### Getestet

- Neuer ROM-freier Regressionstest für Artennamen, Pokédex-Kategorien,
  Kampftexte, Laufzeitbeschriftungen und Fenstergeometrie.

## 1.0.2

### Behoben

- Das klassische Kampfmenü verwendet die breitere Geometrie der deutschen
  Originalfassung. Dadurch bleibt `FLUCHT` vollständig innerhalb des Rahmens;
  Beschriftungen und Cursor entsprechen den deutschen ROM-Koordinaten.

## 1.0.1

### Behoben

- Innerhalb des laufenden Spiels werden Editionsnamen durchgängig als `Blau`,
  `Blaue Edition` und `Pokémon Blaue Edition` angezeigt.

## 1.0.0

### Hinzugefügt

- 2.582 originale deutsche Dialog- und Pokédextexte aus der Blauen Edition.
- Deutsche Namen für Pokémon, Attacken, Items, Trainerklassen und Typen.
- Originale deutsche Schriftzeichen und Titelgrafik „BLAUE EDITION“.
- Deutsche Gen1Recomp-Menüs und Zusatzoberflächen.
- Korrekte Kampftexte, Gegnerbezeichnung, Status- und Wertekürzel.
- Versionsschutz: Die Mod verändert ausschließlich Pokémon Blau.
