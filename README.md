# feature-brancher

# Clone Repo, Create GitHub Issue and Feature Branch

Dieses Skript klont ein Repository, erstellt ein GitHub-Issue und generiert automatisch einen Feature-Branch basierend auf dem Titel des Issues.

## Voraussetzungen

- **GitHub CLI (`gh`)** muss installiert und authentifiziert sein:
  ```bash
  sudo apt install gh
  gh auth login
  ```
- **`git`** muss installiert sein:
  ```bash
  sudo apt install git
  ```

## Konfigurationsdatei (`config.conf`)

Erstelle eine Datei `config.conf` im selben Verzeichnis wie das Skript mit folgendem Inhalt:

```bash
# Zielverzeichnis für den Klon des Repositories
TARGET_DIR="/home/username/projects"

# Basis-URL des GitHub-Servers
BASE_URL="https://github.com/dein-github-username"
```

- `TARGET_DIR`: Lokales Verzeichnis, in das das Repository geklont wird.
- `BASE_URL`: Basis-URL deines GitHub-Repositories (z. B. `https://github.com/dnschwarzer`).

## Nutzung

```bash
./clone_repo_create_issue_branch.sh <repo-name> <titel> [beschreibung]
```

### Beispiel

```bash
./clone_repo_create_issue_branch.sh PlotFactory "Upgrade to 1.0.0" "Beschreibung des Updates"
```

- **`<repo-name>`**: Name des Repositories (z. B. `PlotFactory`).
- **`<titel>`**: Titel des Issues (z. B. `"Upgrade to 1.0.0"`).
- **`[beschreibung]`** *(optional)*: Beschreibung des Issues.

### Ergebnis:
- Das Repository `https://github.com/dnschwarzer/PlotFactory` wird in das Verzeichnis `/home/username/projects/PlotFactory` geklont.
- Es wird geprüft, ob der Branch `develop`, `main` oder `master` existiert und entsprechend ausgecheckt.
- Ein GitHub-Issue wird erstellt.
- Ein Feature-Branch wird erstellt und gepusht:
  ```bash
  feature/<issue-id>_<erstes-wort>/<issue-id>_<letztes-wort>
  ```

### Beispiel-Branch-Name:
```bash
feature/123_upgrade/123_1.0.0
```

## Hinweise
- Punkte in Versionsnummern bleiben erhalten.
- Sonderzeichen im Titel werden durch `-` ersetzt, um einen gültigen Branch-Namen zu erzeugen.
- Nach dem Erstellen und Pushen bleibt das Skript automatisch auf dem neuen Feature-Branch.

## Fehlerbehandlung
- Wenn `gh` nicht installiert oder nicht authentifiziert ist, gibt das Skript eine Fehlermeldung aus.
- Wenn kein bevorzugter Branch (`develop`, `main`, `master`) existiert, bricht das Skript ab.

## Beispiel-Konfigurationsdatei `config.conf`

```bash
TARGET_DIR="/home/dennis/Desktop/GIT"
BASE_URL="https://github.com/dnschwarzer"
```

---

Mit diesem Skript kannst du deine Entwicklung automatisieren und strukturierte Feature-Branches direkt aus GitHub-Issues erstellen.
