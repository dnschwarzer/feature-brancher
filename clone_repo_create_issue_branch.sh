#!/bin/bash

# Überprüfen, ob `gh` installiert ist
if ! command -v gh &> /dev/null; then
  echo "Fehler: Die GitHub CLI (gh) ist nicht installiert. Bitte installiere sie mit 'sudo apt install gh'."
  exit 1
fi

# Überprüfen, ob alle Parameter übergeben wurden
if [ "$#" -lt 2 ]; then
  echo "Nutzung: $0 <repo-name> <titel> [beschreibung]"
  echo "Beispiel: $0 usermgt \"Feature XY hinzufügen\" \"Beschreibung des Features\""
  exit 1
fi

# Authentifizierung überprüfen
if ! gh auth status &> /dev/null; then
  echo "Fehler: Du bist nicht bei GitHub authentifiziert. Führe 'gh auth login' aus, um dich anzumelden."
  exit 1
fi

# Konfigurationsdatei einlesen
CONFIG_FILE="./config.conf"
if [ ! -f "$CONFIG_FILE" ]; then
  echo "Fehler: Konfigurationsdatei '$CONFIG_FILE' nicht gefunden."
  exit 1
fi

# Zielverzeichnis und Basis-URL aus der Konfigurationsdatei auslesen
TARGET_DIR=$(grep "^TARGET_DIR=" "$CONFIG_FILE" | cut -d '=' -f 2 | tr -d '"')
BASE_URL=$(grep "^BASE_URL=" "$CONFIG_FILE" | cut -d '=' -f 2 | tr -d '"')

if [ -z "$TARGET_DIR" ]; then
  echo "Fehler: Kein Zielverzeichnis in der Konfigurationsdatei angegeben."
  exit 1
fi

if [ -z "$BASE_URL" ]; then
  echo "Fehler: Keine Basis-URL in der Konfigurationsdatei angegeben."
  exit 1
fi

# Parameter
REPO_NAME=$1
TITLE=$2
DESCRIPTION=${3:-"Keine Beschreibung angegeben."}  # Optionale Beschreibung
REPO_URL="$BASE_URL/$REPO_NAME"
REPO_DIR="$TARGET_DIR/$REPO_NAME"

# Repository klonen, falls es noch nicht existiert
if [ ! -d "$REPO_DIR" ]; then
  echo "Klonen des Repositories nach: $REPO_DIR"
  git clone "$REPO_URL" "$REPO_DIR"
else
  echo "Repository existiert bereits unter: $REPO_DIR"
fi

# In das Repository wechseln
cd "$REPO_DIR" || { echo "Fehler: Wechsel in das Verzeichnis '$REPO_DIR' fehlgeschlagen."; exit 1; }

# Auf den bevorzugten Branch wechseln (develop, main oder master)
if git show-ref --quiet refs/heads/develop; then
  echo "Wechsel zu 'develop'-Branch"
  git checkout develop
elif git show-ref --quiet refs/heads/main; then
  echo "Wechsel zu 'main'-Branch"
  git checkout main
elif git show-ref --quiet refs/heads/master; then
  echo "Wechsel zu 'master'-Branch"
  git checkout master
else
  echo "Fehler: Kein Branch 'develop', 'main' oder 'master' vorhanden."
  exit 1
fi

# Issue erstellen
REPO_PATH=$(echo "$BASE_URL" | sed -E 's#https://[^/]+/##')/$REPO_NAME
echo "Erstelle Issue im Repository: $REPO_PATH"
ISSUE_OUTPUT=$(gh issue create --repo "$REPO_PATH" --title "$TITLE" --body "$DESCRIPTION" 2>&1)
if [[ "$ISSUE_OUTPUT" == *"https"* ]]; then
  ISSUE_URL=$(echo "$ISSUE_OUTPUT" | grep -o "https://github.com/[^ ]*")
  ISSUE_NUMBER=$(echo "$ISSUE_URL" | grep -oE '[0-9]+$')
else
  echo "Fehler: Das Erstellen des Issues ist fehlgeschlagen."
  echo "$ISSUE_OUTPUT"
  exit 1
fi

# Titel aufteilen, erste und letzte Komponente extrahieren
TITLE_ARRAY=($TITLE)
FIRST_WORD=${TITLE_ARRAY[0],,}  # Erste Komponente (klein)
LAST_WORD=${TITLE_ARRAY[-1],,}  # Letzte Komponente (klein)

# Ersetzen von Sonderzeichen durch "-" außer Punkte für Versionen
FIRST_WORD=$(echo "$FIRST_WORD" | sed 's/[^a-zA-Z0-9.]/-/g')
LAST_WORD=$(echo "$LAST_WORD" | sed 's/[^a-zA-Z0-9.]/-/g')

# Feature-Branch erstellen
BRANCH_NAME="feature/${ISSUE_NUMBER}_${FIRST_WORD}/${ISSUE_NUMBER}_${LAST_WORD}"
echo "Erstelle Feature-Branch: $BRANCH_NAME"
git checkout -b "$BRANCH_NAME"

# Branch pushen
echo "Push des Feature-Branches: $BRANCH_NAME"
git push --set-upstream origin "$BRANCH_NAME"

echo "Feature-Branch $BRANCH_NAME wurde erfolgreich erstellt und gepusht."

# Sicherstellen, dass der aktuelle Branch der erstellte Feature-Branch ist
git checkout "$BRANCH_NAME"