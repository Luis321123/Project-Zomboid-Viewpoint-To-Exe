#!/usr/bin/env bash
# ============================================================================
#  actualizar_b4221.sh
#  Actualiza EN SU SITIO tu copia de Project Zomboid a Build 42.21 (o superior)
#  partiendo de una FUENTE de archivos del juego (carpeta o comprimido).
#
#  Que hace, en orden:
#     0. Comprueba la fuente (debe contener projectzomboid.jar).
#     1. Respaldo RAPIDO del juego actual (cp -al: copia por enlaces duros,
#        ocupa casi nada y es instantanea).
#     2. rsync de la fuente -> tu juego, BORRANDO archivos obsoletos,
#        pero PROTEGIENDO el crack (OnlineFix) y los mods/agente.
#     3. Reinstala ZombieBuddy + Viewpoint y re-parchea los lanzadores.
#
#  Uso:
#     ./actualizar_b4221.sh --fuente <CARPETA_O_ZIP> [--destino DIR]
#                           [--aplicar] [--no-borrar] [--usar-crack-nuevo]
#                           [--sin-mods]
#
#  Sin --aplicar solo MUESTRA el plan (no toca nada).
#
#  Ejemplos:
#     # 1) ver que haria con un repack nuevo ya descomprimido
#     ./actualizar_b4221.sh --fuente ~/Descargas/Project.Zomboid.v42.21.0-0xdeadcode
#
#     # 2) aplicarlo de verdad
#     ./actualizar_b4221.sh --fuente ~/Descargas/Project.Zomboid.v42.21.0-0xdeadcode --aplicar
#
#     # 3) desde un .zip (se descomprime en /tmp)
#     ./actualizar_b4221.sh --fuente ~/Descargas/PZ42.21.zip --aplicar
# ============================================================================
set -euo pipefail

log(){ printf '\033[1m[%s]\033[0m %s\n' "$(date +%H:%M:%S)" "$*"; }
err(){ printf '\033[31m[ERROR]\033[0m %s\n' "$*" >&2; exit 1; }

KIT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEST="$(cd "$KIT_DIR/.." && pwd)"      # la carpeta del repack actual
FUENTE=""; APLICAR=0; BORRAR=1; CRACK_NUEVO=0; CON_MODS=1; PROBAR=0

while [ $# -gt 0 ]; do
  case "$1" in
    --fuente)          FUENTE="${2:-}"; shift 2;;
    --destino)         DEST="${2:-}"; shift 2;;
    --aplicar)         APLICAR=1; shift;;
    --no-borrar)       BORRAR=0; shift;;
    --usar-crack-nuevo) CRACK_NUEVO=1; shift;;
    --sin-mods)        CON_MODS=0; shift;;
    --probar)          PROBAR=1; shift;;
    -h|--help)         sed -n '2,30p' "$0"; exit 0;;
    *) err "Opcion desconocida: $1 (usa --help)";;
  esac
done

[ -n "$FUENTE" ] || err "Falta --fuente. Usa --help para ver el uso."
[ -d "$DEST" ]   || err "El destino '$DEST' no existe."

# ---------- 0) resolver la fuente ----------
CLEANUP=""
resolve_srcroot(){
  local f="$1" tmp root
  if [ -d "$f" ]; then echo "$f"; return; fi
  [ -f "$f" ] || err "La fuente '$f' no existe."
  tmp="$(mktemp -d /tmp/opencode/pzsrc.XXXXXX)"; CLEANUP="$tmp"
  case "$f" in
    *.zip) log "Descomprimiendo ZIP..."; unzip -q "$f" -d "$tmp";;
    *.7z)  log "Descomprimiendo 7z...";  7z x -y -o"$tmp" "$f" >/dev/null;;
    *.rar) log "Descomprimiendo RAR..."; unrar x -o+ "$f" "$tmp/" >/dev/null;;
    *) err "Formato no soportado (usa .zip/.7z/.rar o una carpeta).";;
  esac
  root="$(find "$tmp" -name projectzomboid.jar -printf '%h\n' 2>/dev/null | head -1)"
  [ -n "$root" ] || err "No encuentro projectzomboid.jar dentro de $f"
  echo "$root"
}
cleanup(){ [ -n "$CLEANUP" ] && rm -rf "$CLEANUP" || true; }
trap cleanup EXIT

