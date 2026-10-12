#!/usr/bin/env bash
# ============================================================================
#  actualizar_por_steam.sh
#  Descarga el juego base Build 42.21 (rama publica) con steamcmd y luego llama
#  a actualizar_b4221.sh para fusionarlo en tu copia.
#
#  >>> Requiere una cuenta de Steam QUE POSEA Project Zomboid. <<<
#  La descarga anonima NO funciona (baja 0 bytes); es una limitacion de Steam,
#  no de este script.
#
#  Uso:
#     ./actualizar_por_steam.sh <USUARIO_STEAM> [--aplicar]
#
#  Te pedira la contrasena (y, si tienes, el codigo Steam Guard) de forma
#  interactiva. La descarga va a /tmp/opencode/pz_steam (unos ~10 GB) y NO
#  pisa tu juego hasta que confirmes.
# ============================================================================
set -euo pipefail

USUARIO="${1:-}"
shift || true
[ -n "$USUARIO" ] || { echo "Uso: $0 <USUARIO_STEAM> [--aplicar]"; exit 1; }

STEAMCMD="${STEAMCMD:-$HOME/steamcmd/steamcmd.sh}"
STAGE="${PZ_STEAM_STAGE:-/tmp/opencode/pz_steam}"
[ -x "$STEAMCMD" ] || { echo "[ERROR] No encuentro steamcmd en $STEAMCMD"; exit 1; }

echo "======================================================================"
echo " Descarga de Project Zomboid (Build 42.21, rama publica) via steamcmd"
echo " Cuenta : $USUARIO"
echo " Destino: $STAGE"
echo "======================================================================"
echo "NOTA: si tu cuenta NO posee el juego, la descarga dara 0 bytes."
echo

mkdir -p "$STAGE"
"$STEAMCMD" +force_install_dir "$STAGE" +login "$USUARIO" +app_update 108600 +quit

if [ ! -f "$STAGE/projectzomboid.jar" ]; then
  echo
  echo "[ERROR] No se ha descargado el juego (falta projectzomboid.jar)."
  echo "        Motivos habituales: la cuenta no posee PZ, o fallo de login/Guard."
  exit 1
fi

echo
echo "[OK] Descarga completada. Fusionando con tu copia..."
exec "$(dirname "$0")/actualizar_b4221.sh" --fuente "$STAGE" --aplicar "$@"
