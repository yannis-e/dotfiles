#!/bin/bash

# ==============================================================================
# Twitch → Chromecast CLI Tool (debug + stable + retry)
# ==============================================================================

DEFAULT_CHANNEL="bastighg"
DEFAULT_QUALITY="best"
DEFAULT_DEVICE="KD-43XF8505"

MAX_RETRIES=10  # Maximale Anzahl an Versuchen
RETRY_DELAY=2   # Sekunden Wartezeit zwischen den Versuchen

CHANNEL=${1:-$DEFAULT_CHANNEL}
QUALITY=${2:-$DEFAULT_QUALITY}
DEVICE=${3:-$DEFAULT_DEVICE}

# ------------------------------------------------------------------------------
# 0. CLEANUP FUNKTION (Wird bei STRG+C ausgeführt)
# ------------------------------------------------------------------------------
cleanup() {
    echo ""
    echo "--------------------------------------------------"
    echo "🛑 Vorgang abgebrochen oder beendet..."
    echo "📺 Sende Stop-Befehl an $DEVICE..."

    # Sendet den Stop-Befehl an den TV
    catt -d "$DEVICE" stop >/dev/null 2>&1

    echo "✅ TV-Bildschirm freigegeben. Tschüss!"
    echo "=================================================="
    exit 0
}

# Registriert die Cleanup-Funktion für das Signal SIGINT (STRG+C)
trap cleanup SIGINT

echo "=================================================="
echo "📺 TwitchCast Debug Tool (mit Auto-Retry)"
echo "=================================================="
echo "Channel : $CHANNEL"
echo "Quality : $QUALITY"
echo "Device  : $DEVICE"
echo "💡 INFO : Drücke [STRG + C] im Terminal, um abzubrechen/TV zu stoppen."
echo "--------------------------------------------------"

# ------------------------------------------------------------------------------
# 1. Check tools
# ------------------------------------------------------------------------------
echo "[1/5] Checking dependencies..."

command -v streamlink >/dev/null || {
  echo "❌ streamlink fehlt"
  exit 1
}

command -v catt >/dev/null || {
  echo "❌ catt fehlt"
  exit 1
}

echo "✅ Tools vorhanden"

# ------------------------------------------------------------------------------
# 2. Stream URL holen
# ------------------------------------------------------------------------------
echo ""
echo "[2/5] Resolving Twitch stream URL..."

URL=$(streamlink "twitch.tv/$CHANNEL" "$QUALITY" --stream-url 2>/dev/null)

if [ -z "$URL" ]; then
  echo "❌ Kein Stream gefunden"
  echo "💡 Prüfe Kanalname oder Qualität"
  exit 1
fi

echo "✅ Stream URL erhalten:"
echo "$URL"

# ------------------------------------------------------------------------------
# 3. Chromecast check
# ------------------------------------------------------------------------------
echo ""
echo "[3/5] Checking Chromecast devices..."

catt scan 2>/dev/null || true

echo "🎯 Target device: $DEVICE"

# ------------------------------------------------------------------------------
# 4. Cast attempt mit Auto-Retry Schleife
# ------------------------------------------------------------------------------
echo ""
echo "[4/5] Starting cast..."

ATTEMPT=1
SUCCESS=0

while [ $ATTEMPT -le $MAX_RETRIES ]; do
  echo "🔄 Sendeversuch $ATTEMPT von $MAX_RETRIES..."

  catt -d "$DEVICE" cast "$URL"
  CATT_EXIT=$?

  if [ $CATT_EXIT -eq 0 ]; then
    SUCCESS=1
    break # Schleife verlassen, da es geklappt hat
  else
    echo "⚠️ Versuch $ATTEMPT fehlgeschlagen (Timeout/Fehler)."

    if [ $ATTEMPT -lt $MAX_RETRIES ]; then
      echo "⏳ Warte $RETRY_DELAY Sekunden vor dem nächsten Versuch..."
      sleep $RETRY_DELAY
    fi
  fi

  ATTEMPT=$((ATTEMPT + 1))
done

# ------------------------------------------------------------------------------
# 5. Result
# ------------------------------------------------------------------------------
echo ""
echo "[5/5] Result"

if [ $SUCCESS -eq 1 ]; then
  echo "✅ Stream erfolgreich nach $ATTEMPT Versuch(en) gestartet!"
  echo "⏳ Halte dieses Terminal offen. Zum Beenden [STRG + C] drücken."

  # Hält das Script aktiv, damit der "trap" auf STRG+C lauschen kann
  while true; do sleep 1; done
else
  echo "❌ Cast nach $MAX_RETRIES Versuchen endgültig fehlgeschlagen."
  echo "🔧 Debug Tipps:"
  echo "   - Starte den Fernseher einmal neu (Strom trennen)."
  echo "   - Prüfe deine Linux-Firewall (ggf. blockiert sie die Antwort)."
  exit 1
fi