SRC="$(resolve_srcroot "$FUENTE")"
SRC="$(cd "$SRC" && pwd)"
[ -f "$SRC/projectzomboid.jar" ] || err "'$SRC' no contiene projectzomboid.jar (fuente incorrecta)."
[ -f "$DEST/projectzomboid.jar" ] || err "'$DEST' no parece una instalacion de PZ."

log "Fuente : $SRC"
log "Destino: $DEST"

# Tamaño de los dos jars (para confirmar que es una version distinta)
S_SZ=$(stat -c%s "$SRC/projectzomboid.jar" 2>/dev/null || echo 0)
D_SZ=$(stat -c%s "$DEST/projectzomboid.jar" 2>/dev/null || echo 0)
log "projectzomboid.jar  fuente=${S_SZ} bytes  actual=${D_SZ} bytes"
if [ "$S_SZ" = "$D_SZ" ]; then
  log "AVISO: el tamaño del jar coincide; puede que la fuente NO sea 42.21."
fi

# ---------- lista de exclusiones (se PROTEGE del borrado/sobrescritura) ----------
KIT_BASE="$(basename "$KIT_DIR")"
EXC=( --exclude="/mods/ZombieBuddy" --exclude="/mods/Viewpoint" --exclude="/mods/loaded.txt"
      --exclude="/ZombieBuddy.jar" --exclude="/zbNative.dll"
      --exclude="/$KIT_BASE" --exclude="_backup_*" --exclude="/_viewpoint_backup_*" )
if [ "$CRACK_NUEVO" -eq 0 ]; then
  EXC+=( --exclude="/OnlineFix64.dll" --exclude="/OnlineFix.ini" --exclude="/OnlineFix.url"
         --exclude="/steam_api64.dll" --exclude="/steam_api64.of" --exclude="/steam_appid.txt"
         --exclude="/SKIDROWRELOADED.COM.txt" )
fi

echo
echo "=======================  PLAN  ======================="
echo " rsync $SRC/  ->  $DEST/   $([ "$BORRAR" -eq 1 ] && echo '(con --delete: borra obsoletos)' || echo '(sin borrar)')"
echo " PROTEGIDO (no se toca en destino):"
printf '   %s\n' "${EXC[@]}" | sed 's/--exclude=//'
echo " Respaldo rapido previo:  $(dirname "$DEST")/_backup_b42.20.4_<fecha>"
[ "$CON_MODS" -eq 1 ] && echo " Luego: reinstalar ZombieBuddy+Viewpoint y re-parchear lanzadores."
echo "======================================================"
echo

if [ "$APLICAR" -ne 1 ]; then
  log "SIMULACION. No se ha tocado nada. Anade --aplicar para ejecutarlo."
  exit 0
fi

# ---------- 1) respaldo rapido con enlaces duros ----------
TS="$(date +%Y%m%d_%H%M%S)"
BACKUP="$(dirname "$DEST")/_backup_b42.20.4_$TS"
log "Creando respaldo rapido en: $BACKUP"
mkdir -p "$BACKUP"
cp -al "$DEST/." "$BACKUP/"
log "Respaldo hecho (enlaces duros; ocupa casi 0)."

# ---------- 2) el merge ----------
RSYNC_OPTS=( -a --human-readable --info=progress2 )
[ "$BORRAR" -eq 1 ] && RSYNC_OPTS+=( --delete )
RSYNC_OPTS+=("${EXC[@]}")
log "Copiando archivos del juego (puede tardar)..."
rsync "${RSYNC_OPTS[@]}" "$SRC/" "$DEST/"

# ---------- 3) reinstalar mods + agente ----------
if [ "$CON_MODS" -eq 1 ]; then
  log "Reinstalando ZombieBuddy + Viewpoint y parcheando lanzadores..."
  bash "$KIT_DIR/aplicar_viewpoint_zb.sh" "$DEST" 42.21
fi

# ---------- 4) prueba opcional del agente ----------
if [ "$PROBAR" -eq 1 ]; then
  log "Probando que el agente carga bajo Wine (solo -version, sin abrir el juego)..."
  ( cd "$DEST" && WINEDEBUG=-all wine "jre64/bin/java.exe" -Djava.library.path='win64/;.' \
      -agentlib:zbNative -version 2>&1 | grep -iE 'ZombieBuddy|version|error' | head ) || true
fi

echo
log "ACTUALIZACION APLICADA."
log "  Respaldo: $BACKUP"
log "  Si algo va mal, restaura con:  rsync -a --delete '$BACKUP/' '$DEST/'"
log "  Arranca el juego y comprueba en consola: 'Build 42.21' y '[ZB] activating ZombieBuddy'."
