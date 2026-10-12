#!/usr/bin/env bash
# ============================================================================
#  aplicar_viewpoint_zb.sh
#  (Re)instala ZombieBuddy + Project Viewpoint (3D) en CUALQUIER carpeta de
#  Project Zomboid sobre Wine/Linux.  Es idempotente: puedes ejecutarlo tantas
#  veces como quieras.
#
#  Uso:
#     ./aplicar_viewpoint_zb.sh <CARPETA_DEL_JUEGO> [versionMin]
#
#  Ejemplos:
#     ./aplicar_viewpoint_zb.sh /ruta/a/ProjectZomboid         # asume 42.21
#     ./aplicar_viewpoint_zb.sh /ruta/a/ProjectZomboid 42.20   # para 42.20.x
#
#  Variables opcionales:
#     PZ_WORKSHOP_CACHE  carpeta .../steamapps/workshop/content/108600
#     PZ_WINE_USERDIR    carpeta .../Zomboid  (datos de usuario de Wine)
# ============================================================================
set -euo pipefail

log(){ printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*"; }
err(){ printf '[ERROR] %s\n' "$*" >&2; exit 1; }

GAMEDIR="${1:-}"
VERSIONMIN="${2:-42.21}"
[ -n "$GAMEDIR" ] || err "Uso: $0 <CARPETA_DEL_JUEGO> [versionMin]"
GAMEDIR="$(cd "$GAMEDIR" && pwd)"
[ -f "$GAMEDIR/projectzomboid.jar" ] || err "'$GAMEDIR' no contiene projectzomboid.jar (¿es la carpeta del juego?)"

# ------- origen de los mods (Workshop) -------
WS="${PZ_WORKSHOP_CACHE:-$HOME/.local/share/Steam/steamapps/workshop/content/108600}"
ZB_SRC="$WS/3619862853/mods/ZombieBuddy"
VP_SRC="$WS/3809306528/mods/Viewpoint"

if [ ! -d "$ZB_SRC" ] || [ ! -d "$VP_SRC" ]; then
  HERE="$(cd "$(dirname "$0")" && pwd)"
  [ -d "$HERE/mods/ZombieBuddy" ] && ZB_SRC="$HERE/mods/ZombieBuddy"
  [ -d "$HERE/mods/Viewpoint" ]  && VP_SRC="$HERE/mods/Viewpoint"
fi
[ -d "$ZB_SRC" ] || err "No encuentro el mod ZombieBuddy en: $ZB_SRC"
[ -d "$VP_SRC" ] || err "No encuentro el mod Viewpoint en: $VP_SRC"

log "Juego    : $GAMEDIR"
log "versionMin que se aplicara: $VERSIONMIN"

# ------- 1) mods dentro de <juego>/mods -------
log "Copiando mods a <juego>/mods ..."
mkdir -p "$GAMEDIR/mods"
rsync -a --delete "$ZB_SRC/" "$GAMEDIR/mods/ZombieBuddy/"
rsync -a --delete "$VP_SRC/"  "$GAMEDIR/mods/Viewpoint/"

# ------- 2) mods en la carpeta de usuario de Wine (por si el juego lee de ahi) -------
detect_wine_userdir(){
  if [ -n "${PZ_WINE_USERDIR:-}" ]; then echo "$PZ_WINE_USERDIR"; return; fi
  local wp="${WINEPREFIX:-$HOME/.wine}" c
  for c in "$wp/drive_c/users/$USER/Zomboid" "$wp/drive_c/users/$(basename "$HOME")/Zomboid"; do
    [ -d "$c" ] && { echo "$c"; return; }
  done
  c="$(ls -d "$wp"/drive_c/users/*/Zomboid 2>/dev/null | head -1 || true)"
  echo "${c:-}"
}
UDIR="$(detect_wine_userdir)"
if [ -n "$UDIR" ] && [ -d "$UDIR" ]; then
  log "Copiando mods a $UDIR/mods ..."
  mkdir -p "$UDIR/mods"
  rsync -a --delete "$ZB_SRC/" "$UDIR/mods/ZombieBuddy/"
  rsync -a --delete "$VP_SRC/"  "$UDIR/mods/Viewpoint/"
else
  log "AVISO: no encontre la carpeta de usuario de Wine/Zomboid; omito esa copia."
fi

# ------- 3) agente ZombieBuddy en la raiz -------
if [ -f "$ZB_SRC/libs/ZombieBuddy.jar" ] && [ -f "$ZB_SRC/libs/zbNative.dll" ]; then
  rm -f "$GAMEDIR/ZombieBuddy.jar" "$GAMEDIR/zbNative.dll"
  cp "$ZB_SRC/libs/ZombieBuddy.jar" "$GAMEDIR/ZombieBuddy.jar"
  cp "$ZB_SRC/libs/zbNative.dll"    "$GAMEDIR/zbNative.dll"
  log "Agente ZombieBuddy copiado a la raiz del juego."
elif [ ! -f "$GAMEDIR/ZombieBuddy.jar" ]; then
  log "AVISO: falta ZombieBuddy.jar y no hay copia en el mod."
fi

# ------- 4) parchear lanzadores (JSON + .bat) con el agente -------
python3 - "$GAMEDIR" <<'PYEOF'
import sys, os, re
gd = sys.argv[1]
def rd(p): return open(p,'rb').read()
def wr(p,b): open(p,'wb').write(b)

# --- JSON (pzexe). Insertar -agentlib:zbNative como primer vmArg. ---
j = os.path.join(gd, 'ProjectZomboid64.json')
if os.path.exists(j):
    s = rd(j)
    if b'-agentlib:zbNative' in s:
        print('  ProjectZomboid64.json: ya tenia el agente.')
    else:
        m = re.search(rb'("vmArgs"\s*:\s*\[[ \t]*)(\r\n|\n)([ \t]*)', s)
        if m:
            nl = m.group(2); ind = m.group(3)
            ins = m.group(1) + nl + ind + b'"-agentlib:zbNative",' + nl + ind
            s = s[:m.start()] + ins + s[m.end():]
            wr(j, s)
            print('  ProjectZomboid64.json: agente insertado en vmArgs.')
        else:
            print('  AVISO: no encontre "vmArgs": [ en el JSON.')

# --- .bat: SET _JAVA_OPTIONS=-agentlib:zbNative ---
for name in ('ProjectZomboid64.bat','ProjectZomboid64ShowConsole.bat','ProjectZomboidOpenGLDebug64.bat'):
    p = os.path.join(gd, name)
    if not os.path.exists(p): continue
    s = rd(p)
    nl = b'\r\n' if b'\r\n' in s else b'\n'
    if re.search(rb'^SET _JAVA_OPTIONS=', s, re.M):
        s = re.sub(rb'^SET _JAVA_OPTIONS=[^\r\n]*',
                   b'SET _JAVA_OPTIONS=-agentlib:zbNative', s, count=1, flags=re.M)
        print(f'  {name}: _JAVA_OPTIONS actualizado.')
    else:
        m = re.search(rb'^@cd /d "%~dp0"', s, re.M)
        if m:
            s = s[:m.end()] + nl + b'SET _JAVA_OPTIONS=-agentlib:zbNative' + s[m.end():]
            print(f'  {name}: _JAVA_OPTIONS insertado.')
        else:
            print(f'  AVISO: {name} sin punto de insercion para _JAVA_OPTIONS.')
    wr(p, s)
PYEOF

# ------- 5) versionMin del mod Viewpoint -------
for mi in "$GAMEDIR/mods/Viewpoint/common/mod.info" \
          ${UDIR:+"$UDIR/mods/Viewpoint/common/mod.info"}; do
  [ -f "$mi" ] || continue
  if grep -q '^versionMin=' "$mi"; then
    sed -i "s/^versionMin=.*/versionMin=${VERSIONMIN}/" "$mi"
  else
    printf 'versionMin=%s\n' "$VERSIONMIN" >> "$mi"
  fi
done
log "Viewpoint versionMin => $VERSIONMIN"

log "LISTO. Ahora, en el juego: activa 'ZombieBuddy' y luego 'Viewpoint' y aprueba los JAR."
