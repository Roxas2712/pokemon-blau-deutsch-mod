# Herkunft der deutschen Texte – Blaue Edition

Die Mod wird lokal mit `tools/build_official_german_mod.py` aus einer
unveränderten deutschen ROM von **Pokémon Blaue Edition** erzeugt.

Aus der ROM stammen:

- Dialoge und Pokédex-Texte
- Pokémon-, Attacken-, Item-, Trainer- und Typnamen
- Pokédex-Kategorien
- der vollständige deutsche Font
- die Titelgrafik „BLAUE EDITION“

Engine-Texte werden, soweit möglich, über ihre englischen ROM-Texte den
offiziellen deutschen Fassungen zugeordnet. Nur Gen1Recomp-Zusatzfunktionen
ohne Game-Boy-Gegenstück stehen als geprüfte Übersetzungen im Buildskript.

Die ROM wird ausschließlich gelesen und weder in die Mod noch in das
Mod-Archiv kopiert.

## Lokaler Neuaufbau

Benötigt werden die deutsche ROM mit SHA-1
`20e72dc6f41493eee1fdd0cef54214e6c3389688` und die Symboldatei des
bytegenau passenden deutschen Disassembly-Builds.

```sh
python3 tools/build_official_german_mod.py \
  --version blue \
  --rom "/Pfad/Pokemon - Blaue Edition (Germany) (SGB Enhanced).gb" \
  --symbols "/Pfad/pokered-de/pokeblue.sym"
```

Danach:

```sh
MODKIT_LUAJIT="$PWD/.tools/luajit-src/src/luajit" \
  python3 tools/modkit.py validate deutsch-blau --base imported --strict
python3 tools/modkit.py lint deutsch-blau
```
